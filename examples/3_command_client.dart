import 'dart:io';
import 'dart:convert';
void main(List<String> args) async {



  if (args.isEmpty) {
    print(' use: dart run examples/3_command_client.dart <command>');
    print('\nexamples:');
    print('  dart run examples/3_command_client.dart PING');
    print('  dart run examples/3_command_client.dart ECHO Hello');
    print('  dart run examples/3_command_client.dart TIME');
    print('  dart run examples/3_command_client.dart REVERSE Nibras');
    print('  dart run examples/3_command_client.dart HELP');
    return;
  }
  print(' connect to  Command Server...\n');
  try {
    final socket = await Socket.connect('localhost', 8080);

    print(' connect to server !\n');

    // الأمر
    final command = args.join(' ');

    // إرسال الأمر
    socket.write('$command\n');
    print(' command: $command\n');

    print(' response:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');

    // استقبال الرد
    await for (var data in socket) {
      final response = utf8.decode(data).trim();
      print(response);
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━');

    await socket.close();

  } catch (e) {
    print(' error: $e');
  }
}

