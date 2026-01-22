
/// ثوابت مشروع Nrdr Protocol
/// هاد الملف بيحتوي كل القيم الثابتة المستخدمة بالمشروع


/// ثوابت الشبكة (Network Constants)
class NrdrConstants{
  // منع إنشاء كائن من هاد الكلاس
  // لأنو بس بدنا نستخدم الثوابت منو
NrdrConstants._();


/// المنفذ اللي بيشتغل عليه Nrdr Server
/// رقم 1413 اخترناه عشوائي (أي رقم فوق 1024 منيح)

static const int serverPort = 1413 ;

/// المنفذ اللي بيشتغل عليه DNS Server
/// رقم 1112 برضو اخترناه عشوائي
static const int dnsPort = 1112;

// === Hosts (العناوين) ===
/// عنوان Nrdr Server
/// localhost = الجهاز نفسو = 127.0.0.1

static const String serverHost = "localHost" ;

/// عنوان DNS Server
static const String dnsHost = "localHost" ;

// === Protocol Settings (إعدادات البروتوكول) ===
/// اللاحقة للدومينات تبعنا

static const String nrdrDomain = ".nrdr" ;

/// علامة نهاية الرسالة
/// كل رسالة بتنتهي بـ END
static const String endMarker = "END";

/// أقصى طول لاسم المفتاح
static const int maxKeyLength = 256 ;

/// أقصى طول لقيمة البيانات

static const int maxValueLength = 10000 ;

/// Timeout للاتصال (بالثواني)

static const int connectionTimeout = 10 ;

  /// نسخة البروتوكول

static const String version = '1.0.0';

}
/// أوامر البروتوكول (Protocol Commands)

class Commands {
  Commands._();
// === Nrdr Server Commands ===

/// أمر PING - للتأكد إنو السيرفر شغال
/// الاستخدام: PING
/// الرد: PONG <timestam

static const  String ping = "PING";

/// أمر FETCH - لاسترجاع البيانات
/// الاستخدام: FETCH <key>
/// الرد: OK\n<data>\nEND

static const String fetch = "FETCH";

/// أمر PUBLISH - لتخزين البيانات
/// الاستخدام: PUBLISH <key> <value>
/// الرد: PUBLISHED Successfully stored <key>\nEND

static const String publish = "PUGLISH";

/// أمر LIST - لعرض كل المفاتيح المخزنة
/// الاستخدام: LIST
/// الرد: OK\n<key1>\n<key2>\nEND
static const String list = "LIST";

// === DNS Commands ===
/// أمر RESOLVE - لحل اسم الدومين
/// الاستخدام: RESOLVE <domain.nexa>
/// الرد: RESOLVED <ip>:<port>\nEND
static const String resolve = "RESOLVE" ;

/// أمر REGISTER - لتسجيل دومين جديد
/// الاستخدام: REGISTER <name> <host> <port> <type>
/// الرد: REGISTERED Successfully registered <name>\nEND
static const String register = "REGISTER" ;

/// أمر UPDATE - لتحديث دومين موجود
/// الاستخدام: UPDATE <name> <host> <port> <type>
/// الرد: UPDATED Successfully updated <name>\nEND
static const String update = "UPDATE" ;

/// أمر DELETE - لحذف دومين
/// الاستخدام: DELETE <name>
/// الرد: DELETED Successfully deleted <name>\nEND
static const String delete = "DELETE";

}

/// Status Codes و Messages (Hybrid Approach)

class ResponseStatus{
  ResponseStatus._();

/// 200 - نجح الطلب

static const int ok = 200 ;
static const String okName = "OK";

/// 201 - تم الإنشاء/التخزين بنجاح

static const int created = 201 ;
static const String createdName = "CREATED" ;

/// 204 - نجح بس ما في محتوى

static const int noContent = 204 ;
static const String noContentName = "NO_CONTENT" ;

// === 4xx: Client Errors (أخطاء الكلاينت) ===
/// 400 - طلب خاطئ (مثلاً: معاملات ناقصة)

static const int badRequest = 400 ;
static const String badRequestName = "BAD_REQUEST" ;

/// 404 - مش موجود (المفتاح أو الدومين)
static const int notFound = 404 ;
static const String notFoundName = "NOT_FOUND";

/// 409 - تعارض (مثلاً: الدومين موجود مسبقاً)
static const int conflict = 409 ;
static const String conflictName = "CONFLICT" ;

/// 413 - البيانات كبيرة كتير
static const int payloadTooLarge = 413 ;
static const String payloadTooLargeName = "PAYLOAD_TOO_LARGE" ;

// === Server Errors (أخطاء السيرفر) ===
static const int internalError = 500 ;
static const String internalErrorName = "INTERNAL_ERROR" ;

/// 503 - السيرفر مش متاح
static const int serviceUnavailable = 503 ;
static const String serviceUnavailableName = "SERVICE_UNAVAILABLE" ;

// === Helper Methods ===
static String? getName (int code){
switch (code){
  case 200 : return okName ;
  case 201 : return createdName ;
  case 204 : return noContentName ;
  case 400 : return badRequestName ;
  case 404 : return notFoundName ;
  case 409 : return conflictName ;
  case 413 : return payloadTooLargeName ;
  case 500 : return internalErrorName ;
  case 503 : return serviceUnavailableName ;

}}
/// احصل على الكود من الاسم

