import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tech_shop_flutter/models/product.dart';
import 'package:tech_shop_flutter/models/product_data.dart';
import 'package:tech_shop_flutter/provider/cart_provider.dart';
import 'package:tech_shop_flutter/provider/product_provider.dart';
import 'package:tech_shop_flutter/screen/detail_screen.dart';
import 'package:tech_shop_flutter/services/api_service.dart';
import 'package:tech_shop_flutter/utils/format_currency.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ProductData> productsFuture;
  late Future<List<String>> suggestCategoryFuture;
  late Future<List<Map<String, ProductData>>> categoryProductFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Future<List<Map<String, ProductData>>> fetchProducts() async {
    List<Map<String, ProductData>> categoryProductList = [];

    List<String> categories =
        await ApiService().fetchCategorySuggestionsHomeScreen();

    await Future.forEach(categories, (category) async {
      print(category);
      ProductData products =
          await ApiService().fetchProducts(category: category);
      categoryProductList.add({category: products});
    });

    return categoryProductList;
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //   // Handle navigation to different screens based on index
  // }

  @override
  void initState() {
    super.initState();
    productsFuture = ApiService().fetchProducts();
    suggestCategoryFuture = ApiService().fetchCategorySuggestionsHomeScreen();
    categoryProductFuture = fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onSubmitted: (query) {
                  // Implement search functionality
                },
              )
            : const Text('Tech Shop'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              _isSearching ? _stopSearch() : _startSearch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            categoryProductFuture = fetchProducts();
          });
        },
        child: FutureBuilder<List<Map<String, ProductData>>>(
          future: categoryProductFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (snapshot.hasData) {
              var data = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  // Featured banner
                  SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor, Colors.blue],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Featured Products',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Categories
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var category = data[index].keys.first;
                        ProductData products = data[index][category]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/category',
                                          arguments: category);
                                    },
                                    child: const Text('See all'),
                                  ),
                                ],
                              ),
                            ),
                            _buildProductList(products.content),
                          ],
                        );
                      },
                      childCount: data.length,
                    ),
                  ),
                ],
              );
            } else {
              return _buildEmptyState();
            }
          },
        ),
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return cart.itemCount > 0
              ? FloatingActionButton(
                  onPressed: () {
                    _showCartModal(context);
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Stack(
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cart.totalQuantity}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, categoryIndex) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 24,
                width: 150,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                categoryProductFuture = fetchProducts();
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Provider.of<ProductProvider>(context, listen: false)
            .setProduct(product.id, product.slug);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailScreen()),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Hero(
                    tag: 'product-${product.id}-0',
                    child: Image.network(
                      product.images.isNotEmpty
                          ? product.images[0].src
                          : 'https://via.placeholder.com/180',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image,
                              size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Consumer<CartProvider>(
                    builder: (ctx, cart, child) {
                      final isInCart = cart.items.containsKey(product.id);
                      return GestureDetector(
                        onTap: () {
                          if (!isInCart) {
                            cart.addItem(product);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.title} added to cart'),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () {
                                    cart.removeItem(product.id);
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isInCart
                                ? Colors.green
                                : Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isInCart ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FormatCurrency().format(product.price).toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<CartProvider>(
          builder: (ctx, cart, child) {
            return cart.items.isEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Continue Shopping'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Cart',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: cart.items.length,
                            itemBuilder: (ctx, index) {
                              final cartItem =
                                  cart.items.values.toList()[index];
                              final product = cartItem.product;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      // Product image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product.images.isNotEmpty
                                              ? product.images[0].src
                                              : 'https://via.placeholder.com/80',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Product details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              FormatCurrency()
                                                  .format(product.price),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Quantity controls
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                            onPressed: () {
                                              cart.decrementQuantity(
                                                  product.id);
                                            },
                                          ),
                                          Text(
                                            '${cartItem.quantity}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.add_circle_outline),
                                            onPressed: () {
                                              cart.incrementQuantity(
                                                  product.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                FormatCurrency().format(cart.totalAmount),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // Navigate to checkout
                              Navigator.pop(context);
                            },
                            child: const Text('Checkout'),
                          ),
                        ),
                      ],
                    ),
                  );
          },
        );
      },
    );
  }
}
