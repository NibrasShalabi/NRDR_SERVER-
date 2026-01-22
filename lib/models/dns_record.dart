/// نموذج لتمثيل سجل DNS
///
/// مثال:
/// ```
/// mysite.nrdr → 127.0.0.1:1413 (web)
/// ``

class DnsRecord {
  /// اسم الدومين (مثل: mysite.nrdr)

  final String name;

  /// العنوان IP (مثل: 127.0.0.1)

  final String host;

  /// نوع السجل (web, storage, api, service)

  final String type;

  /// رقم المنفذ (مثل: 1413)

  final int port;

  DnsRecord(
      {required this.name,
      required this.host,
      required this.type,
      required this.port});

  /// العنوان الكامل (host:port)

  String get address => '$host:$port';

  /// هل الاسم صالح؟
  ///
  /// يجب أن ينتهي بـ `.nrdr`
  bool get isValidName => name.endsWith('.nrdr');

  /// هل المنفذ صالح؟
  ///
  /// يجب أن يكون بين 1024 و 65535
  bool get isValidPort => port >= 1024 && port <= 65535;

  /// هل السجل صالح بالكامل؟
  bool get isValid =>
      isValidName && isValidPort && name.isNotEmpty && host.isNotEmpty;

  /// تحويل لـ Map (للتخزين أو JSON)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'host': host,
      'type': type,
      'port': port,
    };
  }

  /// إنشاء من Map
  factory DnsRecord.fromMap(Map<String, dynamic> map) {
    return DnsRecord(
        name: map['name'] as String,
        host: map['host'] as String,
        type: map['type'] as String,
        port: map['port'] as int);
  }

  /// تحويل لنص (للطباعة)
  @override
  String toString() {
    return '$name → $host:$port ($type)';
  }

  /// للمقارنة بين سجلين
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DnsRecord &&
        other.name == name &&
        other.host == host &&
        other.type == type &&
        other.port == port;
  }

  @override
  int get hashCode {
    return name.hashCode ^ host.hashCode ^ type.hashCode ^ port.hashCode;
  }

  /// نسخ مع تعديل بعض القيم
  ///
  /// مثال:
  /// ```dart
  /// final record = DnsRecord(...);
  /// final updated = record.copyWith(port: 8080);
  DnsRecord copyWith({
    String? name,
    String? host,
    String? type,
    int? port,
  }) {
    return DnsRecord(
        name: name ?? this.name,
        host: host ?? this.host,
        type: type ?? this.type,
        port: port ?? this.port);
  }

  /// إنشاء سجل للـ localhost
  ///
  /// مثال:
  /// ```dart
  /// final record = DnsRecord.localhost('mysite.nrdr', 1413);
  factory DnsRecord.localhost(String name, int port, {String type = 'web'}) {
    return DnsRecord(name: name, host: '127.0.0.1', type: type, port: port);
  }

  /// إنشاء سجل افتراضي (للاختبار)
  factory DnsRecord.defaultRecord() {
    return DnsRecord(
      name: 'mysite.nrdr',
      host: '127.0.0.1',
      port: 1413,
      type: 'web',
    );
  }
}
