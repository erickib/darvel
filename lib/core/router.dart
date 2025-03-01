import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../app/controllers/HomeController.dart';

class RouterConfig {
  final HomeController _homeController = HomeController();

  Handler get handler {
    final router = Router();

    router.get('/', _homeController.index);
    router.get('/about', _homeController.about);

    return router;
  }
}
