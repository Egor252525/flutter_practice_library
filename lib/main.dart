import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/token_storage.dart';
import 'network/dio_client.dart';
import 'repositories/api_auth_repository.dart';
import 'repositories/api_book_repository.dart';
import 'repositories/api_author_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/author_repository.dart';
import 'state/auth_notifier.dart';
import 'state/book_list_notifier.dart';
import 'state/author_list_notifier.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LibraryApp());
}

class LibraryApp extends StatefulWidget {
  const LibraryApp({super.key});

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  late final DioClient _dioClient;
  late final AuthNotifier _auth;

  @override
  void initState() {
    super.initState();

    _dioClient = DioClient();

    _auth = AuthNotifier(
      ApiAuthRepository(_dioClient),
      TokenStorage(),
    );

    // Сначала провайдер, потом restore
    _dioClient.tokenProvider = () => _auth.accessToken;
    _dioClient.onUnauthorized = _auth.onUnauthorized;

    _auth.restore();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DioClient>.value(value: _dioClient),
        Provider<AuthRepository>.value(value: ApiAuthRepository(_dioClient)),
        Provider<BookRepository>.value(value: ApiBookRepository(_dioClient)),
        Provider<AuthorRepository>.value(
            value: ApiAuthorRepository(_dioClient)),
        ChangeNotifierProvider<AuthNotifier>.value(value: _auth),
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
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.authenticated:
        return const MainScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
