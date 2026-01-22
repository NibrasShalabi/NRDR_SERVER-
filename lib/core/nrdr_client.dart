
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/nrdr_response.dart';
import '../services/dns_resolver.dart';
import '../utils/constants.dart';

/// Nrdr Client مع دعم DNS
class NrdrClient {
  final String _host;
  final int _port;
  Socket? _socket;
  bool _connected = false;

  // DNS Resolver
  final DnsResolver _dnsResolver = DnsResolver();

  NrdrClient({
    String host = 'localhost',
    int port = 1413,
  })  : _host = host,
        _port = port;

  /// الاتصال بالسيرفر
  Future<bool> connect() async {
    if (_connected) {
      print('  already connected!');
      return true;
    }

    try {
      print('🔌 connect to $_host:$_port...');

      _socket = await Socket.connect(
        _host,
        _port,
        timeout: Duration(seconds: NrdrConstants.connectionTimeout),
      );

      _connected = true;
      print(' connect successfully!\n');
      return true;

    } on SocketException catch (e) {
      print(' error: ${ErrorMessages.connectionFailed}');
      print('   details: $e\n');
      return false;

    } on TimeoutException catch (e) {
      print(' error: ${ErrorMessages.connectionTimeout}');
      print('   details: $e\n');
      return false;
    }
  }

  /// إرسال أمر واستقبال رد
  Future<NrdrResponse?> sendCommand(String command) async {
    if (!_connected || _socket == null) {
      print(' not connected to server!');
      return null;
    }

    try {
      _socket!.writeln(command);
      await _socket!.flush();

      final responseData = await _socket!.first;
      final responseText = utf8.decode(responseData);

      final response = NrdrResponse.parse(responseText);
      return response;

    } catch (e) {
      print(' error sending command: $e');
      return null;
    }
  }

  /// FETCH مع دعم DNS
  /// يمكن استخدام: fetch("mysite.nrdr/homepage")
  Future<NrdrResponse?> fetch(String key) async {
    // التحقق إذا في دومين
    if (key.contains('/')) {
      final parts = key.split('/');
      final domain = parts[0];
      final actualKey = parts[1];

      if (_dnsResolver.isDomain(domain)) {
        // حل الدومين
        final address = await _dnsResolver.resolve(domain);

        if (address == null) {
          print(' Failed to resolve $domain');
          return null;
        }

        // الاتصال بالسيرفر المحلول
        final addressParts = address.split(':');
        final resolvedHost = addressParts[0];
        final resolvedPort = int.parse(addressParts[1]);

        // حفظ الاتصال الحالي
        final oldSocket = _socket;
        final oldConnected = _connected;

        try {
          // اتصال مؤقت
          _socket = await Socket.connect(resolvedHost, resolvedPort);
          _connected = true;

          print(' send: FETCH $actualKey (via $domain)');
          final response = await sendCommand('${Commands.fetch} $actualKey');

          if (response != null) {
            _printResponse(response);
          }

          // إغلاق الاتصال المؤقت
          await _socket?.close();

          // استرجاع الاتصال الأصلي
          _socket = oldSocket;
          _connected = oldConnected;

          return response;

        } catch (e) {
          print(' Error connecting to resolved server: $e');
          _socket = oldSocket;
          _connected = oldConnected;
          return null;
        }
      }
    }

    // استخدام عادي بدون DNS
    print(' send: FETCH $key');
    final response = await sendCommand('${Commands.fetch} $key');

    if (response != null) {
      _printResponse(response);
    }

    return response;
  }

  /// PUBLISH مع دعم DNS
  Future<NrdrResponse?> publish(String key, String value) async {
    // نفس المنطق للـ DNS
    if (key.contains('/')) {
      final parts = key.split('/');
      final domain = parts[0];
      final actualKey = parts[1];

      if (_dnsResolver.isDomain(domain)) {
        final address = await _dnsResolver.resolve(domain);

        if (address == null) {
          print(' Failed to resolve $domain');
          return null;
        }

        final addressParts = address.split(':');
        final resolvedHost = addressParts[0];
        final resolvedPort = int.parse(addressParts[1]);

        final oldSocket = _socket;
        final oldConnected = _connected;

        try {
          _socket = await Socket.connect(resolvedHost, resolvedPort);
          _connected = true;

          print(' send: PUBLISH $actualKey $value (via $domain)');
          final response = await sendCommand('${Commands.publish} $actualKey $value');

          if (response != null) {
            _printResponse(response);
          }

          await _socket?.close();
          _socket = oldSocket;
          _connected = oldConnected;

          return response;

        } catch (e) {
          print(' Error: $e');
          _socket = oldSocket;
          _connected = oldConnected;
          return null;
        }
      }
    }

    print(' send: PUBLISH $key $value');
    final response = await sendCommand('${Commands.publish} $key $value');

    if (response != null) {
      _printResponse(response);
    }

    return response;
  }

  Future<NrdrResponse?> ping() async {
    print(' send: PING');
    final response = await sendCommand(Commands.ping);
    if (response != null) _printResponse(response);
    return response;
  }

  Future<NrdrResponse?> list() async {
    print(' send: LIST');
    final response = await sendCommand(Commands.list);
    if (response != null) _printResponse(response);
    return response;
  }

  Future<NrdrResponse?> delete(String key) async {
    print(' send: DELETE $key');
    final response = await sendCommand('${Commands.delete} $key');
    if (response != null) _printResponse(response);
    return response;
  }

  void _printResponse(NrdrResponse response) {
    print('\n response:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Status: ${response.statusCode} ${response.statusName}');

    if (response.isSuccess) {
      print(' successfully');
    } else if (response.isClientError) {
      print('  client error');
    } else if (response.isServerError) {
      print(' server error');
    }

    if (response.body.isNotEmpty) {
      print('\ncontent:');
      print(response.body);
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  Future<void> disconnect() async {
    if (!_connected) return;

    try {
      await _socket?.close();
      _connected = false;
      _socket = null;
      print('disconnected from server\n');
    } catch (e) {
      print(' error disconnecting: $e');
    }
  }

  bool get isConnected => _connected;
  String get address => '$_host:$_port';
}