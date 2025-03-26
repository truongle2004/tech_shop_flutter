class Auth {
  final String? accessToken;
  final String? refreshToken;
  final List<String>? roles;
  final int? id;
  Auth({this.accessToken, this.refreshToken, this.roles, this.id});

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      id: json['id'] ?? 0,
      roles: List<String>.from(json['roles'] ?? []),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}
