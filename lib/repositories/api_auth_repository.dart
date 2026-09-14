import 'package:dio/dio.dart';
import '../models/auth_session.dart';
import '../network/dio_client.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final Dio _dio;
  ApiAuthRepository(DioClient client) : _dio = client.dio;

  @override
  Future<AuthSession> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      return _parseSession(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AuthSession> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
      });
      return _parseSession(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AuthSession _parseSession(Response response) {
    final data = response.data;
    if (data == null) {
      throw Exception('Сервер вернул пустой ответ');
    }
    if (data is! Map<String, dynamic>) {
      throw Exception('Сервер вернул некорректный ответ');
    }
    try {
      final session = AuthSession.fromJson(data);
      if (session.accessToken.isEmpty) {
        throw Exception('Сервер не вернул токен доступа');
      }
      return session;
    } catch (e) {
      throw Exception('Не удалось разобрать ответ сервера: $e');
    }
  }

  Exception _mapError(DioException e) {
    if (e.response != null) {
      final code = e.response!.statusCode;
      final data = e.response!.data;
      String? serverMsg;
      if (data is Map && data['message'] is String) {
        serverMsg = data['message'] as String;
      }
      return Exception('$code ${serverMsg ?? _defaultMessage(code)}');
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Превышено время ожидания ответа от сервера');
      case DioExceptionType.connectionError:
        return Exception(
            'Не удалось подключиться к серверу. Проверьте соединение');
      case DioExceptionType.cancel:
        return Exception('Запрос отменён');
      default:
        return Exception(e.message ?? 'Неизвестная ошибка');
    }
  }

  String _defaultMessage(int? code) {
    switch (code) {
      case 401:
        return 'Неверный логин или пароль';
      case 403:
        return 'Недостаточно прав';
      case 409:
        return 'Пользователь с таким логином уже существует';
      case 500:
        return 'Внутренняя ошибка сервера';
      default:
        return 'Ошибка сервера';
    }
  }
}