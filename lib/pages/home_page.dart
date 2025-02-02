import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tech_shop_flutter/models/product.dart';
import 'package:tech_shop_flutter/models/product_data.dart';
import 'package:tech_shop_flutter/services/api_service.dart';
import 'package:tech_shop_flutter/utils/format_currency.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ProductData> productsFuture;
  late Future<List<String>> suggestCategoryFuture;
  late Future<List<Map<String, ProductData>>> categoryProductFuture;

  Future<List<Map<String, ProductData>>> fetchProducts() async {
    List<Map<String, ProductData>> categoryProductList = [];

    List<String> categories =
        await ApiService().fetchCategorySuggestionsHomeScreen();

    await Future.forEach(categories, (category) async {
      ProductData products =
          await ApiService().fetchProducts(category: category);
      categoryProductList.add({category: products});
    });

    return categoryProductList;
  }

  @override
  void initState() {
    super.initState();
    productsFuture = ApiService().fetchProducts();
    suggestCategoryFuture = ApiService().fetchCategorySuggestionsHomeScreen();
    categoryProductFuture = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder()),
            style: TextStyle(color: Colors.black, fontSize: 18),
            onChanged: (query) {
              print(query);
            },
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
          ],
        ),
        body: FutureBuilder<List<Map<String, ProductData>>>(
            future: categoryProductFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerLoading();
              } else if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              } else if (snapshot.hasData) {
                var data = snapshot.data!;
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var category = data[index].keys.first;
                      ProductData products = data[index][category]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/category',
                                            arguments: category);
                                      },
                                      child: const Text('See all'))
                                ],
                              )),
                          const Divider(),
                          _buildProductList(products.content),
                        ],
                      );
                    });
              } else {
                return _buildEmptyState();
              }
            }));
  }

  /// Loading Placeholder with Shimmer
  Widget _buildShimmerLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  /// Error State UI
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          Text('Error loading data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                productsFuture = ApiService().fetchProducts();
              });
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  /// Empty State UI
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No products available',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  /// Product List UI
  Widget _buildProductList(List<Product> products) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  ///  Product Card UI
  Widget _buildProductCard(Product product) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              product.images.isNotEmpty
                  ? product.images[0].src
                  : 'https://via.placeholder.com/150',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image,
                    size: 100, color: Colors.grey);
              },
            ),
          ),
          const SizedBox(height: 8),

          // Product Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),

          // Product Price
          Text(
            FormatCurrency().format(product.price),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),

          // Buy Button
          // ElevatedButton(
          //   onPressed: () {
          //     print("Buy ${product.title}");
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue,
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8)),
          //   ),
          //   child: const Text("Buy Now", style: TextStyle(color: Colors.white)),
          // ),
        ],
      ),
    );
  }
}
