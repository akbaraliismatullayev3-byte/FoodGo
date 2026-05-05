import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _dbService = FirestoreService();
  List<OrderModel> _orders = [];
  StreamSubscription? _subscription;
  String? _userId;


  List<OrderModel> get orders => [..._orders];

  void updateUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    
    if (userId != null) {
      _subscription = _dbService.getOrders(userId).listen((orders) {
        _orders = orders;
        notifyListeners();
      });
    } else {
      _orders = [];
      notifyListeners();
    }
  }

  Future<void> addOrder(OrderModel order) async {
    if (_userId == null) return;
    await _dbService.saveOrder(_userId!, order);
    // Note: Local _orders will update automatically via the stream subscription
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
