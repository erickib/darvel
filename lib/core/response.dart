import 'package:shelf/shelf.dart';

class JsonResponse {
  static Response json(Map<String, dynamic> data, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: data.toString(),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
