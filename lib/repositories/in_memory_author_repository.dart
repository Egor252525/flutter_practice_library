import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/author.dart';
import '../models/page_result.dart';
import 'author_repository.dart';

class InMemoryAuthorRepository implements AuthorRepository {
  List<Author> _authors = [];
  int _nextId = 1;
  static const String _storageKey = 'authors_data';

  InMemoryAuthorRepository() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _authors = jsonList.map((json) => Author.fromJson(json as Map<String, dynamic>)).toList();
        _nextId = _authors.isEmpty ? 1 : _authors.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
        return;
      }
    } catch (e) {
      // Если не удалось загрузить, то используются начальные данные
    }
    _initSeedData();
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _authors.map((author) => author.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
    }
  }

  void _initSeedData() {
    _authors = [
      Author(id: _nextId++, firstName: 'Лев', lastName: 'Толстой', country: 'Россия', birthYear: 1828, deathYear: 1910),
      Author(id: _nextId++, firstName: 'Фёдор', lastName: 'Достоевский', country: 'Россия', birthYear: 1821, deathYear: 1881),
      Author(id: _nextId++, firstName: 'Михаил', lastName: 'Булгаков', country: 'Россия', birthYear: 1891, deathYear: 1940),
      Author(id: _nextId++, firstName: 'Михаил', lastName: 'Шолохов', country: 'Россия', birthYear: 1905, deathYear: 1984),
      Author(id: _nextId++, firstName: 'Борис', lastName: 'Пастернак', country: 'Россия', birthYear: 1890, deathYear: 1960),
      Author(id: _nextId++, firstName: 'Александр', lastName: 'Пушкин', country: 'Россия', birthYear: 1799, deathYear: 1837),
      Author(id: _nextId++, firstName: 'Николай', lastName: 'Гоголь', country: 'Россия', birthYear: 1809, deathYear: 1852),
      Author(id: _nextId++, firstName: 'Михаил', lastName: 'Лермонтов', country: 'Россия', birthYear: 1814, deathYear: 1841),
    ];
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

  @override
  Future<Author> create(Author author) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newAuthor = Author(
      id: _nextId++,
      firstName: author.firstName,
      lastName: author.lastName,
      country: author.country,
      birthYear: author.birthYear,
      deathYear: author.deathYear,
      deletedAt: author.deletedAt,
    );
  
    _authors.add(newAuthor);
    await _saveToStorage();
    return newAuthor;
  }

  @override
  Future<Author> update(Author author) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _authors.indexWhere((a) => a.id == author.id);
    if (index == -1) throw StateError('Автор ${author.id} не найден');
    _authors[index] = author;
    await _saveToStorage();
    return author;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _authors.indexWhere((a) => a.id == id);
    if (index == -1) throw StateError('Автор $id не найден');
    _authors[index] = _authors[index].copyWith(deletedAt: DateTime.now());
    await _saveToStorage();
  }

  @override
  Future<void> hardDelete(int id) async {
    _authors.removeWhere((a) => a.id == id);
    await _saveToStorage();
  }

  @override
  Future<void> restore(int id) async {
    final index = _authors.indexWhere((a) => a.id == id);
    if (index == -1) throw StateError('Автор $id не найден');
    _authors[index] = _authors[index].copyWith(clearDeletedAt: true);
    await _saveToStorage();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final index = _authors.indexWhere((a) => a.id == id && !a.isDeleted);
      if (index != -1) {
        _authors[index] = _authors[index].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await _saveToStorage();
    return count;
  }
}