import 'package:shelf/shelf.dart';

class RequestWrapper {
  final Request request;

  RequestWrapper(this.request);

  String? query(String key) => request.url.queryParameters[key];
}
