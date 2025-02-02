import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tech_shop_flutter/models/product_data.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<ProductData> fetchProducts() async {
    final String? url = dotenv.env['PRODUCT_URL'];

    if (url == null || url.isEmpty) {
      throw Exception('PRODUCT_URL is not defined in the .env file');
    }

    final res = await http
        .get(Uri.parse('$url?pageNo=1&pageSize=10&category=laptop-gaming'));

    if (res.statusCode == 200) {
      return ProductData.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(
          'Failed to load products, Status Code: ${res.statusCode}');
    }
  }
}
