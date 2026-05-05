import 'package:flutter/material.dart';
import 'package:food_go/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/language_provider.dart';
import '../core/theme.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.t('cart'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return _CartItemTile(item: item).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
                    },
                  ),
                ),
                _buildSummarySection(context, cart, productProvider),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: LumiereColors.lightGray.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(context.t('cart_empty'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LumiereColors.darkGray)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: LumiereColors.orangePrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(context.t('order_now')),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildSummarySection(BuildContext context, CartProvider cart, ProductProvider productProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coupon Section
            _buildCouponSection(context, cart, productProvider),
            const SizedBox(height: 20),
            _SummaryRow(label: 'Subtotal', value: '\$${cart.subtotal.toStringAsFixed(2)}'),
            _SummaryRow(label: 'Delivery Fee', value: '\$${cart.deliveryFee.toStringAsFixed(2)}'),
            _SummaryRow(label: 'Service Fee', value: '\$${cart.serviceFee.toStringAsFixed(2)}'),
            if (cart.discount > 0)
              _SummaryRow(label: 'Discount', value: '-\$${cart.discount.toStringAsFixed(2)}', isDiscount: true),
            const Divider(height: 30),
            _SummaryRow(label: 'Total', value: '\$${cart.totalAmount.toStringAsFixed(2)}', isTotal: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _checkout(context, cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LumiereColors.orangePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                  shadowColor: LumiereColors.orangePrimary.withOpacity(0.4),
                ),
                child: Text(context.t('checkout'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context, CartProvider cart, ProductProvider productProvider) {
    if (cart.appliedCoupon != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Coupon "${cart.appliedCoupon!.code}" applied!',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.green, size: 18),
              onPressed: () => cart.removeCoupon(),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => _showCouponSheet(context, cart, productProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: LumiereColors.creamBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: const Row(
          children: [
            Icon(Icons.local_offer_outlined, color: LumiereColors.orangePrimary, size: 20),
            SizedBox(width: 12),
            Text('Apply Coupon Code', style: TextStyle(color: LumiereColors.darkGray, fontWeight: FontWeight.w600)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: LumiereColors.lightGray),
          ],
        ),
      ),
    );
  }

  void _showCouponSheet(BuildContext context, CartProvider cart, ProductProvider productProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CouponSheet(cart: cart, productProvider: productProvider),
    );
  }

  Future<void> _checkout(BuildContext context, CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to checkout')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: cart.items.values.map((i) => OrderItem(product: i.product, quantity: i.quantity)).toList(),
      totalAmount: cart.totalAmount,
      discount: cart.discount,
      couponCode: cart.appliedCoupon?.code,
      date: DateTime.now(),
      status: 'Pending',
    );

    await FirestoreService().saveOrder(user.uid, order);
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      cart.clear();
      _showSuccessDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              const Text('Order Placed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Your meal is being prepared and will be with you soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: LumiereColors.lightGray),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LumiereColors.orangePrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Track Order', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(item.product.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('\$${item.product.price.toStringAsFixed(2)}', style: const TextStyle(color: LumiereColors.orangePrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: LumiereColors.creamBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => cart.removeSingleItem(item.product.id),
                ),
                Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => cart.addItem(item.product),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Fixing _CartItemTile: cart.addItem takes Product
// I'll fix this in the actual file content below.

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false, this.isDiscount = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? LumiereColors.darkGray : LumiereColors.lightGray,
          )),
          Text(value, style: TextStyle(
            fontSize: isTotal ? 22 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: isDiscount ? Colors.green : (isTotal ? LumiereColors.orangePrimary : LumiereColors.darkGray),
          )),
        ],
      ),
    );
  }
}

class _CouponSheet extends StatelessWidget {
  final CartProvider cart;
  final ProductProvider productProvider;

  const _CouponSheet({required this.cart, required this.productProvider});

  @override
  Widget build(BuildContext context) {
    final coupons = productProvider.coupons;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 24),
          const Text('Available Coupons', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: coupons.isEmpty
                ? const Center(child: Text('No coupons available at the moment.'))
                : ListView.builder(
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      final isEligible = cart.subtotal >= coupon.minOrderAmount;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isEligible ? Colors.white : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isEligible ? LumiereColors.orangePrimary.withOpacity(0.2) : Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: isEligible ? LumiereColors.orangePrimary.withOpacity(0.1) : Colors.grey.shade100, shape: BoxShape.circle),
                              child: Icon(Icons.local_offer, color: isEligible ? LumiereColors.orangePrimary : Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('${coupon.discountPercent}% OFF up to \$${coupon.maxDiscount}', style: const TextStyle(fontSize: 12, color: LumiereColors.lightGray)),
                                  if (!isEligible)
                                    Text('Min order \$${coupon.minOrderAmount}', style: const TextStyle(fontSize: 10, color: Colors.red)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: isEligible ? () {
                                cart.applyCoupon(coupon);
                                Navigator.pop(context);
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LumiereColors.orangePrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Apply'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
