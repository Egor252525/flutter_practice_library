import 'package:dio/dio.dart';
import '../models/book.dart';
import '../models/page_result.dart';
import '../network/dio_client.dart';
import 'book_repository.dart';

class ApiBookRepository implements BookRepository {
  final Dio _dio;

  ApiBookRepository(DioClient client) : _dio = client.dio;

  @override
  Future<PageResult<Book>> findAll({int page = 1, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/books',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? [])
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();

      return PageResult(
        items: items,
        page: data['page'] as int? ?? page,
        size: data['size'] as int? ?? size,
        total: data['total'] as int? ?? items.length,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Book?> findById(int id) async {
    try {
      final response = await _dio.get('/books/$id');
      if (response.statusCode == 404) return null;
      return Book.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapError(e);
    }
  }

  @override
  Future<Book> create(Book book) async {
    try {
      final response = await _dio.post('/books', data: book.toJson());
      return Book.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Book> update(Book book) async {
    try {
      final response = await _dio.put('/books/${book.id}', data: book.toJson());
      return Book.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> softDelete(int id) async {
    try {
      await _dio.delete('/books/$id');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    try {
      await _dio.delete('/books/$id', queryParameters: {'hard': true});
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> restore(int id) async {
    try {
      await _dio.post('/books/$id/restore');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    try {
      final response = await _dio.post(
        '/books/bulk-delete',
        data: {'ids': ids},
      );
      return response.data['deleted'] as int? ?? 0;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // Преобразует техническую ошибку Dio в понятный текст для пользователя
  Exception _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Превышено время ожидания ответа от сервера');
      case DioExceptionType.connectionError:
        return Exception('Не удалось подключиться к серверу. Проверьте соединение');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final message = e.response?.data is Map
            ? (e.response!.data['message'] as String? ?? 'Ошибка сервера')
            : 'Ошибка сервера';
        return Exception('Сервер вернул ошибку $code: $message');
      case DioExceptionType.cancel:
        return Exception('Запрос отменён');
      default:
        return Exception('Неизвестная ошибка: ${e.message}');
    }
  }
}
