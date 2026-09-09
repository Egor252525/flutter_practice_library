import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';
import '../validators/validators.dart';

class BookFormScreen extends StatefulWidget {
  final Book? book;

  const BookFormScreen({super.key, this.book});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _isbnController = TextEditingController();
  final _yearController = TextEditingController();
  final _pagesController = TextEditingController();
  final _publisherIdController = TextEditingController();
  final _copiesTotalController = TextEditingController();
  final _copiesAvailableController = TextEditingController();
  
  List<int> _authorIds = [];
  List<int> _genreIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _isbnController.text = widget.book!.isbn;
      _yearController.text = widget.book!.year.toString();
      _pagesController.text = widget.book!.pages.toString();
      _publisherIdController.text = widget.book!.publisherId.toString();
      _copiesTotalController.text = widget.book!.copiesTotal.toString();
      _copiesAvailableController.text = widget.book!.copiesAvailable.toString();
      _authorIds = List.from(widget.book!.authorIds);
      _genreIds = List.from(widget.book!.genreIds);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _isbnController.dispose();
    _yearController.dispose();
    _pagesController.dispose();
    _publisherIdController.dispose();
    _copiesTotalController.dispose();
    _copiesAvailableController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final book = Book(
        id: widget.book?.id ?? 0,
        title: _titleController.text.trim(),
        isbn: _isbnController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        pages: int.parse(_pagesController.text.trim()),
        publisherId: int.parse(_publisherIdController.text.trim()),
        authorIds: _authorIds,
        genreIds: _genreIds,
        copiesTotal: int.parse(_copiesTotalController.text.trim()),
        copiesAvailable: int.parse(_copiesAvailableController.text.trim()),
        deletedAt: widget.book?.deletedAt,
      );

      final repo = context.read<BookRepository>();
      if (widget.book == null) {
        await repo.create(book);
      } else {
        await repo.update(book);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Создание книги' : 'Редактирование книги'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _save,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => Validators.string(
                        value: value,
                        fieldName: 'Название',
                        required: true,
                        minLength: 2,
                        maxLength: 200,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(
                        labelText: 'ISBN',
                        border: OutlineInputBorder(),
                        hintText: '978-5-17-118752-4',
                      ),
                      validator: Validators.isbn,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Год издания',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final intVal = int.tryParse(value?.trim() ?? '');
                        return Validators.number(
                          value: intVal,
                          fieldName: 'Год издания',
                          required: true,
                          min: 1000,
                          max: DateTime.now().year,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _pagesController,
                      decoration: const InputDecoration(
                        labelText: 'Количество страниц',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final intVal = int.tryParse(value?.trim() ?? '');
                        return Validators.number(
                          value: intVal,
                          fieldName: 'Количество страниц',
                          required: true,
                          positive: true,
                          max: 10000,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _publisherIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID издательства',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final intVal = int.tryParse(value?.trim() ?? '');
                        return Validators.number(
                          value: intVal,
                          fieldName: 'ID издательства',
                          required: true,
                          positive: true,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'ID авторов (через запятую)',
                        border: OutlineInputBorder(),
                        hintText: '1, 2, 3',
                      ),
                      initialValue: _authorIds.join(', '),
                      onChanged: (value) {
                        _authorIds = value
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .map(int.tryParse)
                            .whereType<int>()
                            .toList();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Укажите хотя бы одного автора';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'ID жанров (через запятую)',
                        border: OutlineInputBorder(),
                        hintText: '1, 2, 3',
                      ),
                      initialValue: _genreIds.join(', '),
                      onChanged: (value) {
                        _genreIds = value
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .map(int.tryParse)
                            .whereType<int>()
                            .toList();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Укажите хотя бы один жанр';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _copiesTotalController,
                      decoration: const InputDecoration(
                        labelText: 'Всего экземпляров',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final intVal = int.tryParse(value?.trim() ?? '');
                        return Validators.number(
                          value: intVal,
                          fieldName: 'Всего экземпляров',
                          required: true,
                          nonNegative: true,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _copiesAvailableController,
                      decoration: const InputDecoration(
                        labelText: 'Доступно экземпляров',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final intVal = int.tryParse(value?.trim() ?? '');
                        final total = int.tryParse(_copiesTotalController.text.trim()) ?? 0;
                        final error = Validators.number(
                          value: intVal,
                          fieldName: 'Доступно экземпляров',
                          required: true,
                          nonNegative: true,
                        );
                        if (error != null) return error;
                        if (intVal != null && intVal > total) {
                          return 'Доступно не может быть больше общего количества';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(widget.book == null ? 'Создать' : 'Сохранить'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
