class User {
  final String? username;
  final String? id;

  User({
    required this.username,
    required this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      id: json['id'] ?? '',
    );
  }
}
