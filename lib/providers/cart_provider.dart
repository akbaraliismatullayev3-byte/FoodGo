import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/coupon_model.dart';


class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Coupon? _appliedCoupon;


  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.product.price * item.quantity;
    });
    return total;
  }

  double get deliveryFee => itemCount > 0 ? 5.00 : 0.00;
  double get serviceFee => itemCount > 0 ? 2.50 : 0.00;
  
  double get discount {
    if (_appliedCoupon == null) return 0.0;
    double calculated = subtotal * (_appliedCoupon!.discountPercent / 100);
    if (calculated > _appliedCoupon!.maxDiscount) calculated = _appliedCoupon!.maxDiscount;
    return calculated;
  }

  double get totalAmount => (subtotal + deliveryFee + serviceFee) - discount;

  Coupon? get appliedCoupon => _appliedCoupon;

  bool applyCoupon(Coupon coupon) {
    if (subtotal >= coupon.minOrderAmount) {
      _appliedCoupon = coupon;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }


  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
