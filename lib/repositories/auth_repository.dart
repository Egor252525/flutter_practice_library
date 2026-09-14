import '../models/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login(String username, String password);
  Future<AuthSession> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  });
}