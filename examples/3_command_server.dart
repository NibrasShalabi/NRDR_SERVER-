import 'dart:convert';
import 'dart:io';

void main() async {
  print("start command server ");
  final server = await ServerSocket.bind('localhost', 8080);
  print(' Command Server work on : localhost:8080');
  print(' available commands: PING, ECHO, TIME, REVERSE, COUNT, QUIT');
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
    print('get : $message');
    // معالجة الأمر
    final response = processCommand(message);

    client.write('$response\n');
    print(' send: "$response"\n');
  }, onDone: () {
    print('client Disconnected');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    client.close();
  }, onError: (error) {
    print("error : $error ");
    client.close();
  });
}

/// معالجة الأمر وإرجاع الرد

String processCommand(String message) {
  // تقسيم الأمر والمعاملات
  final parts = message.split(' ');

  // الأمر = أول كلمة (بأحرف كبيرة)
  final command = parts[0].toUpperCase();

  // باقي الكلمات = المعاملات
  final args = parts.skip(1).toList();

  // معالجة الأمر
  switch (command) {
    case 'PING':
      return 'PONG';
    case "ECHO":
      if (args.isEmpty) {
        return 'ERROR: ECHO needs a message';
      }
      return args.join(' ');
    case 'TIME':
      return DateTime.now().toString();
    case 'REVERSE':
      if (args.isEmpty) {
        return 'ERROR: REVERSE needs text';
      }
      final text = args.join(' ');
      return text.split('').reversed.join('');
    case 'COUNT':
      if (args.isEmpty) {
        return 'ERROR: COUNT needs text';
      }
      final text = args.join(' ');
      return '${text.length} characters';
    case 'UPPER':
      if (args.isEmpty) {
        return 'ERROR: UPPER needs text';
      }
      return args.join(' ').toUpperCase();
    case 'LOWER':
      if (args.isEmpty) {
        return 'ERROR: LOWER needs text';
      }
      return args.join(' ').toLowerCase();

    case 'HELP':
      return '''
Available commands:
  PING              - Test connection
  ECHO <message>    - Echo back message
  TIME              - Get current time
  REVERSE <text>    - Reverse text
  COUNT <text>      - Count characters
  UPPER <text>      - Convert to uppercase
  LOWER <text>      - Convert to lowercase
  HELP              - Show this help
  QUIT              - Close connection
      ''';

    case 'QUIT':
      return 'BYE';

    default:
      return 'ERROR: Unknown command "$command". Type HELP for commands.';
  }
}
