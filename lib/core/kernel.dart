import 'package:get_it/get_it.dart';
import '../app/services/UserService.dart';

class Kernel {
  static final GetIt _locator = GetIt.instance;

  static void initialize() {
    _locator.registerSingleton<UserService>(UserService());
  }

  static T resolve<T>() => _locator<T>();
}
