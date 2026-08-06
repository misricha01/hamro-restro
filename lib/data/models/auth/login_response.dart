import 'logged_in_user.dart';

/// Maps the `data` object of the login endpoint's
/// `{status, message, data: {access_token, refresh_token, loggedInUser}}`
/// success envelope.
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final LoggedInUser user;

  const LoginResponse({required this.accessToken, required this.refreshToken, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: LoggedInUser.fromJson(json['loggedInUser'] as Map<String, dynamic>),
    );
  }
}
