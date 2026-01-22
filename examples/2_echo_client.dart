import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print("error");
    return;
  }
  print('server connected ');
  try {
    final socket = await Socket.connect('localhost', 8080);
    print('connect to Echo Server!\n');
    // الرسالة اللي بدنا نرسلها
    final message = args.join(' ');
    // إرسال الرسالة
    socket.write('$message \n');
    print(' send: "$message"\n');
    print(' response from server:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');
    // استقبال الرد
    await for (var data in socket) {
      final response = utf8.decode(data).trim();
      print(response);
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');
    await socket.close();
  } catch (e) {
    print('error : $e');
  }
}
