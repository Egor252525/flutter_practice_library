import '../models/author.dart';
import '../models/page_result.dart';

abstract interface class AuthorRepository {
  Future<PageResult<Author>> findAll({int page = 1, int size = 10});
  Future<Author?> findById(int id);
}