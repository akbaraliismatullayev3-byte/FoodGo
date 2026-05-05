import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firebase_service.dart';
import '../models/banner_model.dart';
import '../models/coupon_model.dart';


class ProductProvider with ChangeNotifier {
  final FirestoreService _dbService = FirestoreService();
  List<Product> _products = [];
  List<BannerItem> _banners = [];
  List<Coupon> _coupons = [];
  bool _isLoading = false;

  ProductProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    
    // Listen to products from Firestore
    _dbService.getProducts().listen((products) {
      _products = products;
      _isLoading = false;
      notifyListeners();
    });

    // Listen to banners from Firestore
    _dbService.getBanners().listen((banners) {
      _banners = banners;
      notifyListeners();
    });

    // Listen to coupons from Firestore
    _dbService.getCoupons().listen((coupons) {
      _coupons = coupons;
      notifyListeners();
    });
  }


  List<Product> get products => _products;
  List<BannerItem> get banners => _banners;
  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;


  List<Product> get popularProducts => _products.where((p) => p.rating >= 4.8).toList();
  List<Product> get recommendedProducts => _products.where((p) => p.tag == 'SIGNATURE').toList();

  Future<void> addProduct(Product product) async {
    await _dbService.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _dbService.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _dbService.deleteProduct(id);
  }

  Future<void> addBanner(BannerItem banner) async {
    await _dbService.addBanner(banner);
  }

  Future<void> deleteBanner(String id) async {
    await _dbService.deleteBanner(id);
  }
}
