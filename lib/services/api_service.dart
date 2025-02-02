import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:tech_shop_flutter/models/category.dart';
import 'package:tech_shop_flutter/models/product_data.dart';

class ApiService {
  final String baseUrl = dotenv.env['PRODUCT_URL'] ?? '';

  ApiService() {
    if (baseUrl.isEmpty) {
      throw Exception('PRODUCT_URL is not defined in the .env file');
    }
  }

  Future<dynamic> _get(String endpoint) async {
    final res = await http.get(Uri.parse('$baseUrl$endpoint'));

    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    } else {
      print('endpoint: $baseUrl$endpoint');
      throw Exception('Failed to load data, Status Code: ${res.statusCode}');
    }
  }

  Future<ProductData> fetchProducts(
      {int pageNo = 1,
      int pageSize = 10,
      String category = 'laptop-gaming'}) async {
    final data =
        await _get('?pageNo=$pageNo&pageSize=$pageSize&category=$category');
    return ProductData.fromJson(data);
  }

  Future<List<Category>> fetchAllProductCategorySlug() async {
    final data = await _get('/category');
    return List<Category>.from(data.map((x) => Category.fromJson(x)));
  }

  Future<List<String>> fetchCategorySuggestionsHomeScreen() async {
    final data = await _get('/suggestions');
    return List<String>.from(data);
  }
}
