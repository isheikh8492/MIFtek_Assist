class User {
  static int _nextId = 0;
  int id;
  String firstName;
  String lastName;
  String email;
  String password;

  User({
  required this.firstName,
  required this.lastName,
  required this.email,
  required this.password
  }) : id = _nextId++;
}