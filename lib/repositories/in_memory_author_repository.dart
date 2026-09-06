import '../models/author.dart';
import '../models/page_result.dart';
import 'author_repository.dart';

class InMemoryAuthorRepository implements AuthorRepository {
  final List<Author> _authors = [];
  int _nextId = 1;

  InMemoryAuthorRepository() {
    _initSeedData();
  }

  void _initSeedData() {
    final seedAuthors = [
      Author(id: _nextId++, firstName: 'Лев', lastName: 'Толстой', country: 'Россия', birthYear: 1828, deathYear: 1910),
      Author(id: _nextId++, firstName: 'Фёдор', lastName: 'Достоевский', country: 'Россия', birthYear: 1821, deathYear: 1881),
      Author(id: _nextId++, firstName: 'Михаил', lastName: 'Булгаков', country: 'Россия', birthYear: 1891, deathYear: 1940),
      Author(id: _nextId++, firstName: 'Михаил', lastName: 'Шолохов', country: 'Россия', birthYear: 1905, deathYear: 1984),
      Author(id: _nextId++, firstName: 'Борис', lastName: 'Пастернак', country: 'Россия', birthYear: 1890, deathYear: 1960),
      Author(id: _nextId++, firstName: 'Александр', lastName: 'Пушкин', country: 'Россия', birthYear: 1799, deathYear: 1837),
      Author(id: _nextId++, firstName: 'Николай', lastName: 'Гоголь', country: 'Россия', birthYear: 1809, deathYear: 1852),
      Author(id: _nextId++, firstName: 'Михаил', lastName: 'Лермонтов', country: 'Россия', birthYear: 1814, deathYear: 1841),
    ];
    _authors.addAll(seedAuthors);
  }

  @override
  Future<PageResult<Author>> findAll({int page = 1, int size = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final filtered = _authors.where((a) => !a.isDeleted).toList();
    final total = filtered.length;
    final from = (page - 1) * size;
    final to = (from + size) > total ? total : (from + size);
    final items = from >= total ? <Author>[] : filtered.sublist(from, to);
    
    return PageResult(
      items: items,
      page: page,
      size: size,
      total: total,
    );
  }

  @override
  Future<Author?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _authors.firstWhere((a) => a.id == id && !a.isDeleted);
    } catch (_) {
      return null;
    }
  }
}