import 'dart:convert';
import 'dart:io';

class StorageServer {

  final Map<String, String> _storage = {};

// الإحصائيات

int clientCount = 0;
int commandCount = 0;

Future<void> start () async {

  print(' start Storage Server...\n');
  final server = await ServerSocket.bind('localhost', 8080);
  print(' Storage Server work on : localhost:8080');
  print(' commands : SET, GET, DELETE, LIST, EXISTS, CLEAR, STATS');
  print(' waiting client ...\n');
  await for (var client in server) {
    clientCount++;
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');
    print(' client number  $clientCount connect!');
    print(' ${client.remoteAddress.address}:${client.remotePort}\n');
    _handleClient(client);
  }
  }
  /// معالجة كلاينت
  void _handleClient(Socket client) {
    client.listen(
          (data) {
        commandCount++;

        final message = utf8.decode(data).trim();
        print(' commands #$commandCount: "$message"');

        // معالجة الأمر
        final response = _processCommand(message);

        // إرسال الرد
        client.write('$response\n');
        print(' response: "$response"\n');
      },
      onDone: () {
        print(' client disconnected ');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        client.close();
      },
      onError: (error) {
        print(' error: $error');
        client.close();
      },
    );
  }

  String _processCommand(String message) {
    final parts = message.split(' ');
    final command = parts[0].toUpperCase();
    final args = parts.skip(1).toList();

    switch (command) {
    // تخزين قيمة
      case 'SET':
        return _handleSet(args);

    // استرجاع قيمة
      case 'GET':
        return _handleGet(args);

    // حذف قيمة
      case 'DELETE':
        return _handleDelete(args);

    // عرض كل المفاتيح
      case 'LIST':
        return _handleList();

    // التحقق من وجود مفتاح
      case 'EXISTS':
        return _handleExists(args);

    // حذف كل شي
      case 'CLEAR':
        return _handleClear();

    // الإحصائيات
      case 'STATS':
        return _handleStats();

    // PING للاختبار
      case 'PING':
        return 'PONG';

    // مساعدة
      case 'HELP':
        return _handleHelp();

      default:
        return 'ERROR: Unknown command "$command". Type HELP for commands.';
    }
  }
  String _handleSet(List<String> args) {
    if (args.length < 2) {
      return 'ERROR: SET requires key and value';
    }

    final key = args[0];
    final value = args.skip(1).join(' ');

    // التخزين بالـ Map
    _storage[key] = value;

    return 'OK: Stored "$key"';
  }

  /// GET key - استرجاع
  String _handleGet(List<String> args) {
    if (args.isEmpty) {
      return 'ERROR: GET requires a key';
    }

    final key = args[0];

    // البحث بالـ Map
    if (_storage.containsKey(key)) {
      return _storage[key]!;
    }

    return 'ERROR: Key "$key" not found';
  }

  /// DELETE key - حذف
  String _handleDelete(List<String> args) {
    if (args.isEmpty) {
      return 'ERROR: DELETE requires a key';
    }

    final key = args[0];

    // الحذف من الـ Map
    if (_storage.remove(key) != null) {
      return 'OK: Deleted "$key"';
    }

    return 'ERROR: Key "$key" not found';
  }

  /// LIST - عرض كل المفاتيح
  String _handleList() {
    if (_storage.isEmpty) {
      return 'EMPTY: No data stored';
    }

    // عرض كل المفاتيح
    return _storage.keys.join('\n');
  }

  /// EXISTS key - التحقق من وجود مفتاح
  String _handleExists(List<String> args) {
    if (args.isEmpty) {
      return 'ERROR: EXISTS requires a key';
    }

    final key = args[0];

    return _storage.containsKey(key) ? 'YES' : 'NO';
  }

  /// CLEAR - حذف كل البيانات
  String _handleClear() {
    final count = _storage.length;
    _storage.clear();

    return 'OK: Cleared $count items';
  }

  /// STATS - الإحصائيات
  String _handleStats() {
    return '''
Server Statistics:
  Clients connected: $clientCount
  Commands executed: $commandCount
  Items stored: ${_storage.length}
    ''';
  }

  /// HELP - المساعدة
  String _handleHelp() {
    return '''
Available commands:
  SET <key> <value>  - Store a value
  GET <key>          - Retrieve a value
  DELETE <key>       - Delete a value
  LIST               - List all keys
  EXISTS <key>       - Check if key exists
  CLEAR              - Delete all data
  STATS              - Show statistics
  PING               - Test connection
  HELP               - Show this help
    ''';
  }
}

/// نقطة البداية
void main() async {
  final server = StorageServer();
  await server.start();

}