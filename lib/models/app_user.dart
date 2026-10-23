import 'package:my_app/models/user_role.dart';

class AppUser {
  const AppUser({
    required this.username,
    required this.password,
    required this.name,
    required this.role,
  });

  final String username;
  final String password;
  final String name;
  final UserRole role;
}
