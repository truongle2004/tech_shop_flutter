import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  int? id;
  String? slug;

  void setProduct(int? id, String? slug) {
    this.id = id;
    this.slug = slug;
    notifyListeners();
  }
}
