import 'dart:io';
import 'package:nrdr/core/nrdr_client.dart';
import 'package:nrdr/utils/constants.dart';
void main (List<String> args )async{
  // عرض المساعدة
  if (args.isEmpty || args[0] == 'help') {
    _printHelp();
    return;
  }

  // قراءة الأمر
  final command = args[0].toLowerCase();

  // إنشاء الكلاينت
  final client = NrdrClient(
    host: NrdrConstants.serverHost,
    port: NrdrConstants.serverPort,
  );
  // الاتصال
  final connected = await client.connect();
  if (!connected) {
    exit(1);
  }
  // تنفيذ الأمر
  try {
    switch (command) {
      case 'ping':
        await client.ping();
        break;

      case 'fetch':
      case 'get':
        if (args.length < 2) {
          print(' use: client.dart fetch <key>');
          break;
        }
        await client.fetch(args[1]);
        break;

      case 'publish':
      case 'set':
        if (args.length < 3) {
          print(' use: client.dart publish <key> <value>');
          break;
        }
        final key = args[1];
        final value = args.skip(2).join(' ');
        await client.publish(key, value);
        break;

      case 'list':
        await client.list();
        break;

      case 'delete':
      case 'del':
        if (args.length < 2) {
          print(' use : client.dart delete <key>');
          break;
        }
        await client.delete(args[1]);
        break;

      default:
        print(' wrong command : $command');
        print('use: dart run bin/client.dart help\n');
    }
  } finally {
    // قطع الاتصال
    await client.disconnect();
  }


}
void _printHelp() {
  print('''


use:
  dart run bin/client.dart <command> [arguments]
command:

  ping                        test connection
  
  fetch <key>                 data recovery
  get <key>                   (same fetch)
  
  publish <key> <value>       data storage
  set <key> <value>           (same publish)
  
  list                        show all keys
  
  delete <key>                delete data
  del <key>                   (same delete)
  
  help                        show help list

example use :

  dart run bin/client.dart ping
  dart run bin/client.dart publish name Nibras
  dart run bin/client.dart fetch name
  dart run bin/client.dart list
  dart run bin/client.dart delete name

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''');
}