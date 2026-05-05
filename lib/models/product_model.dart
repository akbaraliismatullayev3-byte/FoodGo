import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviews;
  final int calories;
  final String protein;
  final String tag;
  final DateTime? createdAt;
  final List<CustomizationOption> options;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.calories,
    required this.protein,
    this.tag = "",
    this.createdAt,
    this.options = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'calories': calories,
      'protein': protein,
      'tag': tag,
      'createdAt': createdAt?.toIso8601String(),
      'options': options.map((x) => x.toMap()).toList(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    try {
      DateTime? parsedDate;
      if (map['createdAt'] is Timestamp) {
        parsedDate = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedDate = DateTime.tryParse(map['createdAt']);
      }

      return Product(
        id: id,
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        price: (map['price'] ?? 0.0).toDouble(),
        rating: (map['rating'] ?? 0.0).toDouble(),
        reviews: (map['reviews'] ?? 0).toInt(),
        calories: (map['calories'] ?? 0).toInt(),
        protein: map['protein']?.toString() ?? '',
        tag: map['tag'] ?? '',
        createdAt: parsedDate,
        options: map['options'] != null && map['options'] is List
            ? List<CustomizationOption>.from(
                (map['options'] as List).map((x) => CustomizationOption.fromMap(x)))
            : [],
      );
    } catch (e) {
      print('Error parsing product $id: $e');
      // Return a basic product if parsing fails to avoid crashing the whole list
      return Product(
        id: id,
        name: map['name'] ?? 'Error parsing',
        description: '',
        imageUrl: '',
        price: 0.0,
        rating: 0.0,
        reviews: 0,
        calories: 0,
        protein: '',
      );
    }
  }
}

class CustomizationOption {
  final String name;
  final double price;
  final String icon;

  CustomizationOption({
    required this.name,
    required this.price,
    this.icon = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'icon': icon,
    };
  }

  factory CustomizationOption.fromMap(Map<String, dynamic> map) {
    return CustomizationOption(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      icon: map['icon'] ?? '',
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
