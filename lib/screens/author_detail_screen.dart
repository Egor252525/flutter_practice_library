import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/author_repository.dart';
import '../models/author.dart';
import '../widgets/loading_widget.dart';

class AuthorDetailScreen extends StatefulWidget {
  final int authorId;
  const AuthorDetailScreen({super.key, required this.authorId});

  @override
  State<AuthorDetailScreen> createState() => _AuthorDetailScreenState();
}

class _AuthorDetailScreenState extends State<AuthorDetailScreen> {
  Author? _author;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<AuthorRepository>();
      final author = await repo.findById(widget.authorId);
      setState(() {
        _author = author;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить автора: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали автора'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const LoadingWidget(message: 'Загрузка автора...')
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
                    onPressed: _loadAuthor,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          : _author == null
          ? const Center(child: Text('Автор не найден'))
          : _buildContent(context, _author!),
    );
  }

  Widget _buildContent(BuildContext context, Author author) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.fullName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              _buildInfoRow('Страна', author.country),
              _buildInfoRow('Год рождения', '${author.birthYear}'),
              _buildInfoRow('Год смерти', author.deathYear?.toString() ?? '—'),
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
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
