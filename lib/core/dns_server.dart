// lib/core/dns_server.dart

import 'dart:io';
import 'dart:convert';
import '../models/dns_record.dart';
import '../models/nrdr_response.dart';
import '../utils/constants.dart';

/// DNS Server
class DnsServer {
  final Map<String, DnsRecord> _registry = {};
  ServerSocket? _server;
  int _queryCount = 0;
  bool _isRunning = false;

  DnsServer() {
    // سجلات افتراضية
    _registry['mysite.nrdr'] = DnsRecord.localhost('mysite.nrdr', 1413);
    _registry['storage.nrdr'] = DnsRecord.localhost('storage.nrdr', 1413);
  }

  /// بدء DNS Server
  Future<void> start({
    String host = 'localhost',
    int port = 1112,
  }) async {
    if (_isRunning) {
      print('  DNS Server already work  ً!');
      return;
    }

    try {
      print(' start DNS Server...\n');

      _server = await ServerSocket.bind(host, port);
      _isRunning = true;

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print(' DNS Server start!');
      print(' address: $host:$port');
      print(' registry: ${_registry.length}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      print('waiting  Inquire...\n');

      await for (var client in _server!) {
        _handleClient(client);
      }

    } catch (e) {
      print(' start error DNS Server: $e');
      _isRunning = false;
    }
  }

  /// معالجة استعلام
  void _handleClient(Socket client) {
    final address = '${client.remoteAddress.address}:${client.remotePort}';

    client.listen(
          (data) {
        _queryCount++;
        final message = utf8.decode(data).trim();

        print('━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('Inquire  #$_queryCount from $address');
        print(' command: "$message"');

        final response = _processCommand(message);
        client.write(response.toRawString());

        print(' response: ${response.statusCode} ${response.statusName}');
        print('   Body: ${response.body}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      },
      onDone: () => client.close(),
      onError: (e) {
        print('error: $e');
        client.close();
      },
    );
  }

  /// معالجة الأوامر
  NrdrResponse _processCommand(String message) {
    final parts = message.split(' ');
    if (parts.isEmpty) {
      return NrdrResponse.badRequest(ErrorMessages.emptyCommand);
    }

    final command = parts[0].toUpperCase();
    final args = parts.skip(1).toList();

    switch (command) {
      case 'RESOLVE':
        return _handleResolve(args);

      case 'REGISTER':
        return _handleRegister(args);

      case 'LIST':
        return _handleList();

      case 'DELETE':
      case 'UNREGISTER':
        return _handleDelete(args);

      default:
        return NrdrResponse.badRequest(
            '${ErrorMessages.invalidCommand}: $command'
        );
    }
  }

  /// RESOLVE - حل دومين
  NrdrResponse _handleResolve(List<String> args) {
    if (args.isEmpty) {
      return NrdrResponse.badRequest(ErrorMessages.missingDomain);
    }

    final domain = args[0];

    if (_registry.containsKey(domain)) {
      final record = _registry[domain]!;
      return NrdrResponse.success('${record.host}:${record.port}');
    }

    return NrdrResponse.notFound(ErrorMessages.domainNotFound);
  }

  /// REGISTER - تسجيل دومين
  NrdrResponse _handleRegister(List<String> args) {
    // REGISTER domain host port [type]
    if (args.length < 3) {
      return NrdrResponse.badRequest(
          'Usage: REGISTER <domain> <host> <port> [type]'
      );
    }

    final domain = args[0];
    final host = args[1];
    final port = int.tryParse(args[2]);
    final type = args.length > 3 ? args[3] : 'web';

    if (port == null) {
      return NrdrResponse.badRequest(ErrorMessages.invalidPort);
    }

    // تحقق من الدومين
    if (!domain.endsWith('.nrdr')) {
      return NrdrResponse.badRequest(
          'Domain must end with .nrdr'
      );
    }

    // تحقق إذا موجود
    if (_registry.containsKey(domain)) {
      return NrdrResponse(
        statusCode: ResponseStatus.conflict,
        statusName: ResponseStatus.conflictName,
        body: ErrorMessages.domainAlreadyExists,
      );
    }

    // التسجيل
    _registry[domain] = DnsRecord(
      name: domain,
      host: host,
      port: port,
      type: type,
    );

    return NrdrResponse(
      statusCode: ResponseStatus.created,
      statusName: ResponseStatus.createdName,
      body: 'Registered $domain → $host:$port',
    );
  }

  /// LIST - عرض كل الدومينات
  NrdrResponse _handleList() {
    if (_registry.isEmpty) {
      return NrdrResponse(
        statusCode: ResponseStatus.noContent,
        statusName: ResponseStatus.noContentName,
        body: 'No domains registered',
      );
    }

    final domains = _registry.values.map((r) => r.toString()).join('\n');
    return NrdrResponse.success(domains);
  }

  /// DELETE - حذف دومين
  NrdrResponse _handleDelete(List<String> args) {
    if (args.isEmpty) {
      return NrdrResponse.badRequest(ErrorMessages.missingDomain);
    }

    final domain = args[0];

    if (_registry.remove(domain) != null) {
      return NrdrResponse.success('Deleted $domain');
    }

    return NrdrResponse.notFound(ErrorMessages.domainNotFound);
  }

  /// إيقاف السيرفر
  Future<void> stop() async {
    if (!_isRunning) return;

    print('\n stop DNS Server...');
    await _server?.close();
    _isRunning = false;

    print(' DNS Server stop');
    print(' Statistics:');
    print(' Inquiries: $_queryCount');
    print(' Domains: ${_registry.length}');
  }

  bool get isRunning => _isRunning;
}