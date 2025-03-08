import 'dart:io';
import 'package:shelf/shelf.dart';
import '../../core/annotations/route.dart';
import 'package:mustache_template/mustache_template.dart';
import '../../core/views/view_renderer.dart';
import '../../core/helpers/response.dart';

class HomeController {
  //final UserService userService;

  HomeController();

  @Route.get('/')
  Response index(Request request) {
    final html = ViewRenderer.render(
        'home', {'name': 'John Doe', 'title': 'Home Page'},
        layout: 'layout');

    return responseAsHtml(html);
  }

  @Route.get('/home-about')
  Response about(Request request) {
    final template =
        Template(File('lib/views/about.mustache').readAsStringSync());
    final output = template.renderString({
      'title': 'About Us',
      'content': 'This is the HomeController -> about page.'
    });
    return Response.ok(output, headers: {'Content-Type': 'text/html'});
  }

  @Route.get('/posts/<postId>/comments/<commentId>')
  Response getComment(Request request, String postId, String commentId) {
    return Response.ok('Post: $postId, Comment: $commentId');
  }
}
