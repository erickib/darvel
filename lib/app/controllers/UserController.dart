import 'package:darvel/app/models/User.dart';
import 'package:darvel/core/annotations/route.dart';
import 'package:shelf/shelf.dart';
import 'package:darvel/core/orm/entity_manager.dart';
import 'package:mysql1/mysql1.dart';

class UserController {
  @Route.get('/users')
  Future<Response> getUsers(Request request) async {
    var settings = new ConnectionSettings(
        host: '192.168.18.13',
        port: 3306,
        user: 'laravel',
        password: 'admin',
        db: 'laravel');
    var con = await MySqlConnection.connect(settings);
    print(con);
    final em = new EntityManager(con);
    final users = '';
    //await em.findAll<User>();
    con.close();
    return Response.ok(users);
  }

  @Route.get('/user/<id>')
  Response getUser(Request request, String id) {
    print("UserController:> $id");
    return Response.ok('User $id');
  }
}
