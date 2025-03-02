import 'dart:io';
import 'package:shelf/shelf.dart';
import '../../core/annotations.dart';
import 'package:mustache_template/mustache_template.dart';
import '../services/UserService.dart';

class HomeController {
  //final UserService userService;

  HomeController();

  @Route.get('/')
  Response index(Request request, Map<String, dynamic> services) {
    final template =
        Template(File('lib/views/home.mustache').readAsStringSync());
    final output = template
        .renderString({'title': 'Welcome', 'message': 'Welcome to LaraDart!'});
    return Response.ok(output, headers: {'Content-Type': 'text/html'});
  }

  @Route.get('/home-about')
  Response about(Request request, Map<String, dynamic> services) {
    final template =
        Template(File('lib/views/about.mustache').readAsStringSync());
    final output = template.renderString({
      'title': 'About Us',
      'content': 'This is the HomeController -> about page.'
    });
    return Response.ok(output, headers: {'Content-Type': 'text/html'});
  }
}
