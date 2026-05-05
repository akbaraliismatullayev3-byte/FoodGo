import 'package:flutter/material.dart';
import 'package:food_go/providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/lumiere_button.dart';
import '../models/review_model.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../providers/comment_provider.dart';


class FoodDetailScreen extends StatefulWidget {
  final Product product;
  const FoodDetailScreen({super.key, required this.product});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  final Set<String> _selectedCustomizations = {};
  final TextEditingController _reviewController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  double _userRating = 5.0;


  Future<void> _submitReview(BuildContext context) async {
    final text = _reviewController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user?.uid ?? 'guest',
      userName: user?.displayName ?? 'Foodie',
      userImageUrl: user?.photoURL ?? '',
      comment: text,
      rating: _userRating,
      date: DateTime.now(),
    );

    // Checklist requirement: Store in local storage
    await commentProvider.addComment(widget.product.id, review);

    _reviewController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Your comment has been added'), // Checklist exact string
            ],
          ),
          backgroundColor: LumiereColors.orangePrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final title = widget.product.name.isNotEmpty ? widget.product.name : 'Miso-Glazed Harvest Bowl';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Hero Header
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),

                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      if (widget.product.tag.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: LumiereColors.redAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.product.tag,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 16),

                      // Price & Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.product.rating.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${widget.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: LumiereColors.redAccent),
                              ),
                            ],
                          ),
                          _buildQuantitySelector(),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // The Story
                      Text(context.t('description'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LumiereColors.darkGray)),
                      const SizedBox(height: 12),
                      Text(
                        widget.product.description,
                        style: const TextStyle(color: LumiereColors.darkGray, height: 1.6, fontSize: 15),
                      ),

                      const SizedBox(height: 32),

                      // Customization
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.t('customizations'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LumiereColors.darkGray)),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (_selectedCustomizations.isEmpty) return;
                              setState(() => _selectedCustomizations.clear());
                            },
                            child: Text(
                              context.t('clear_all'),
                              style: const TextStyle(color: LumiereColors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...widget.product.options.map((opt) => _buildCustomOption(opt)),

                      const SizedBox(height: 32),

                      // Nutritional Profile
                      Text(
                        context.t('nutrition'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LumiereColors.darkGray),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildNutritionCard('${widget.product.calories}', context.t('calories').toUpperCase()),
                          const SizedBox(width: 16),
                          _buildNutritionCard(widget.product.protein, context.t('protein').toUpperCase()),
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      // Write Review Section
                      Text(
                        context.t('write_review'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LumiereColors.darkGray),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (index) => IconButton(
                          icon: Icon(
                            index < _userRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () => setState(() => _userRating = index + 1.0),
                        )),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: LumiereColors.creamBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _reviewController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Share your culinary experience...',
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _submitReview(context),
                          style: TextButton.styleFrom(
                            backgroundColor: LumiereColors.orangePrimary.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(context.t('submit'), style: const TextStyle(color: LumiereColors.orangePrimary, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Display Reviews from Local Storage (Checklist Requirement)
                      Consumer<CommentProvider>(
                        builder: (context, commentProvider, _) {
                          final reviews = commentProvider.getCommentsForProduct(widget.product.id);
                          if (reviews.isEmpty) return const SizedBox();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reviews (${reviews.length})',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LumiereColors.darkGray),
                              ),
                              const SizedBox(height: 16),
                              ...reviews.map((review) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.black.withOpacity(0.03)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundImage: review.userImageUrl.isNotEmpty ? NetworkImage(review.userImageUrl) : null,
                                          backgroundColor: LumiereColors.creamBg,
                                          child: review.userImageUrl.isEmpty ? const Icon(Icons.person, color: LumiereColors.lightGray, size: 20) : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Row(
                                                children: List.generate(5, (i) => Icon(
                                                  Icons.star,
                                                  size: 12,
                                                  color: i < review.rating ? Colors.amber : Colors.grey.shade300,
                                                )),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(DateFormat('MMM d, yyyy').format(review.date), style: const TextStyle(fontSize: 10, color: LumiereColors.lightGray)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      review.comment,
                                      style: const TextStyle(color: LumiereColors.darkGray, height: 1.4),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          );
                        },
                      ),


                      const SizedBox(height: 120), // Spacer for bottom button
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Button
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: LumiereButton(
              text: context.t('add_to_cart'),
              onPressed: () {
                for (int i = 0; i < _quantity; i++) {
                  cartProvider.addItem(widget.product);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.product.name} ${context.t('add_to_cart').toLowerCase()}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        children: [
          Hero(
            tag: widget.product.id,
            child: Image.network(widget.product.imageUrl, width: double.infinity, height: 400, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                  _buildCircleButton(Icons.favorite_border, () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: LumiereColors.darkGray, size: 20),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LumiereColors.creamBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildSmallButton(Icons.remove, () {
            if (_quantity > 1) setState(() => _quantity--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildSmallButton(Icons.add, () => setState(() => _quantity++), color: LumiereColors.orangePrimary, iconColor: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSmallButton(IconData icon, VoidCallback onTap, {Color? color, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? LumiereColors.darkGray, size: 20),
      ),
    );
  }

  Widget _buildCustomOption(CustomizationOption option) {
    final isSelected = _selectedCustomizations.contains(option.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: LumiereColors.orangePrimary, width: 2) : Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) {
          setState(() {
            if (isSelected) {
              _selectedCustomizations.remove(option.name);
            } else {
              _selectedCustomizations.add(option.name);
            }
          });
        },
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: LumiereColors.orangePrimary,
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: LumiereColors.creamBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, color: LumiereColors.darkGray, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.name,
                style: const TextStyle(fontWeight: FontWeight.bold, color: LumiereColors.darkGray),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '+\$${option.price.toStringAsFixed(2)}',
          style: const TextStyle(color: LumiereColors.lightGray, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String value, String label) {
    return Expanded(
      child: GlassCard(
        borderRadius: 16,
        opacity: 0.6,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: LumiereColors.darkGray)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: LumiereColors.lightGray, fontSize: 10, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }
}
