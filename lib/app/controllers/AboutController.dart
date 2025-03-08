import 'dart:io';
import 'package:shelf/shelf.dart';
import '../../core/annotations/route.dart';
import 'package:mustache_template/mustache_template.dart';

class AboutController {
  @Route.get('/about-index')
  Response index(Request request) {
    final template =
        Template(File('lib/views/home.mustache').readAsStringSync());
    final output = template.renderString({
      'title': 'Welcome',
      'message': 'Welcome to AboutController -> IndexPage'
    });
    return Response.ok(output, headers: {'Content-Type': 'text/html'});
  }

  @Route.get('/about')
  Response about(Request request) {
    return Response.ok('This is the AboutController -> about page');
  }
}
