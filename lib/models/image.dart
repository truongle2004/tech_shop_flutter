class Image {
  final int id;
  final String src;
  final String alt;
  final int position;
  final String createAt;
  final String deleteAt;

  Image({
    required this.id,
    required this.src,
    required this.alt,
    required this.position,
    required this.createAt,
    required this.deleteAt,
  });

  // Factory method to create a Image object from a JSON map
  factory Image.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('Failed to load image: Empty JSON');
    }

    return Image(
      id: json['id'] ?? 0, // Provide a default value or handle null case
      src: json['src'] ?? '', // Avoid null errors by providing default values
      alt: json['alt'] ?? '', // Nullable field
      position: json['position'] ?? -1, // Nullable field
      createAt: json['create_at'] ?? '', // Nullable field
      deleteAt: json['delete_at'] ?? '', // Nullable field
    );
  }
}
