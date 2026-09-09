class Author {
  final int id;
  final String firstName;
  final String lastName;
  final String country;
  final int birthYear;
  final int? deathYear;
  final DateTime? deletedAt;

  const Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.birthYear,
    this.deathYear,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  String get fullName => '$firstName $lastName';

  Author copyWith({
    String? firstName,
    String? lastName,
    String? country,
    int? birthYear,
    int? deathYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Author(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      birthYear: birthYear ?? this.birthYear,
      deathYear: deathYear ?? this.deathYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'birthYear': birthYear,
      'deathYear': deathYear,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as int? ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      country: json['country'] as String? ?? '',
      birthYear: json['birthYear'] as int? ?? 0,
      deathYear: json['deathYear'] as int?,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'] as String)
          : null,
    );
  }
}
