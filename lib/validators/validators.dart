class Validators {
  static String? required(String? value, {String fieldName = 'Поле'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обязательно для заполнения';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'Поле',
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length < min) {
      return '$fieldName должно содержать не менее $min символов';
    }
    return null;
  }

  static String? maxLength(
    String? value,
    int max, {
    String fieldName = 'Поле',
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > max) {
      return '$fieldName должно содержать не более $max символов';
    }
    return null;
  }

  static String? range(
    int? value,
    int min,
    int max, {
    String fieldName = 'Поле',
  }) {
    if (value == null) {
      return '$fieldName обязательно для заполнения';
    }
    if (value < min || value > max) {
      return '$fieldName должно быть в диапазоне от $min до $max';
    }
    return null;
  }

  static String? positive(int? value, {String fieldName = 'Поле'}) {
    if (value == null) {
      return '$fieldName обязательно для заполнения';
    }
    if (value <= 0) {
      return '$fieldName должно быть положительным числом';
    }
    return null;
  }

  static String? nonNegative(int? value, {String fieldName = 'Поле'}) {
    if (value == null) {
      return '$fieldName обязательно для заполнения';
    }
    if (value < 0) {
      return '$fieldName не может быть отрицательным';
    }
    return null;
  }

  static String? isbn(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'ISBN обязателен для заполнения';
    }
    // Проверка, может ли содержать дефисы
    final clean = trimmed.replaceAll('-', '');
    if (clean.length != 10 && clean.length != 13) {
      return 'ISBN должен содержать 10 или 13 цифр';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(clean)) {
      return 'ISBN должен содержать только цифры и дефисы';
    }
    return null;
  }

  // Комбинированный валидатор для строк
  static String? string({
    required String? value,
    required String fieldName,
    bool required = true,
    int? minLength,
    int? maxLength,
    RegExp? pattern,
    String? patternError,
  }) {
    if (required) {
      final requiredError = Validators.required(value, fieldName: fieldName);
      if (requiredError != null) return requiredError;
    }

    final trimmed = value?.trim() ?? '';
    if (!required && trimmed.isEmpty) return null;

    if (minLength != null) {
      final minError = Validators.minLength(
        trimmed,
        minLength,
        fieldName: fieldName,
      );
      if (minError != null) return minError;
    }

    if (maxLength != null) {
      final maxError = Validators.maxLength(
        trimmed,
        maxLength,
        fieldName: fieldName,
      );
      if (maxError != null) return maxError;
    }

    if (pattern != null && !pattern.hasMatch(trimmed)) {
      return patternError ?? 'Некорректный формат $fieldName';
    }

    return null;
  }

  // Комбинированный валидатор для чисел
  static String? number({
    required int? value,
    required String fieldName,
    bool required = true,
    int? min,
    int? max,
    bool positive = false,
    bool nonNegative = false,
  }) {
    if (required && value == null) {
      return '$fieldName обязательно для заполнения';
    }
    if (value == null) return null;

    if (min != null && max != null) {
      return Validators.range(value, min, max, fieldName: fieldName);
    }

    if (positive) {
      return Validators.positive(value, fieldName: fieldName);
    }

    if (nonNegative) {
      return Validators.nonNegative(value, fieldName: fieldName);
    }

    if (min != null && value < min) {
      return '$fieldName должно быть не менее $min';
    }

    if (max != null && value > max) {
      return '$fieldName должно быть не более $max';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль обязателен';
    }
    final s = PasswordStrength.evaluate(value);
    if (!s.hasMinLength) return 'Минимум 8 символов';
    if (!s.hasDigit) return 'Добавьте хотя бы одну цифру';
    if (!s.hasSpecial) return 'Добавьте специальный символ (!@#\$%...)';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email обязателен';
    }
    final re = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');
    if (!re.hasMatch(value.trim())) return 'Некорректный email';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Логин обязателен';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) return 'Минимум 3 символа';
    if (trimmed.length > 32) return 'Не более 32 символов';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      return 'Только латиница, цифры и _';
    }
    return null;
  }
}

class PasswordStrength {
  final bool hasMinLength;
  final bool hasDigit;
  final bool hasSpecial;
  final bool hasUppercase;

  const PasswordStrength({
    required this.hasMinLength,
    required this.hasDigit,
    required this.hasSpecial,
    required this.hasUppercase,
  });

  bool get isValid => hasMinLength && hasDigit && hasSpecial;

  static PasswordStrength evaluate(String password) {
    return PasswordStrength(
      hasMinLength: password.length >= 8,
      hasDigit: RegExp(r'\d').hasMatch(password),
      hasSpecial: RegExp(
        r'[!@#$%^&*(),.?":{}|<>_\-\[\]\\/;`~+=]',
      ).hasMatch(password),
      hasUppercase: RegExp(r'[A-ZА-Я]').hasMatch(password),
    );
  }
}
