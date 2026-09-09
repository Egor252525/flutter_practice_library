import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/author.dart';
import '../repositories/author_repository.dart';
import '../validators/validators.dart';

class AuthorFormScreen extends StatefulWidget {
  final Author? author;

  const AuthorFormScreen({super.key, this.author});

  @override
  State<AuthorFormScreen> createState() => _AuthorFormScreenState();
}

class _AuthorFormScreenState extends State<AuthorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _deathYearController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.author != null) {
      _firstNameController.text = widget.author!.firstName;
      _lastNameController.text = widget.author!.lastName;
      _countryController.text = widget.author!.country;
      _birthYearController.text = widget.author!.birthYear.toString();
      _deathYearController.text = widget.author!.deathYear?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _birthYearController.dispose();
    _deathYearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final author = Author(
        id: widget.author?.id ?? 0,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        country: _countryController.text.trim(),
        birthYear: int.parse(_birthYearController.text.trim()),
        deathYear: _deathYearController.text.trim().isNotEmpty
            ? int.parse(_deathYearController.text.trim())
            : null,
        deletedAt: widget.author?.deletedAt,
      );

      final repo = context.read<AuthorRepository>();
      if (widget.author == null) {
        await repo.create(author);
      } else {
        await repo.update(author);
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
        title: Text(widget.author == null ? 'Создание автора' : 'Редактирование автора'),
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
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => Validators.string(
                        value: value,
                        fieldName: 'Имя',
                        required: true,
                        minLength: 2,
                        maxLength: 50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Фамилия',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => Validators.string(
                        value: value,
                        fieldName: 'Фамилия',
                        required: true,
                        minLength: 2,
                        maxLength: 50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Страна',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => Validators.string(
                        value: value,
                        fieldName: 'Страна',
                        required: true,
                        minLength: 2,
                        maxLength: 50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _birthYearController,
                      decoration: const InputDecoration(
                        labelText: 'Год рождения',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final intVal = int.tryParse(value?.trim() ?? '');
                        return Validators.number(
                          value: intVal,
                          fieldName: 'Год рождения',
                          required: true,
                          min: 1000,
                          max: DateTime.now().year,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _deathYearController,
                      decoration: const InputDecoration(
                        labelText: 'Год смерти (необязательно)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final intVal = int.tryParse(value.trim());
                        if (intVal == null) {
                          return 'Введите корректный год';
                        }
                        final birthYear = int.tryParse(_birthYearController.text.trim()) ?? 0;
                        if (intVal <= birthYear) {
                          return 'Год смерти должен быть больше года рождения';
                        }
                        if (intVal > DateTime.now().year) {
                          return 'Год смерти не может быть в будущем';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(widget.author == null ? 'Создать' : 'Сохранить'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
