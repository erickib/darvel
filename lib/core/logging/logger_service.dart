class LoggerService {
  static final List<Map<String, dynamic>> _accessLogs = [];
  static final List<Map<String, dynamic>> _errorLogs = [];

  static void logAccess({
    required String method,
    required String path,
    required Map<String, String> headers,
    required Map<String, String> queryParams,
    required int statusCode,
  }) {
    _accessLogs.add({
      'timestamp': DateTime.now().toIso8601String(),
      'method': method,
      'path': path,
      'headers': headers,
      'queryParams': queryParams,
      'statusCode': statusCode,
    });
  }

  static void logError(String error, [StackTrace? stackTrace]) {
    _errorLogs.add({
      'timestamp': DateTime.now().toIso8601String(),
      'error': error,
      'stackTrace': stackTrace?.toString(),
    });
  }

  static List<Map<String, dynamic>> get accessLogs => _accessLogs;
  static List<Map<String, dynamic>> get errorLogs => _errorLogs;

  static void clear() {
    _accessLogs.clear();
    _errorLogs.clear();
  }
}
