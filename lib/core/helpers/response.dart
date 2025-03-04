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
