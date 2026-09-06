import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/book_repository.dart';
import '../models/book.dart';
import '../widgets/loading_widget.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Book? _book;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<BookRepository>();
      final book = await repo.findById(widget.bookId);
      setState(() {
        _book = book;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить книгу: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали книги'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const LoadingWidget(message: 'Загрузка книги...')
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBook,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _book == null
                  ? const Center(child: Text('Книга не найдена'))
                  : _buildContent(context, _book!),
    );
  }

  Widget _buildContent(BuildContext context, Book book) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
              const Divider(),
              _buildInfoRow('ISBN', book.isbn),
              _buildInfoRow('Год издания', '${book.year}'),
              _buildInfoRow('Количество страниц', '${book.pages}'),
              _buildInfoRow('Всего экземпляров', '${book.copiesTotal}'),
              _buildInfoRow('Доступно', '${book.copiesAvailable}'),
              _buildInfoRow('ID издательства', '${book.publisherId}'),
              _buildInfoRow('ID авторов', book.authorIds.join(', ')),
              _buildInfoRow('ID жанров', book.genreIds.join(', ')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}