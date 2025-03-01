import 'package:shelf/shelf.dart';

class HomeController {
  Response index(Request request) {
    return Response.ok('Welcome to LaraDart!');
  }

  Response about(Request request) {
    return Response.ok('About Us Page');
  }
}
