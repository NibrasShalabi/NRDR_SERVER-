import 'dart:convert';
import 'dart:io';

void main() async {
  print("Attempting to connect to the server .. ");
  try {
    final socket = await Socket.connect('localhost', 8080);
    print('We contacted the server ..!');
    print('address : ${socket.remoteAddress.address}:${socket.remotePort}\n');

    print('Server replies');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');

    await for (var data in socket) {
      // تحويل من bytes لـ String
      final message = utf8.decode(data);
      print(message.trim());
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');
    print(' server connected ..!');
    await socket.close();
  } catch (e) {
    print('error $e');
    print('Make sure the server is running .. !!');
  }
}
