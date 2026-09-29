import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../core/storage/auth_storage.dart';
import '../data/models/auth/logged_in_user.dart';
import '../data/models/auth/login_request.dart';
import '../data/models/auth/register_request.dart';
import '../data/repositories/auth_repository.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

/// ViewModel for the auth flow: owns login state, talks to
/// [AuthRepository] for the network call and [AuthStorage] for session
/// persistence, and exposes plain state for [LoginScreen] / the app gate to
/// react to.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final AuthStorage _storage;

  AuthProvider({AuthRepository? repository, AuthStorage? storage})
      : _repository = repository ?? AuthRepositoryImpl(),
        _storage = storage ?? AuthStorage();

  AuthStatus status = AuthStatus.checking;
  bool isLoggingIn = false;
  bool isRegistering = false;
  bool isLoggingOut = false;
  String? errorMessage;
  LoggedInUser? currentUser;

  /// Called once on app startup to restore a previous session, if any.
  Future<void> tryAutoLogin() async {
    final token = await _storage.readAccessToken();
    final userJson = await _storage.readUserJson();

    if (token != null && token.isNotEmpty && userJson != null) {
      currentUser = LoggedInUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    isLoggingIn = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.login(LoginRequest(email: email, password: password));
      await _storage.saveSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        userJson: jsonEncode(result.user.toJson()),
      );
      currentUser = result.user;
      status = AuthStatus.authenticated;
      isLoggingIn = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoggingIn = false;
      notifyListeners();
      return false;
    }
  }

  /// Register + auto-login, per Swagger's summary for this endpoint.
  /// NOTE: `RegisterRequest`/`CreateUserDto` has no `restaurantId` -- a
  /// successful call establishes a session but leaves the new account with
  /// no restaurant attached. There is no follow-up flow wired for that yet
  /// (e.g. "create your restaurant"), so the app gate will land wherever it
  /// normally does for an authenticated-but-restaurant-less user -- this
  /// hasn't been tested live.
  Future<bool> register({
    required String fullname,
    required String email,
    required String password,
    required String position,
  }) async {
    isRegistering = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.register(
        RegisterRequest(fullname: fullname, email: email, password: password, position: position),
      );
      await _storage.saveSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        userJson: jsonEncode(result.user.toJson()),
      );
      currentUser = result.user;
      status = AuthStatus.authenticated;
      isRegistering = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isRegistering = false;
      notifyListeners();
      return false;
    }
  }

  /// Logs out via the server (best-effort — a failed network call still
  /// clears the local session) and returns to the login screen.
  Future<void> logout() async {
    isLoggingOut = true;
    notifyListeners();

    try {
      await _repository.logout();
    } on ApiException catch (_) {
      // Server call failed (offline, already-expired token, etc.) — the
      // local session is cleared below regardless, so the user is still
      // signed out on this device.
    }

    isLoggingOut = false;
    await _clearSession();
  }

  /// Used when a background refresh fails (see [DioClient.onUnauthenticated])
  /// — the session is already invalid server-side, so no logout call is made.
  Future<void> forceLogout() => _clearSession();

  Future<void> _clearSession() async {
    await _storage.clear();
    currentUser = null;
    errorMessage = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}