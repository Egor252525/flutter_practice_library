import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/page_result.dart';
import '../repositories/book_repository.dart';

enum LoadStatus { idle, loading, success, error }

class BookListNotifier extends ChangeNotifier {
  final BookRepository _repository;
  
  int _page = 1;
  final int _size = 10;
  PageResult<Book> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;

  BookListNotifier(this._repository) {
    load();
  }

  PageResult<Book> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  int get page => _page;
  int get size => _size;
  bool get isEmpty => _status == LoadStatus.success && _result.items.isEmpty;
  bool get hasData => _status == LoadStatus.success && _result.items.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.findAll(page: _page, size: _size);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список книг: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void goToPage(int page) {
    if (page < 1 || page > _result.totalPages) return;
    _page = page;
    load();
  }

  void nextPage() {
    if (_result.hasNext) {
      _page++;
      load();
    }
  }

  void previousPage() {
    if (_result.hasPrevious) {
      _page--;
      load();
    }
  }

  void firstPage() {
    if (_page != 1) {
      _page = 1;
      load();
    }
  }

  void lastPage() {
    if (_page != _result.totalPages) {
      _page = _result.totalPages;
      load();
    }
  }

  void reset() {
    _page = 1;
    _result = PageResult.empty();
    _status = LoadStatus.idle;
    _error = null;
    load(); 
  }
}
