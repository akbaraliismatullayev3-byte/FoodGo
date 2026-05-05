import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';

class CommentProvider extends ChangeNotifier {
  static const String _storageKey = 'local_comments';
  Map<String, List<Review>> _localReviews = {};

  CommentProvider() {
    _loadFromPrefs();
  }

  List<Review> getCommentsForProduct(String productId) {
    return _localReviews[productId] ?? [];
  }

  Future<void> addComment(String productId, Review review) async {
    if (!_localReviews.containsKey(productId)) {
      _localReviews[productId] = [];
    }
    _localReviews[productId]!.add(review);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null) {
        final Map<String, dynamic> decoded = jsonDecode(data);
        _localReviews = decoded.map((key, value) {
          final List<dynamic> list = value as List;
          return MapEntry(
            key,
            list.map((item) => Review.fromMap(Map<String, dynamic>.from(item), item['id'] ?? '')).toList(),
          );
        });
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toSave = _localReviews.map((key, value) {
        return MapEntry(key, value.map((r) => r.toMap()).toList());
      });
      await prefs.setString(_storageKey, jsonEncode(toSave));
    } catch (e) {
      debugPrint('Error saving comments: $e');
    }
  }
}
