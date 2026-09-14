class AppUser {
  final int id;
  final String username;
  final String email;
  final String fullName;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'fullName': fullName,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['fullName'] as String? ?? json['username'] as String? ?? '',
      );
}
