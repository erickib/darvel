class User {
  final int id;
  final String name;
  final String email;

  User(this.id, this.name, this.email);

  static List<User> sampleUsers = [
    User(1, 'John Doe', 'john@example.com'),
    User(2, 'Jane Doe', 'jane@example.com'),
  ];
}
