import 'dart:convert';
import 'package:shelf/shelf.dart';

Response responseAsJson(Map<String, dynamic> data, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );
}

Response responseAsHtml(String html, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: html,
    headers: {'Content-Type': 'text/html'},
  );
}

Response responseAsError(
    {required String error, String? stack, int statusCode = 500}) {
  String html = '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
    </head>
    <body>
      <h1>$error<h1><br />
      <pre>$stack<pre><br />
        
    </body>
    </html>
  ''';
  return Response(
    statusCode,
    body: html,
    headers: {'Content-Type': 'text/html'},
  );
}
