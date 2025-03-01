import '../models/User.dart';

class UserService {
  List<User> getAllUsers() {
    return User.sampleUsers;
  }
}
