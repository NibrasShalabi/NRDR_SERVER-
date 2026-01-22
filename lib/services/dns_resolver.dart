// lib/services/dns_resolver.dart

import 'dart:io';
import 'dart:convert';
import '../models/dns_record.dart';
import '../models/nrdr_response.dart';
import '../utils/constants.dart';

/// DNS Resolver - حل أسماء .nrdr
class DnsResolver {
  final String _dnsHost;
  final int _dnsPort;

  DnsResolver({
    String dnsHost = 'localhost',
    int dnsPort = 1112,
  })  : _dnsHost = dnsHost,
        _dnsPort = dnsPort;

  /// حل اسم دومين لعنوان IP:Port
  Future<String?> resolve(String domain) async {
    try {
      print(' DNS: Solution $domain...');

      // الاتصال بـ DNS Server
      final socket = await Socket.connect(
        _dnsHost,
        _dnsPort,
        timeout: Duration(seconds: 5),
      );

      // إرسال RESOLVE
      socket.writeln('${Commands.resolve} $domain');
      await socket.flush();

      // استقبال الرد
      final responseData = await socket.first;
      final responseText = utf8.decode(responseData);

      await socket.close();

      // تحليل الرد
      final response = NrdrResponse.parse(responseText);

      if (response.isSuccess) {
        print(' DNS: $domain → ${response.body}');
        return response.body.trim();
      }

      print(' DNS: $domain not found');
      return null;

    } catch (e) {
      print(' DNS Error: $e');
      return null;
    }
  }

  /// التحقق هل الاسم دومين .nrdr
  bool isDomain(String name) {
    return name.endsWith(NrdrConstants.nrdrDomain);
  }
}