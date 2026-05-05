import '../models/product_model.dart';

class OrderModel {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final double discount;
  final String? couponCode;
  final DateTime date;
  final String status;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    this.discount = 0.0,
    this.couponCode,
    required this.date,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'discount': discount,
      'couponCode': couponCode,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      items: List<OrderItem>.from(
          map['items']?.map((x) => OrderItem.fromMap(x)) ?? []),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      couponCode: map['couponCode'],
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      status: map['status'] ?? 'Pending',
    );
  }
}

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      product: Product.fromMap(map['product'], map['product']['id'] ?? ''),
      quantity: map['quantity'] ?? 1,
    );
  }
}
