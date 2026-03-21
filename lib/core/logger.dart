import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String message) {
    if (kDebugMode) {
      _printLog('DEBUG', message);
    }
  }

  static void i(String message) {
    _printLog('INFO', message);
  }

  static void w(String message) {
    _printLog('WARNING', message);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _printLog('ERROR', message);
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  static void _printLog(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [$level] $message');
  }
}
