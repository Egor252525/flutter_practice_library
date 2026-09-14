import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/auth_session.dart';
import '../auth/token_storage.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repository;
  final TokenStorage _storage;

  AuthStatus _status = AuthStatus.unknown;
  AuthSession? _session;
  String? _lastError;

  AuthNotifier(this._repository, this._storage);

  AuthStatus get status => _status;
  AppUser? get user => _session?.user;
  String? get lastError => _lastError;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  String? get accessToken {
    final t = _session?.accessToken;
    return (t != null && t.isNotEmpty) ? t : null;
  }

  Future<void> restore() async {
    try {
      final saved = await _storage.read();
      if (saved == null) {
        _status = AuthStatus.unauthenticated;
      } else {
        _session = saved;
        _status = AuthStatus.authenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _lastError = null;
    try {
      final session = await _repository.login(username, password);
      _session = session;
      _status = AuthStatus.authenticated;
      await _storage.save(session);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = _friendlyError(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    _lastError = null;
    try {
      final session = await _repository.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      _session = session;
      _status = AuthStatus.authenticated;
      await _storage.save(session);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    _session = null;
    _status = AuthStatus.unauthenticated;
    _lastError = null;
    notifyListeners();
  }

  Future<void> onUnauthorized() async {
    await logout();
  }

  String _friendlyError(Object e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    if (msg.contains('401') || msg.toLowerCase().contains('unauthorized')) {
      return 'Неверный логин или пароль';
    }
    if (msg.contains('409')) {
      return 'Пользователь с таким логином уже существует';
    }
    return msg;
  }
}