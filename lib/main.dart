import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tech_shop_flutter/provider/auth_provider.dart';
import 'package:tech_shop_flutter/provider/cart_provider.dart';
import 'package:tech_shop_flutter/provider/product_provider.dart';
import 'package:tech_shop_flutter/screen/cart_screen.dart';
import 'package:tech_shop_flutter/screen/categories_screen.dart';
import 'package:tech_shop_flutter/screen/detail_screen.dart';
import 'package:tech_shop_flutter/screen/home_screen.dart';
import 'package:tech_shop_flutter/screen/login_screen.dart';
import 'package:tech_shop_flutter/screen/register_screen.dart';
import 'package:tech_shop_flutter/screen/profile_screen.dart';
import 'package:tech_shop_flutter/services/api_service.dart';
import 'package:tech_shop_flutter/models/product.dart';
import 'package:tech_shop_flutter/utils/format_currency.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ProductProvider()),
      ChangeNotifierProvider(create: (context) => CartProvider()),
      ChangeNotifierProvider(create: (context) => AuthProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FToastBuilder(),
      title: 'Tech Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.isAuthenticated) {
              return const LoginScreen();
            }
            return const MainScreen();
            },
        ),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/detail': (context) => const DetailScreen(),
        '/category': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return Scaffold(
            appBar: AppBar(
              title: Text(args ?? 'Products'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Search functionality
                  },
                ),
              ],
            ),
            body: FutureBuilder<List<dynamic>>(
              future: args != null
                  ? ApiService()
                      .fetchProducts(category: args)
                      .then((data) => data.content)
                  : ApiService().fetchProducts().then((data) => data.content),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Reload data
                            Navigator.pushReplacementNamed(context, '/category',
                                arguments: args);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No products found in this category',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data as List<Product>;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Consumer<CartProvider>(
                      builder: (ctx, cart, _) {
                        final isInCart = cart.isInCart(product.id);

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image with Quick Add Button
                              Stack(
                                children: [
                                  // Product image
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Provider.of<ProductProvider>(context,
                                                  listen: false)
                                              .setProduct(
                                                  product.id, product.slug);
                                          Navigator.pushNamed(
                                              context, '/detail');
                                        },
                                        child: Hero(
                                          tag: 'product_image_${product.id}',
                                          child: Image.network(
                                            product.images.isNotEmpty
                                                ? product.images[0].src
                                                : 'https://via.placeholder.com/150',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Quick add to cart button
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          isInCart
                                              ? Icons.shopping_cart
                                              : Icons.add_shopping_cart,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          if (isInCart) {
                                            cart.incrementQuantity(product.id);
                                          } else {
                                            cart.addItem(product);
                                          }

                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                isInCart
                                                    ? 'Increased quantity for ${product.title}'
                                                    : 'Added ${product.title} to cart',
                                              ),
                                              duration:
                                                  const Duration(seconds: 2),
                                              action: SnackBarAction(
                                                label: 'VIEW CART',
                                                onPressed: () {
                                                  // Navigate to cart tab
                                                  Navigator.of(context).pop();
                                                  final mainScreenState = context
                                                      .findAncestorStateOfType<
                                                          _MainScreenState>();
                                                  if (mainScreenState != null) {
                                                    mainScreenState
                                                        ._onItemTapped(
                                                            2); // Cart tab index
                                                  }
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Product info
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Title
                                      Text(
                                        product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),

                                      // Price and cart count
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Price
                                          Text(
                                            FormatCurrency()
                                                .format(product.price),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),

                                          // Cart quantity indicator
                                          if (isInCart)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'x${cart.getQuantity(product.id)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
