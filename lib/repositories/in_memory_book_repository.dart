import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/page_result.dart';
import 'book_repository.dart';

class InMemoryBookRepository implements BookRepository {
  List<Book> _books = [];
  int _nextId = 1;
  static const String _storageKey = 'books_data';

  InMemoryBookRepository() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _books = jsonList
            .map((json) => Book.fromJson(json as Map<String, dynamic>))
            .toList();
        _nextId = _books.isEmpty
            ? 1
            : _books.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
        return;
      }
    } catch (e) {
      //
    }
    _initSeedData();
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _books.map((book) => book.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      //
    }
  }

  void _initSeedData() {
    _books = [
      Book(
        id: _nextId++,
        title: 'Война и мир',
        isbn: '978-5-17-118752-4',
        year: 1869,
        pages: 1300,
        publisherId: 1,
        authorIds: [1],
        genreIds: [1, 2],
        copiesTotal: 10,
        copiesAvailable: 7,
      ),
      Book(
        id: _nextId++,
        title: 'Преступление и наказание',
        isbn: '978-5-17-118753-1',
        year: 1866,
        pages: 672,
        publisherId: 1,
        authorIds: [2],
        genreIds: [1, 3],
        copiesTotal: 8,
        copiesAvailable: 5,
      ),
      Book(
        id: _nextId++,
        title: 'Анна Каренина',
        isbn: '978-5-17-118754-8',
        year: 1878,
        pages: 864,
        publisherId: 2,
        authorIds: [1],
        genreIds: [1, 2],
        copiesTotal: 6,
        copiesAvailable: 4,
      ),
      Book(
        id: _nextId++,
        title: 'Мастер и Маргарита',
        isbn: '978-5-17-118755-5',
        year: 1967,
        pages: 480,
        publisherId: 3,
        authorIds: [3],
        genreIds: [1, 4],
        copiesTotal: 12,
        copiesAvailable: 9,
      ),
      Book(
        id: _nextId++,
        title: 'Идиот',
        isbn: '978-5-17-118756-2',
        year: 1869,
        pages: 640,
        publisherId: 2,
        authorIds: [2],
        genreIds: [1, 3],
        copiesTotal: 5,
        copiesAvailable: 3,
      ),
      Book(
        id: _nextId++,
        title: 'Тихий Дон',
        isbn: '978-5-17-118757-9',
        year: 1940,
        pages: 1800,
        publisherId: 1,
        authorIds: [4],
        genreIds: [1, 2],
        copiesTotal: 7,
        copiesAvailable: 4,
      ),
      Book(
        id: _nextId++,
        title: 'Доктор Живаго',
        isbn: '978-5-17-118758-6',
        year: 1957,
        pages: 720,
        publisherId: 3,
        authorIds: [5],
        genreIds: [1, 2],
        copiesTotal: 4,
        copiesAvailable: 2,
      ),
      Book(
        id: _nextId++,
        title: 'Евгений Онегин',
        isbn: '978-5-17-118759-3',
        year: 1833,
        pages: 368,
        publisherId: 1,
        authorIds: [6],
        genreIds: [5, 2],
        copiesTotal: 9,
        copiesAvailable: 6,
      ),
      Book(
        id: _nextId++,
        title: 'Мертвые души',
        isbn: '978-5-17-118760-9',
        year: 1842,
        pages: 512,
        publisherId: 2,
        authorIds: [7],
        genreIds: [1, 6],
        copiesTotal: 6,
        copiesAvailable: 4,
      ),
      Book(
        id: _nextId++,
        title: 'Герой нашего времени',
        isbn: '978-5-17-118761-6',
        year: 1840,
        pages: 352,
        publisherId: 3,
        authorIds: [8],
        genreIds: [1, 3],
        copiesTotal: 8,
        copiesAvailable: 5,
      ),
      Book(
        id: _nextId++,
        title: 'Отцы и дети',
        isbn: '978-5-17-118762-3',
        year: 1862,
        pages: 400,
        publisherId: 1,
        authorIds: [9],
        genreIds: [1, 2],
        copiesTotal: 7,
        copiesAvailable: 4,
      ),
      Book(
        id: _nextId++,
        title: 'Обломов',
        isbn: '978-5-17-118763-0',
        year: 1859,
        pages: 576,
        publisherId: 2,
        authorIds: [10],
        genreIds: [1, 2],
        copiesTotal: 5,
        copiesAvailable: 3,
      ),
      Book(
        id: _nextId++,
        title: 'Братья Карамазовы',
        isbn: '978-5-17-118764-7',
        year: 1880,
        pages: 800,
        publisherId: 3,
        authorIds: [2],
        genreIds: [1, 3],
        copiesTotal: 6,
        copiesAvailable: 4,
      ),
      Book(
        id: _nextId++,
        title: 'Двенадцать стульев',
        isbn: '978-5-17-118765-4',
        year: 1928,
        pages: 448,
        publisherId: 1,
        authorIds: [11],
        genreIds: [7, 1],
        copiesTotal: 10,
        copiesAvailable: 7,
      ),
      Book(
        id: _nextId++,
        title: 'Золотой теленок',
        isbn: '978-5-17-118766-1',
        year: 1931,
        pages: 480,
        publisherId: 2,
        authorIds: [11],
        genreIds: [7, 1],
        copiesTotal: 8,
        copiesAvailable: 5,
      ),
      Book(
        id: _nextId++,
        title: 'Пиковая дама',
        isbn: '978-5-17-118767-8',
        year: 1834,
        pages: 160,
        publisherId: 3,
        authorIds: [6],
        genreIds: [3, 1],
        copiesTotal: 12,
        copiesAvailable: 9,
      ),
      Book(
        id: _nextId++,
        title: 'Нос',
        isbn: '978-5-17-118768-5',
        year: 1836,
        pages: 96,
        publisherId: 1,
        authorIds: [7],
        genreIds: [8, 1],
        copiesTotal: 6,
        copiesAvailable: 4,
      ),
      Book(
        id: _nextId++,
        title: 'Шинель',
        isbn: '978-5-17-118769-2',
        year: 1842,
        pages: 120,
        publisherId: 2,
        authorIds: [7],
        genreIds: [1, 3],
        copiesTotal: 7,
        copiesAvailable: 5,
      ),
      Book(
        id: _nextId++,
        title: 'Капитанская дочка',
        isbn: '978-5-17-118770-8',
        year: 1836,
        pages: 320,
        publisherId: 3,
        authorIds: [6],
        genreIds: [2, 1],
        copiesTotal: 8,
        copiesAvailable: 6,
      ),
      Book(
        id: _nextId++,
        title: 'Бесы',
        isbn: '978-5-17-118771-5',
        year: 1872,
        pages: 768,
        publisherId: 1,
        authorIds: [2],
        genreIds: [1, 3],
        copiesTotal: 5,
        copiesAvailable: 3,
      ),
    ];
  }

  @override
  Future<PageResult<Book>> findAll({int page = 1, int size = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filtered = _books.where((b) => !b.isDeleted).toList();
    final total = filtered.length;
    final from = (page - 1) * size;
    final to = (from + size) > total ? total : (from + size);
    final items = from >= total ? <Book>[] : filtered.sublist(from, to);

    return PageResult(items: items, page: page, size: size, total: total);
  }

  @override
  Future<Book?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _books.firstWhere((b) => b.id == id && !b.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Book> create(Book book) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newBook = Book(
      id: _nextId++,
      title: book.title,
      isbn: book.isbn,
      year: book.year,
      pages: book.pages,
      publisherId: book.publisherId,
      authorIds: book.authorIds,
      genreIds: book.genreIds,
      copiesTotal: book.copiesTotal,
      copiesAvailable: book.copiesAvailable,
      deletedAt: book.deletedAt,
    );

    _books.add(newBook);
    await _saveToStorage();
    return newBook;
  }

  @override
  Future<Book> update(Book book) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index == -1) throw StateError('Книга ${book.id} не найдена');
    _books[index] = book;
    await _saveToStorage();
    return book;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _books.indexWhere((b) => b.id == id);
    if (index == -1) throw StateError('Книга $id не найдена');
    _books[index] = _books[index].copyWith(deletedAt: DateTime.now());
    await _saveToStorage();
  }

  @override
  Future<void> hardDelete(int id) async {
    _books.removeWhere((b) => b.id == id);
    await _saveToStorage();
  }

  @override
  Future<void> restore(int id) async {
    final index = _books.indexWhere((b) => b.id == id);
    if (index == -1) throw StateError('Книга $id не найдена');
    _books[index] = _books[index].copyWith(clearDeletedAt: true);
    await _saveToStorage();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final index = _books.indexWhere((b) => b.id == id && !b.isDeleted);
      if (index != -1) {
        _books[index] = _books[index].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await _saveToStorage();
    return count;
  }
}
