import 'package:tech_shop_flutter/models/product.dart';

class ProductData {
  final List<Product> content;
  final int pageNo;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  ProductData({
    required this.content,
    required this.pageNo,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    try {
      return ProductData(
        content:
            List<Product>.from(json['content'].map((x) => Product.fromJson(x))),
        pageNo: json['pageNo'] ?? 0,
        pageSize: json['pageSize'] ?? 0,
        totalElements: json['totalElements'] ?? 0,
        totalPages: json['totalPages'] ?? 0,
        last: json['last'] ?? false,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing ProductData: $e'); // Log the error
      return ProductData(
        // Return an empty fallback object
        content: [],
        pageNo: 0,
        pageSize: 0,
        totalElements: 0,
        totalPages: 0,
        last: false,
      );
    }
  }
}
