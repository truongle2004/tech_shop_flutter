class Category {
  final int id;
  final String name;
  final String slug;

  Category({required this.id, required this.name, required this.slug});

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
      );
    } catch (err) {
      print('Err from Category json: $err');
      return Category(
        id: 0,
        name: '',
        slug: '',
      );
    }
  }
}
