import '../models/book.dart';
import '../models/page_result.dart';

abstract interface class BookRepository {
  Future<PageResult<Book>> findAll({int page = 1, int size = 10});
  Future<Book?> findById(int id);
}