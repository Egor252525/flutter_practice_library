import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'network/dio_client.dart';
import 'repositories/book_repository.dart';
import 'repositories/author_repository.dart';
import 'repositories/api_book_repository.dart';
import 'repositories/api_author_repository.dart';
import 'state/book_list_notifier.dart';
import 'state/author_list_notifier.dart';
import 'screens/book_list_screen.dart';
import 'screens/author_list_screen.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DioClient>(create: (_) => DioClient()),

        // Репозитории обращаются к серверу, а не к памяти
        Provider<BookRepository>(
          create: (ctx) => ApiBookRepository(ctx.read<DioClient>()),
        ),
        Provider<AuthorRepository>(
          create: (ctx) => ApiAuthorRepository(ctx.read<DioClient>()),
        ),

        ChangeNotifierProvider(
          create: (ctx) => BookListNotifier(ctx.read<BookRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuthorListNotifier(ctx.read<AuthorRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Библиотечная система',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Библиотека'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.library_books), text: 'Книги'),
              Tab(icon: Icon(Icons.people), text: 'Авторы'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BookListScreen(),
            AuthorListScreen(),
          ],
        ),
      ),
    );
  }
}