/// Maps to `CreateUserDto` for `POST /api/auth/register`.
/// `fullname`, `email`, `password`, `position` are required by Swagger;
/// `role` is optional there but the app always sends `'user'` since this
/// form is for a brand-new account, not a privileged one.
class RegisterRequest {
  final String fullname;
  final String email;
  final String password;
  final String position;
  final String role;

  const RegisterRequest({
    required this.fullname,
    required this.email,
    required this.password,
    required this.position,
    this.role = 'user',
  });

  Map<String, dynamic> toJson() => {
    'fullname': fullname,
    'email': email,
    'password': password,
    'position': position,
    'role': role,
  };
}