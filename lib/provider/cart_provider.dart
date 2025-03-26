import 'package:flutter/foundation.dart';
import 'package:tech_shop_flutter/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  bool isInCart(int productId) {
    return _items.containsKey(productId);
  }

  int getQuantity(int productId) {
    return _items[productId]?.quantity ?? 0;
  }

  void addItem(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + quantity,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          product: product,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void incrementQuantity(int productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
      notifyListeners();
    }
  }

  void decrementQuantity(int productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items.update(
          productId,
          (existingItem) => CartItem(
            product: existingItem.product,
            quantity: existingItem.quantity - 1,
          ),
        );
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}