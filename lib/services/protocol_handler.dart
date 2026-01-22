import '../models/nrdr_response.dart';
import '../utils/constants.dart';

/// بروتوكول ياهد أومر نصية من
/// client => يحللها =>  then ينفذها
/// no tcp , socket , client
/// just (logic)
/// شكل الرد
/// statusCode / statusName / body ..
/// عن طريق دوال جاهزة
/// success / badRequest / notFound ..




class ProtocolHandler { // تنفيذ لأوامر دون اعتماد خارجي
  // Map  (in-memory storage)
  // تخزين مؤقت
  final Map<String, String> _storage = {};

  // إحصائيات
  int _commandCount = 0;
  int _publishCount = 0;
  int _fetchCount = 0;


// بوابة الدخول الوحيدة لكل الأوامر
  NrdrResponse processCommand(String message) {
    _commandCount++;
    try {
      // تقسيم الأمر
      final parts = message.trim().split(' ');

      if (parts.isEmpty || parts[0].isEmpty) {
        return NrdrResponse.badRequest(ErrorMessages.emptyCommand);
      }
      final command = parts[0].toUpperCase();
      final args = parts.skip(1).toList();
      // معالجة حسب الأمر
      // لكل أمر handler  حاص فيه
      switch (command) {
        case Commands.ping:
          return _handlePing();

        case Commands.fetch:
          return _handleFetch(args);

        case Commands.publish:
          return _handlePublish(args);

        case Commands.list:
          return _handleList();

        case Commands.delete:
          return _handleDelete(args);

        default:
          return NrdrResponse.badRequest(
              '${ErrorMessages.invalidCommand}: $command'
          );
      }
    } catch (e) {
      // منمنع الأوامر العشوائية و الغير مدعومة
      return NrdrResponse(
        statusCode: ResponseStatus.internalError,
        statusName: ResponseStatus.internalErrorName,
        body: '${ErrorMessages.serverError}: $e',
      );
    }
  }

  /// PING - اختبار الاتصال
  NrdrResponse _handlePing() {
    final timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
    return NrdrResponse.success(timestamp.toString());
  }

  /// FETCH key - استرجاع بيانات
  NrdrResponse _handleFetch(List<String> args) {
    _fetchCount++;
    if (args.isEmpty) {
      return NrdrResponse.badRequest(ErrorMessages.missingKey);
    }
    final key = args[0];
    // التحقق من الطول
    if (key.length > NrdrConstants.maxKeyLength) {
      return NrdrResponse.badRequest(ErrorMessages.keyTooLong);
    }
    // البحث بالتخزين
    if (_storage.containsKey(key)) {
      return NrdrResponse.success(_storage[key]!);
    }

    // غير موجود
    return NrdrResponse.notFound(ErrorMessages.keyNotFound);
  }

  /// PUBLISH key value - تخزين بيانات

  NrdrResponse _handlePublish(List<String> args) {
    _publishCount++;

    // التحقق من المعاملات
    if (args.isEmpty) {
      return NrdrResponse.badRequest(ErrorMessages.missingKey);
    }

    if (args.length < 2) {
      return NrdrResponse.badRequest(ErrorMessages.missingValue);
    }
    final key = args[0];
    final value = args.skip(1).join(' ');

    // التحقق من الطول
    if (key.length > NrdrConstants.maxKeyLength) {
      return NrdrResponse.badRequest(ErrorMessages.keyTooLong);
    }

    if (value.length > NrdrConstants.maxValueLength) {
      return NrdrResponse(
        statusCode: ResponseStatus.payloadTooLarge,
        statusName: ResponseStatus.payloadTooLargeName,
        body: ErrorMessages.valueTooLong,
      );
    }

    // التخزين
    final isNew = !_storage.containsKey(key);
    _storage[key] = value;
    //اذا القيمة جديدة => created
    // اذا موجودة =>  update

    // الرد
    if (isNew) {
      return NrdrResponse(
        statusCode: ResponseStatus.created,
        statusName: ResponseStatus.createdName,
        body: 'Successfully stored "$key"',
      );
    } else {
      return NrdrResponse.success('Updated "$key"');
    }
  }
/// LIST - عرض كل المفاتيح
  NrdrResponse _handleList() {
    if (_storage.isEmpty) {
      return NrdrResponse(
        statusCode: ResponseStatus.noContent,
        statusName: ResponseStatus.noContentName,
        body: 'No data stored',
      );
    }

    final keys = _storage.keys.join('\n');
    return NrdrResponse.success(keys);
  }

  /// DELETE key - حذف بيانات
  NrdrResponse _handleDelete(List<String> args) {
    if (args.isEmpty) {
      return NrdrResponse.badRequest(ErrorMessages.missingKey);
    }

    final key = args[0];

    if (_storage.remove(key) != null) {
      return NrdrResponse.success('Deleted "$key"');
    }

    return NrdrResponse.notFound(ErrorMessages.keyNotFound);
  }

  /// الحصول على الإحصائيات
  Map<String, dynamic> getStats() {
    return {
      'totalCommands': _commandCount,
      'publishCount': _publishCount,
      'fetchCount': _fetchCount,
      'itemsStored': _storage.length,
    };
  }

  /// مسح كل البيانات
  void clear() {
    _storage.clear();
  }

}