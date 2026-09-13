import 'package:dio/dio.dart';
import '../models/author.dart';
import '../models/page_result.dart';
import '../network/dio_client.dart';
import 'author_repository.dart';

class ApiAuthorRepository implements AuthorRepository {
  final Dio _dio;

  ApiAuthorRepository(DioClient client) : _dio = client.dio;

  @override
  Future<PageResult<Author>> findAll({int page = 1, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/authors',
        queryParameters: {'page': page, 'size': size},
      );

      final data = response.data as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? [])
          .map((json) => Author.fromJson(json as Map<String, dynamic>))
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
  Future<Author?> findById(int id) async {
    try {
      final response = await _dio.get('/authors/$id');
      if (response.statusCode == 404) return null;
      return Author.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapError(e);
    }
  }

  @override
  Future<Author> create(Author author) async {
    try {
      final response = await _dio.post('/authors', data: author.toJson());
      return Author.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Author> update(Author author) async {
    try {
      final response = await _dio.put('/authors/${author.id}', data: author.toJson());
      return Author.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> softDelete(int id) async {
    try {
      await _dio.delete('/authors/$id');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    try {
      await _dio.delete('/authors/$id', queryParameters: {'hard': true});
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> restore(int id) async {
    try {
      await _dio.post('/authors/$id/restore');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    try {
      final response = await _dio.post(
        '/authors/bulk-delete',
        data: {'ids': ids},
      );
      return response.data['deleted'] as int? ?? 0;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

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