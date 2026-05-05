import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/language_provider.dart';
import '../models/order_model.dart';
import '../widgets/lumiere_button.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.t('order_history'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: LumiereColors.lightGray.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(context.t('orders') + ' empty', style: const TextStyle(color: LumiereColors.lightGray, fontSize: 16)),
        ],
      ).animate().fadeIn(),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: LumiereColors.orangePrimary.withOpacity(0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ID: #${order.id.substring(order.id.length - 6).toUpperCase()}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: LumiereColors.orangePrimary)),
                  Text(DateFormat('MMM dd, yyyy • HH:mm').format(order.date), 
                    style: const TextStyle(fontSize: 12, color: LumiereColors.lightGray)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(image: NetworkImage(item.product.imageUrl), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('${item.quantity} x \$${item.product.price.toStringAsFixed(2)}', 
                                style: const TextStyle(fontSize: 12, color: LumiereColors.lightGray)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusChip(status: order.status),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (order.discount > 0)
                            Text('-\$${order.discount.toStringAsFixed(2)}', 
                              style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('\$${order.totalAmount.toStringAsFixed(2)}', 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: LumiereColors.darkGray)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'completed': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = LumiereColors.orangePrimary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