  static int? getCode(String name) {
    switch (name.toUpperCase()) {
      case 'OK': return ok;
      case 'CREATED': return created;
      case 'NO_CONTENT': return noContent;
      case 'BAD_REQUEST': return badRequest;
      case 'NOT_FOUND': return notFound;
      case 'CONFLICT': return conflict;
      case 'PAYLOAD_TOO_LARGE': return payloadTooLarge;
      case 'INTERNAL_ERROR': return internalError;
      case 'SERVICE_UNAVAILABLE': return serviceUnavailable;
      default: return null;
    }
  }
/// هل الكود يدل على نجاح؟ (2xx)
static bool isSuccess (int code ) => code >= 200 && code < 300 ;
/// هل الكود يدل على خطأ من الكلاينت؟ (4xx)
static bool isClientError (int code) => code >= 400 && code < 500 ;
/// هل الكود يدل على خطأ من السيرفر؟ (5xx)
static bool isServerError (int code) => code >= 500 && code < 600 ;
/// تنسيق رد كامل
static String formatResponse (int statusCode , String body ) {
  final   statusName = getName(statusCode) ;
  return '$statusCode $statusName\n$body\n${NrdrConstants.endMarker}\n';
}

}
/// رسائل الأخطاء المفصلة (Error Messages)

class ErrorMessages {
ErrorMessages._();
// === Parameter Errors ===
  static const String missingKey = 'Missing key parameter';
  static const String missingValue = 'Missing value parameter';
  static const String missingDomain = 'Missing domain name';
  static const String missingHost = 'Missing host parameter';
  static const String missingPort = 'Missing port parameter';
  static const String missingType = 'Missing type parameter';

  // === Validation Errors ===
  static const String invalidCommand = 'Invalid or unknown command';
  static const String invalidDomain = 'Invalid domain name format';
  static const String invalidPort = 'Invalid port number';
  static const String keyTooLong = 'Key exceeds maximum length';
  static const String valueTooLong = 'Value exceeds maximum length';
  static const String emptyCommand = 'Empty command received';

  // === Not Found Errors ===
  static const String keyNotFound = 'Key not found in storage';
  static const String domainNotFound = 'Domain not registered';

  // === Conflict Errors ===
  static const String domainAlreadyExists = 'Domain already registered';
  static const String keyAlreadyExists = 'Key already exists';

  // === Connection Errors ===
  static const String connectionFailed = 'Failed to connect to server';
  static const String connectionTimeout = 'Connection timeout';
  static const String dnsResolutionFailed = 'DNS resolution failed';

  // === Server Errors ===
  static const String serverError = 'Internal server error occurred';
  static const String serverUnavailable = 'Server is currently unavailable';

}
/// رسائل النجاح (Success Messages)
class SuccessMessages {
  SuccessMessages._();
  static const String connected = 'Connected to server';
  static const String disconnected = 'Disconnected from server';
  static const String published = 'Data published successfully';
  static const String fetched = 'Data fetched successfully';
  static const String deleted = 'Data deleted successfully';
  static const String registered = 'Domain registered successfully';
  static const String updated = 'Domain updated successfully';
  static const String unregistered = 'Domain unregistered successfully';
  static const String resolved = 'Domain resolved successfully';
  static const String listed = 'List retrieved successfully';
}
/// أنواع السجلات (Record Types)

class RecordTypes {
  RecordTypes._();


  static const String web = 'web';
  static const String storage = 'storage';
  static const String api = 'api';
  static const String service = 'service';
  static const String custom = 'custom';
}