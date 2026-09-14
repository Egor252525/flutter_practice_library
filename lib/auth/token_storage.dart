import 'dart:convert';
import 'package:flutter_practice_book/models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_session.dart';

class TokenStorage {
  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kUser = 'auth_user';

  Future<void> save(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, session.accessToken);
    await prefs.setString(_kRefresh, session.refreshToken);
    await prefs.setString(_kUser, json.encode(session.user.toJson()));
  }

  Future<AuthSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_kAccess);
    if (access == null || access.isEmpty) return null;

    final refresh = prefs.getString(_kRefresh) ?? '';
    final userRaw = prefs.getString(_kUser);

    AppUser user;
    if (userRaw != null && userRaw.isNotEmpty) {
      try {
        user = AppUser.fromJson(json.decode(userRaw) as Map<String, dynamic>);
      } catch (_) {
        user = const AppUser(id: 0, username: '', email: '', fullName: '');
      }
    } else {
      user = const AppUser(id: 0, username: '', email: '', fullName: '');
    }

    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      user: user,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
    await prefs.remove(_kUser);
  }
}