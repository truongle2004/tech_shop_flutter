import 'dart:convert';

import 'package:tech_shop_flutter/models/image.dart';

class Product {
  final int id;
  final bool available;
  final String title;
  final String description;
  final String tags;
  final String category;
  final String vendor;
  final double price;
  final String createAt;
  final String updateAt;
  final String deleteAt;
  final List<Image> images;

  Product({
    required this.id,
    required this.available,
    required this.title,
    required this.description,
    required this.tags,
    required this.category,
    required this.vendor,
    required this.price,
    required this.images,
    required this.createAt,
    required this.updateAt,
    required this.deleteAt,
  });

  // Factory method to create a Product object from a JSON map
  factory Product.fromJson(Map<String, dynamic> json) {
   
    return Product(
      id: json['id'] ?? -1,
      available: json['available'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: json['tags'] ?? '',
      category: json['category'] ?? '',
      vendor: json['vendor'] ?? '',
      price: json['price'] ?? 0,
      createAt: json['create_at'] ?? '',
      updateAt: json['update_at'] ?? '',
      deleteAt: json['delete_at'] ?? '',
      images: json['images'] != null
          ? (json['images'] as List).map((e) => Image.fromJson(e)).toList()
          : [],
    );
  }
}
