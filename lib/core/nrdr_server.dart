import 'dart:convert';
import 'dart:io';
import '../services/protocol_handler.dart';
import '../utils/constants.dart';

/// Nrdr Server
/// create TCP
/// Reception client
/// Receive text messages
/// Pass it to  protocol Handler
/// Reply via socket



class NrdrServer {

  final ProtocolHandler _handler = ProtocolHandler();
  ServerSocket? _server ;
// إحصائيات
  int _clientCount = 0;
  bool _isRunning = false;

  // start method
Future<void>start ({

  String host = 'localhost' ,
  int port = 1413,
})async{


  if( _isRunning) {
    print ("server is working already");
    return;
  }
  try{
    print("start nrdr sever .. ");
    _server = await ServerSocket.bind(host, port);
    _isRunning = true ;
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print(' Nrdr Server work!');
    print(' address: $host:$port');
    print(' protocol: Nrdr v${NrdrConstants.version}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    print(' waiting client ...\n');
    // معالجة الكلاينتات
await for (var client in _server!){
  _clientCount++;
  _handleClient(client , _clientCount);
}
  }catch(e){
    print(' error server start : $e');
_isRunning =false ;
  }
  }
/// معالجة كلاينت واحد
  void _handleClient(Socket client, int clientId) {
    final address = '${client.remoteAddress.address}:${client.remotePort}';
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');
    print(' client #$clientId connect');
    print(' address: $address');
    print(' time: ${DateTime.now()}');
    print('');
    // الاستماع للرسائل
    client.listen(
          (data) {
        _handleMessage(client, data, clientId);
      },
      onDone: () {
        print(' client #$clientId disconnect');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        client.close();
      },
      onError: (error) {
        print('Error with Clint #$clientId: $error');
        client.close();
      },
    );
  }

/// معالجة رسالة من الكلاينت
  void _handleMessage(Socket client, List<int> data, int clientId) {

try {
  final message = utf8.decode(data).trim();
  if (message.isEmpty) {
    return;
  }
  print(' client #$clientId: "$message"');
// معالجة الأمر عبر Protocol Handler
  final response = _handler.processCommand(message);

  // تحويل الرد لنص
  final responseText = response.toRawString();

  // إرسال الرد
  client.write(responseText);

  print(' response: ${response.statusCode} ${response.statusName}');

  // طباعة Body إذا كان قصير
  if (response.body.length < 100) {
    print('Body: ${response.body}');
  } else {
    print('Body: ${response.body.substring(0, 97)}...');
  }
  print('');

} catch (e) {
  print('Error processing message: $e');
}
  }

  Future<void> stop()async{
  if(!_isRunning){
    print('server is not working');
    return;
  }
  print('stop server') ;
  await _server?.close();
  _isRunning = false ;
  print(' server stop successfully');
  print(' statistics:');
  print('- clients counts : $_clientCount');
  final stats = _handler.getStats();
  print('- executed orders: ${stats['totalCommands']}');
  print('- stored data: ${stats['itemsStored']}');

  }
/// هل السيرفر شغال؟
bool get isRunning => _isRunning ;
  /// عدد الكلاينتات
  int get clientCount => _clientCount;
/// الإحصائيات
Map<String  , dynamic >getStats(){
  return {
    'isRunning': _isRunning,
    'clientCount': _clientCount,
    ..._handler.getStats(),
  };
}
}




