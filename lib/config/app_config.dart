class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  static const int connectTimeoutMs = int.fromEnvironment(
    'API_CONNECT_TIMEOUT',
    defaultValue: 5000,
  );
  static const int receiveTimeoutMs = int.fromEnvironment(
    'API_RECEIVE_TIMEOUT',
    defaultValue: 10000,
  );
  static const int sendTimeoutMs = int.fromEnvironment(
    'API_SEND_TIMEOUT',
    defaultValue: 10000,
  );

  static const String apiFail = String.fromEnvironment(
    'API_FAIL',
    defaultValue: '',
  );
  static const String apiDelay = String.fromEnvironment(
    'API_DELAY',
    defaultValue: '',
  );
}
