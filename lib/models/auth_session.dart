import 'app_user.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final AppUser user;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': user.toJson(),
  };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final access =
        (json['accessToken'] ?? json['token'] ?? json['access_token'] ?? '')
            as String;
    final refresh =
        (json['refreshToken'] ?? json['refresh_token'] ?? '') as String;

    final nested = json['user'];
    final AppUser user = (nested is Map<String, dynamic>)
        ? AppUser.fromJson(nested)
        : AppUser.fromJson(json);

    return AuthSession(accessToken: access, refreshToken: refresh, user: user);
  }
}
