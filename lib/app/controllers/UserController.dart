import 'package:darvel/core/annotations/route.dart';
import 'package:shelf/shelf.dart';
//import 'package:shelf_router/shelf_router.dart';

class UserController {
  @Route.get('/users')
  Response getUsers(Request request) {
    return Response.ok('All users');
  }

  @Route.get('/user/<id>')
  Response getUser(Request request, String id) {
    print("UserController:> $id");
    return Response.ok('User $id');
  }
}
