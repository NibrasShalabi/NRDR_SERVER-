
import 'package:nrdr/models/dns_record.dart';

void main() {
  print('=== اختبار DnsRecord ===\n');

  // Test 1: إنشاء سجل
  print('Test 1: إنشاء سجل');
  final record1 = DnsRecord(
    name: 'mysite.nrdr',
    host: '127.0.0.1',
    port: 1413,
    type: 'web',
  );
  print('$record1');
  print('العنوان: ${record1.address}\n');

  // Test 2: localhost factory
  print('Test 2: localhost factory');
  final record2 = DnsRecord.localhost('api.nrdr', 8080, type: 'api');
  print('$record2\n');

  // Test 3: التحقق من الصلاحية
  print(' Test 3: التحقق من الصلاحية');
  print('Name valid? ${record1.isValidName}');
  print('Port valid? ${record1.isValidPort}');
  print('All valid? ${record1.isValid}\n');

  // Test 4: copyWith
  print(' Test 4: copyWith');
  final updated = record1.copyWith(port: 9000);
  print('الأصلي: $record1');
  print('المحدث: $updated\n');

  // Test 5: toMap/fromMap
  print('Test 5: toMap/fromMap');
  final map = record1.toMap();
  print('Map: $map');
  final restored = DnsRecord.fromMap(map);
  print('Restored: $restored\n');

  // Test 6: المقارنة
  print('Test 6: المقارنة');
  final record3 = DnsRecord.localhost('mysite.nrdr', 1413);
  print('record1 == record3? ${record1 == record3}');
}