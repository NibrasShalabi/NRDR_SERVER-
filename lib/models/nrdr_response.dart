// lib/models/nrdr_response.dart

import '../utils/constants.dart';

/// نموذج لتمثيل رد من Nrdr Server
/// 
/// شكل الرد:
/// ```
/// 200 OK
/// Body content here
/// END
/// ```
class NrdrResponse {
  /// رمز الحالة (مثل 200, 404)
  final int statusCode;

  /// اسم الحالة (مثل OK, NOT_FOUND)
  final String statusName;

  /// محتوى الرد
  final String body;

  /// هل العملية نجحت؟ (2xx = نجاح)
  bool get isSuccess => ResponseStatus.isSuccess(statusCode);

  /// هل في خطأ من الكلاينت؟ (4xx)
  bool get isClientError => ResponseStatus.isClientError(statusCode);

  /// هل في خطأ من السيرفر؟ (5xx)
  bool get isServerError => ResponseStatus.isServerError(statusCode);

  /// Constructor أساسي
  NrdrResponse({
    required this.statusCode,
    required this.statusName,
    required this.body,
  });

  /// تحليل رد نصي وتحويله لـ NrdrResponse
  ///
  /// مثال:
  /// ```dart
  /// final raw = "200 OK\nHello\nEND\n";
  /// final response = NrdrResponse.parse(raw);
  /// print(response.statusCode); // 200
  /// ```
  factory NrdrResponse.parse(String rawResponse) {
    try {
      // تقسيم الرد لأسطر
      final lines = rawResponse.trim().split('\n');

      // التحقق من وجود محتوى
      if (lines.isEmpty) {
        return NrdrResponse._error('Empty response received');
      }

      // السطر الأول = Status Line
      // الشكل: "200 OK" أو "404 NOT_FOUND"
      final statusLine = lines.first.trim();

      // تقسيم Status Line
      final statusParts = statusLine.split(' ');

      // يجب أن يكون فيه على الأقل: رقم واسم
      if (statusParts.length < 2) {
        return NrdrResponse._error(
          'Invalid status line format: $statusLine',
        );
      }

      // استخراج Status Code
      final statusCodeStr = statusParts[0];
      final statusCode = int.tryParse(statusCodeStr);

      if (statusCode == null) {
        return NrdrResponse._error(
          'Invalid status code: $statusCodeStr',
        );
      }

      // استخراج Status Name (باقي السطر)
      final statusName = statusParts.skip(1).join(' ');

      // استخراج Body (كل الأسطر بين Status و END)
      final bodyLines = <String>[];

      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();

        // توقف عند END
        if (line == NrdrConstants.endMarker) {
          break;
        }

        bodyLines.add(line);
      }

      // دمج Body
      final body = bodyLines.join('\n');

      return NrdrResponse(
        statusCode: statusCode,
        statusName: statusName,
        body: body,
      );

    } catch (e) {
      return NrdrResponse._error(
        'Failed to parse response: $e',
      );
    }
  }

  /// إنشاء رد خطأ
  factory NrdrResponse._error(String message) {
    return NrdrResponse(
      statusCode: ResponseStatus.internalError,
      statusName: ResponseStatus.internalErrorName,
      body: message,
    );
  }

  /// إنشاء رد ناجح سريع
  factory NrdrResponse.success(String body) {
    return NrdrResponse(
      statusCode: ResponseStatus.ok,
      statusName: ResponseStatus.okName,
      body: body,
    );
  }

  /// إنشاء رد "مش موجود" سريع
  factory NrdrResponse.notFound(String message) {
    return NrdrResponse(
      statusCode: ResponseStatus.notFound,
      statusName: ResponseStatus.notFoundName,
      body: message,
    );
  }

  /// إنشاء رد "طلب خاطئ" سريع
  factory NrdrResponse.badRequest(String message) { 
    return NrdrResponse(
      statusCode: ResponseStatus.badRequest,
      statusName: ResponseStatus.badRequestName,
      body: message,
    );
  }

  /// تحويل NrdrResponse لنص (للإرسال)
  ///
  /// مثال:
  /// ```dart
  /// final response = NrdrResponse.success('Hello');
  /// print(response.toRawString());
  /// // 200 OK
  /// // Hello
  /// // END
  /// ```
  String toRawString() {
    return '$statusCode $statusName\n$body\n${NrdrConstants.endMarker}\n';
  }

  /// نسخة للطباعة (بدون END)
  @override
  String toString() {
    return '$statusCode $statusName\n$body';
  }

  /// للمقارنة بين NrdrResponse
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NrdrResponse &&
        other.statusCode == statusCode &&
        other.statusName == statusName &&
        other.body == body;
  }

  @override
  int get hashCode {
    return statusCode.hashCode ^
    statusName.hashCode ^
    body.hashCode;
  }

  /// تحويل لـ Map (مفيد للـ JSON لاحقاً)
  Map<String, dynamic> toMap() {
    return {
      'statusCode': statusCode,
      'statusName': statusName,
      'body': body,
      'isSuccess': isSuccess,
    };
  }

  /// إنشاء من Map
  factory NrdrResponse.fromMap(Map<String, dynamic> map) {
    return NrdrResponse(
      statusCode: map['statusCode'] as int,
      statusName: map['statusName'] as String,
      body: map['body'] as String,
    );
  }
}