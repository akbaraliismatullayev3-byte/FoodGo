import 'package:flutter/material.dart';

class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> gradientColors;
  final String? tag;

  final String? productId;
  final String? category;

  const BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradientColors,
    this.tag,
    this.productId,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'gradientColors': gradientColors.map((c) => c.value).toList(),
      'tag': tag,
      'productId': productId,
      'category': category,
    };
  }

  factory BannerItem.fromMap(Map<dynamic, dynamic> map, String id) {
    return BannerItem(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      gradientColors: (map['gradientColors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          [const Color(0xFFff4b1f), const Color(0xFFff9068)],
      tag: map['tag'],
      productId: map['productId'],
      category: map['category'],
    );
  }
}
