import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/book_list_notifier.dart';
import '../widgets/loading_widget.dart';
import 'book_detail_screen.dart';
import 'book_form_screen.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Книги'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookFormScreen()),
              );
              if (result == true && context.mounted) {
                context.read<BookListNotifier>().load();
              }
            },
          ),
        ],
      ),
      body: Consumer<BookListNotifier>(
        builder: (context, notifier, child) {
          switch (notifier.status) {
            case LoadStatus.loading:
              return const LoadingWidget(message: 'Загрузка книг...');
            case LoadStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      notifier.error ?? 'Произошла ошибка',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: notifier.load,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            case LoadStatus.success:
              if (notifier.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_books, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Нет книг', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                );
              }
              return _buildContent(context, notifier);
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BookListNotifier notifier) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifier.result.items.length,
            itemBuilder: (context, index) {
              final book = notifier.result.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    book.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ISBN: ${book.isbn}'),
                      Text('Год: ${book.year}, Страниц: ${book.pages}'),
                      Text(
                        'Доступно: ${book.copiesAvailable}/${book.copiesTotal}',
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookFormScreen(book: book),
                            ),
                          );
                          if (result == true && context.mounted) {
                            notifier.load();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(bookId: book.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _buildPagination(context, notifier),
      ],
    );
  }

  Widget _buildPagination(BuildContext context, BookListNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: notifier.page > 1 ? notifier.firstPage : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: notifier.result.hasPrevious
                ? notifier.previousPage
                : null,
          ),
          Text('${notifier.page} / ${notifier.result.totalPages}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: notifier.result.hasNext ? notifier.nextPage : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: notifier.page < notifier.result.totalPages
                ? notifier.lastPage
                : null,
          ),
          const SizedBox(width: 16),
          Text('Всего: ${notifier.result.total}'),
        ],
      ),
    );
  }
}
