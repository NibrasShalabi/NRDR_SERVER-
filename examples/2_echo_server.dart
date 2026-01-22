import 'dart:convert';
import 'dart:io';

void main() async {
  print(' Start Echo Server...\n');
  final server = await ServerSocket.bind('localhost', 8080);
  print(' Echo Server work in : localhost:8080');
  print('waiting clint ...\n');
  await for (var client in server) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('new client online.. !');
    print('address: ${client.remoteAddress.address}:${client.remotePort}');
    handleClient(client);
  }
}

void handleClient(Socket client) {
  client.listen((data) {
    final message = utf8.decode(data).trim();
    print('get:  "$message" ');
    // إرجاع نفس الرسالة (Echo!)
    client.write('echo : $message\n');
    print(' sent back : "Echo: $message"\n');
  }, onDone: () {
    print('client Disconnected');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    client.close();
  }, onError: (error) {
    print("error : $error ");
    client.close();
  });
}
