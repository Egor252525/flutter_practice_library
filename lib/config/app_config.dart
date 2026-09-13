class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  /// Таймаут соединения. Можно переопределить через --dart-define
  static const int connectTimeoutMs = int.fromEnvironment(
    'API_CONNECT_TIMEOUT',
    defaultValue: 5000,
  );

  /// Таймаут ответа (мс)
  static const int receiveTimeoutMs = int.fromEnvironment(
    'API_RECEIVE_TIMEOUT',
    defaultValue: 10000,
  );

  /// Таймаут отправки (мс)
  static const int sendTimeoutMs = int.fromEnvironment(
    'API_SEND_TIMEOUT',
    defaultValue: 10000,
  );
}
