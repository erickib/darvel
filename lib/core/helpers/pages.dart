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
// class PageAccessLogs {
//   final String method;
//   final String path;
//   final Map<String, String> headers;
//   final Map<String, String> queryParams;
//   final int statusCode;

//   PageAccessLogs({
//     required this.method,
//     required this.path,
//     required this.headers,
//     required this.queryParams,
//     required this.statusCode,
//   });

//   String render() {
//     String formattedHeaders = headers.entries
//         .map((entry) => '<tr><td>${entry.key}</td><td>${entry.value}</td></tr>')
//         .join();

//     String formattedQueryParams = queryParams.entries
//         .map((entry) => '<tr><td>${entry.key}</td><td>${entry.value}</td></tr>')
//         .join();

//     return '''
//     <!DOCTYPE html>
//     <html lang="en">
//     <head>
//         <title>Access Log</title>
//         <style>
//             body { font-family: Arial, sans-serif; padding: 20px; background: #f1f1f1; }
//             h1 { color: #333; }
//             table { width: 100%; border-collapse: collapse; margin-top: 20px; }
//             th, td { padding: 10px; border: 1px solid #ccc; text-align: left; }
//             th { background: #007BFF; color: white; }
//             .status { font-weight: bold; color: ${_getStatusColor(statusCode)}; }
//         </style>
//     </head>
//     <body>
//         <h1>Access Log</h1>
//         <p><strong>Method:</strong> $method</p>
//         <p><strong>Path:</strong> $path</p>
//         <p><strong>Status Code:</strong> <span class="status">$statusCode</span></p>

//         <h2>Headers</h2>
//         <table>
//             <tr><th>Key</th><th>Value</th></tr>
//             $formattedHeaders
//         </table>

//         <h2>Query Parameters</h2>
//         <table>
//             <tr><th>Key</th><th>Value</th></tr>
//             $formattedQueryParams
//         </table>
//     </body>
//     </html>
//     ''';
//   }

class PageAccessLogs {
  final List<Map<String, dynamic>> logs;

  PageAccessLogs({required this.logs});

  String render() {
    String logRows = logs.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> log = entry.value;

      return '''
        <tr onclick="toggleDetails('log_$index')">
          <td>${log['timestamp']}</td>
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
    return map.entries.map((e) => '${e.key}: ${e.value}').join('<br>');
  }

  // Helper function to color-code status codes
  String _getStatusColor(int code) {
    if (code >= 200 && code < 300) return 'green';
    if (code >= 400 && code < 500) return 'orange';
    if (code >= 500) return 'red';
    return 'black';
  }
}
