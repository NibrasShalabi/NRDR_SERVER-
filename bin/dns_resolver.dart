import 'dart:io';
import 'dart:convert';
import 'package:nrdr/models/dns_record.dart';
import 'package:nrdr/utils/constants.dart';
import 'dart:async';

/// DNS Resolver - محلل أسماء النطاقات


class DnsResolver {
  final String _dnsHost ;
  final int _dnsPort;
/// Cache للسجلات (تسريع الأداء)
  final Map<String, DnsRecord> _cache = {};
  DnsResolver({
    String dnsHost = 'localhost',
    int dnsPort = 1112,
  })  : _dnsHost = dnsHost,
        _dnsPort = dnsPort;
/// حل اسم نطاق لعنوان IP:Port
///
/// مثال:
/// ```dart
/// final record = await resolver.resolve('mysite.nrdr');
/// print(record.address); // 127.0.0.1:1413
/// ```

Future<DnsRecord?> resolve (String domain )async{
  // التحقق من الصيغة
  if (!domain.endsWith(NrdrConstants.nrdrDomain)) {
    print('The domain must end with ${NrdrConstants.nrdrDomain}');
return null ;
  }
  // التحقق من الـ Cache
  if (_cache.containsKey(domain)) {
    print('the solution was found. Cache: $domain');
    return _cache[domain];
  }
  print(' scope solution: $domain...');
  try {
    // الاتصال بـ DNS Server
    final socket = await Socket.connect(
      _dnsHost,
      _dnsPort,
      timeout: Duration(seconds: NrdrConstants.connectionTimeout),
    );

    // إرسال طلب RESOLVE
    socket.writeln('${Commands.resolve} $domain');
    await socket.flush();

    // استقبال الرد
    final responseData = await socket.first;
    final responseText = utf8.decode(responseData);

    await socket.close();

    // تحليل الرد
    final record = _parseResolveResponse(domain, responseText);

    if (record != null) {
      // حفظ بالـ Cache
      _cache[domain] = record;
      print(' Solved: $domain → ${record.address}');
    } else {
      print(' domain resolution failed: $domain');
    }

    return record;

  } on SocketException catch (e) {
    print('error connection DNS Server: $e');
    return null;

  } on TimeoutException catch (e) {
    print(' The call time has ended. DNS Server: $e');
    return null;
  }
}
  /// تحليل رد DNS
  DnsRecord? _parseResolveResponse(String domain, String response) {
    try {
      final lines = response.trim().split('\n');

      // التحقق من الحالة
      if (lines.isEmpty) {
        return null;
      }

      final statusLine = lines.first;

      // لو NOT_FOUND
      if (statusLine.contains('404') || statusLine.contains('NOT_FOUND')) {
        return null;
      }

      // لو مش OK
      if (!statusLine.contains('200') && !statusLine.contains('OK')) {
        return null;
      }

      // استخراج العنوان
      // الشكل: 127.0.0.1:1413
      String? address;
      for (var line in lines) {
        if (line.contains(':') && !line.contains('OK')) {
          address = line.trim();
          break;
        }
      }

      if (address == null) {
        return null;
      }

      // تقسيم العنوان
      final parts = address.split(':');
      if (parts.length != 2) {
        return null;
      }

      final host = parts[0];
      final port = int.tryParse(parts[1]);

      if (port == null) {
        return null;
      }

      // إنشاء DnsRecord
      return DnsRecord(
        name: domain,
        host: host,
        port: port,
        type: RecordTypes.web,
      );

    } catch (e) {
      print('Error parsing response DNS: $e');
      return null;
    }
  }
  /// مسح الـ Cache
  void clearCache() {
    _cache.clear();
    print(' deleted Cache from DNS');
  }

  /// حذف سجل من الـ Cache
  void removeCached(String domain) {
    _cache.remove(domain);
    print('deleted don $domain from Cache');
  }

  /// عدد السجلات بالـ Cache
  int get cacheSize => _cache.length;

  /// كل السجلات المحفوظة
  List<DnsRecord> get cachedRecords => _cache.values.toList();
}




