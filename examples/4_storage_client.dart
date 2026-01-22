import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  if (args.isEmpty) {
    print(' use: dart run examples/4_storage_client.dart <command>');
    print('\eexample:');
    print('  dart run examples/4_storage_client.dart SET name Nibras');
    print('  dart run examples/4_storage_client.dart GET name');
    print('  dart run examples/4_storage_client.dart DELETE name');
    print('  dart run examples/4_storage_client.dart LIST');
    print('  dart run examples/4_storage_client.dart EXISTS name');
    print('  dart run examples/4_storage_client.dart STATS');
    print('  dart run examples/4_storage_client.dart HELP');
    return;
  }

  print(' connect to Storage Server...\n');

  try {
    final socket = await Socket.connect('localhost', 1413);

    print('connected to server!\n');

    final command = args.join(' ');
    socket.writeln(command);
    socket.flush();
    print(' commands: $command\n');

    print(' responses:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');

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