import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/app_user_model.dart';
import '../models/banner_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/coupon_model.dart';
import '../models/review_model.dart';
import '../models/extra_content_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<BannerItem>> getBanners() {
    return _db.collection('banners').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BannerItem.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addBanner(BannerItem banner) {
    return _db.collection('banners').doc(banner.id).set(banner.toMap());
  }

  Future<void> deleteBanner(String id) {
    return _db.collection('banners').doc(id).delete();
  }


  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => _mapToProduct(doc)).toList());
  }

  Future<void> addProduct(Product product) {
    return _db.collection('products').doc(product.id).set(product.toMap());
  }

  Future<void> updateProduct(Product product) {
    return _db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) {
    return _db.collection('products').doc(id).delete();
  }

  Future<String> uploadProductImage(String fileName, dynamic imageFile) async {
    final ref = _storage.ref().child('products').child(fileName);
    // Assuming imageFile is from image_picker (XFile)
    await ref.putData(await imageFile.readAsBytes());
    return await ref.getDownloadURL();
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    final createdAt = data['createdAt'];

    return AppUser.fromMap({
      ...data,
      'createdAt': createdAt is Timestamp ? createdAt.toDate().toIso8601String() : data['createdAt'],
    });
  }

  Future<void> saveUserProfile(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> saveOrder(String userId, OrderModel order) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(order.id)
        .set(order.toMap());
  }

  Stream<List<OrderModel>> getOrders(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // --- COUPONS ---

  Stream<List<Coupon>> getCoupons() {
    return _db.collection('coupons').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Coupon.fromMap(doc.data(), doc.id)).toList());
  }

  // --- EXTRA CONTENT (NEWS/BLOG) ---

  Stream<List<ExtraContent>> getExtraContent(String type) {
    return _db
        .collection('extra_content')
        .where('type', isEqualTo: type)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExtraContent.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addExtraContent(ExtraContent content) {
    return _db.collection('extra_content').doc(content.id).set(content.toMap());
  }

  Future<void> deleteExtraContent(String id) {
    return _db.collection('extra_content').doc(id).delete();
  }

  // --- REVIEWS ---

  Stream<List<Review>> getProductReviews(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addReview(String productId, Review review) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .doc(review.id)
        .set(review.toMap());
  }


  Product _mapToProduct(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product.fromMap(data, doc.id);
  }
}

class RealtimeDatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: 'https://foodgo-10e44-default-rtdb.firebaseio.com',
  );

  Stream<List<Product>> getProducts() {
    return _db.ref('products').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      final List<Product> products = [];
      data.forEach((key, value) {
        final productData = Map<String, dynamic>.from(value as Map);
        products.add(Product(
          id: key.toString(),
          name: productData['name'] ?? '',
          description: productData['description'] ?? '',
          imageUrl: productData['imageUrl'] ?? '',
          price: (productData['price'] ?? 0.0).toDouble(),
          rating: (productData['rating'] ?? 0.0).toDouble(),
          reviews: productData['reviews'] ?? 0,
          calories: productData['calories'] ?? 0,
          protein: productData['protein'] ?? '',
          tag: productData['tag'] ?? '',
        ));
      });
      return products;
    });
  }

  Future<void> addProduct(Product product) {
    return _db.ref('products').child(product.id).set({
      'name': product.name,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'rating': product.rating,
      'reviews': product.reviews,
      'calories': product.calories,
      'protein': product.protein,
      'tag': product.tag,
    });
  }

  Future<void> updateProduct(Product product) {
    return _db.ref('products').child(product.id).update({
      'name': product.name,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'tag': product.tag,
    });
  }

  Future<void> deleteProduct(String id) {
    return _db.ref('products').child(id).remove();
  }

  // --- USER PROFILES ---

  Future<void> saveUserProfile(AppUser user) async {
    await _db.ref('users').child(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final snapshot = await _db.ref('users').child(uid).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return AppUser.fromMap(data);
  }

  // --- ORDERS ---

  Future<void> saveOrder(String userId, OrderModel order) {
    return _db.ref('orders').child(userId).child(order.id).set(order.toMap());
  }

  Stream<List<OrderModel>> getOrders(String userId) {
    return _db.ref('orders').child(userId).onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      final List<OrderModel> orders = [];
      data.forEach((key, value) {
        final orderData = Map<String, dynamic>.from(value as Map);
        orders.add(OrderModel.fromMap(orderData, key.toString()));
      });
      
      // Sort by date descending
      orders.sort((a, b) => b.date.compareTo(a.date));
      return orders;
    });
  }

  // --- BANNERS ---

  Stream<List<BannerItem>> getBanners() {
    return _db.ref('banners').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      return data.entries.map((e) {
        final bannerData = Map<String, dynamic>.from(e.value as Map);
        return BannerItem.fromMap(bannerData, e.key.toString());
      }).toList();
    });
  }

  Future<void> addBanner(BannerItem banner) {
    return _db.ref('banners').child(banner.id).set(banner.toMap());
  }

  Future<void> deleteBanner(String id) {
    return _db.ref('banners').child(id).remove();
  }
}
