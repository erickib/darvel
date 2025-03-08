import 'dart:ffi';

import 'package:intl/intl.dart';

/// ### Internal Server Error Page
/// #### Renders a raw string html page for the server internal exceptions
/// ##### Callable from anywhere of the framework to be used as the html body
/// ##### in a response, eg.:
///     String errorHtml = PageInternalServerError(
///       error: e.toString(),
///       stack: stack.toString(),
///       ).render();
///     return Response.internalServerError(
///         body: errorHtml,
///         headers: {'Content-Type': 'text/html'},
///       );
class PageInternalServerError {
  final String error;
  final String stack;

  PageInternalServerError({required this.error, required this.stack});

  String render() {
    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>Internal Server Error</title>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; background: #f8d7da; }
            h1 { color: #721c24; }
            pre { background: #f1f1f1; padding: 10px; border-radius: 5px; }
        </style>
    </head>
    <body>
        <h1>Internal Server Error</h1>
        <p><strong>Error:</strong> $error</p>
        <pre>$stack</pre>
    </body>
    </html>
    ''';
  }
}

/// ### Access Logs Page
/// #### renders a raw string html page for the server access logs
class PageAccessLogs {
  final List<Map<String, dynamic>> logs;

  PageAccessLogs({required this.logs});

  String render() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd H:MM:ss');
    String logRows = logs.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> log = entry.value;
      final DateTime fromTimeStamp = DateTime.parse(log['timestamp']);
      final String formatted = formatter.format(fromTimeStamp);

      return '''
        <tr onclick="toggleDetails('log_$index')">
          <td>${formatted}</td>
          <td>Method: <strong>${log['method']}</strong></td>
          <td>Path: <strong>${log['path']}</strong></td>
          <td class="status"><strong><span class="status" style="color:${_getStatusColor(log['statusCode'])};">${log['statusCode']}</span></strong></td>
        </tr>
        <tr id="log_$index" class="details">
          <td colspan="4">
            <strong>Headers:</strong> ${_formatMap(log['headers'])}<br>
            <strong>Query Params:</strong> ${_formatMap(log['queryParams'])}
          </td>
        </tr>
      ''';
    }).join();

    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>Access Logs</title>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; background: #f1f1f1; }
            h1 { color: #333; }
            table { width: 100%; border-collapse: collapse; margin-top: 20px; }
            th, td { padding: 10px; border: 1px solid #ccc; text-align: left; }
            th { background: #007BFF; color: white; }
            .status { font-weight: bold; color: black; }
            .details { display: none; background: #fafafa; }
            .details td { padding: 15px; font-size: 14px; }
        </style>
        <script>
            function toggleDetails(id) {
                var row = document.getElementById(id);
                row.style.display = row.style.display === 'table-row' ? 'none' : 'table-row';
            }
        </script>
    </head>
    <body>
        <h1>Access Logs</h1>
        <table>
            <tr>
                <th>Timestamp</th>
                <th>Method</th>
                <th>Path</th>
                <th>Status</th>
            </tr>
            $logRows
        </table>
    </body>
    </html>
    ''';
  }

  String _formatMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return 'None';
    return map.entries.map((e) => '''
      <div style="border-bottom: black 1px solid;font-size: small;"><span style="display: inline-block; width: 150px;">${e.key}:</span> ${e.value}</div>
    ''').join('');
  }

  // Helper function to color-code status codes
  String _getStatusColor(int code) {
    if (code >= 200 && code < 300) return 'green';
    if (code >= 400 && code < 500) return 'orange';
    if (code >= 500) return 'red';
    return 'black';
  }
}

/// ### Error Logs Page
/// #### renders a raw string html page for the server error logs
class PageErrorLogs {
  final List<Map<String, dynamic>> logs;

  PageErrorLogs({required this.logs});

  String render() {
    String logRows = logs.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> log = entry.value;

      return '''
        <tr onclick="toggleDetails('log_$index')">
          <td>${log['timestamp']}</td>
          <td>${log['error']}</td>
          <td>${log['statusCode']}</td>
        </tr>
        <tr id="log_$index" class="details">
          <td colspan="3">
            <strong>Stack Trace:</strong><br>
            <pre>${log['stack'] ?? 'No stack trace available'}</pre>
          </td>
        </tr>
      ''';
    }).join();

    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>Error Logs</title>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; background: #f1f1f1; }
            h1 { color: #d9534f; }
            table { width: 100%; border-collapse: collapse; margin-top: 20px; }
            th, td { padding: 10px; border: 1px solid #ccc; text-align: left; }
            th { background: #d9534f; color: white; }
            .details { display: none; background: #fafafa; }
            .details td { padding: 15px; font-size: 14px; }
            pre { white-space: pre-wrap; word-wrap: break-word; font-size: 14px; }
        </style>
        <script>
            function toggleDetails(id) {
                var row = document.getElementById(id);
                row.style.display = row.style.display === 'table-row' ? 'none' : 'table-row';
            }
        </script>
    </head>
    <body>
        <h1>Error Logs</h1>
        <table>
            <tr>
                <th>Timestamp</th>
                <th>Error</th>
                <th>Status</th>
            </tr>
            $logRows
        </table>
    </body>
    </html>
    ''';
  }
}
