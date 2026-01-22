import 'dart:io';

void main() async {
  print(" Simple server Start ... !");

  final server = await ServerSocket.bind('localhost', 8080);


  print ('server work on : localhost:8080');
  print ('waiting clint ...\n');

  // 2. انتظار الكلاينت (Client)
  await for (var client in server ){
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('new client online.. !');
    print('address: ${client.remoteAddress.address}:${client.remotePort}');
    // 3. إرسال رسالة ترحيب
    client.write("hello , i'm Simple Server \n");
    client.write(" done \n");
    print('Sent welcome message .. ');
    await client.close();
    print('client Disconnected');
  }

}

