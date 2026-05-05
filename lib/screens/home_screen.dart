import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/product_provider.dart';
import '../providers/language_provider.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../services/gemini_service.dart';
import 'food_detail_screen.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/lumiere_drawer.dart';
import '../widgets/ai_chat_sheet.dart';

class HomeScreen extends StatefulWidget {
  final FocusNode? searchFocusNode;
  const HomeScreen({super.key, this.searchFocusNode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> _getCategories(BuildContext context, List<Product> products) {
    // 1. Get unique tags from products
    final Set<String> tags = products.map((p) => p.tag).where((t) => t.isNotEmpty).toSet();
    
    // 2. Build categories list starting with "All"
    final List<Map<String, dynamic>> categories = [
      {'name': 'All', 'icon': Icons.apps_rounded, 'gradient': LumiereColors.allGradient, 'label': context.t('see_all')},
    ];

    // 3. Map tags to UI data
    for (final tag in tags) {
      if (tag.toLowerCase() == 'all') continue;
      categories.add({
        'name': tag,
        'icon': _getCategoryIcon(tag),
        'gradient': _getCategoryGradient(tag),
        'label': tag, // Or translate if you have a mapping
      });
    }

    return categories;
  }

  IconData _getCategoryIcon(String tag) {
    final t = tag.toLowerCase();
    if (t.contains('burger')) return Icons.lunch_dining;
    if (t.contains('piz')) return Icons.local_pizza;
    if (t.contains('sushi') || t.contains('roll')) return Icons.set_meal;
    if (t.contains('dessert') || t.contains('sweet')) return Icons.icecream;
    if (t.contains('drink') || t.contains('bev')) return Icons.local_drink;
    if (t.contains('pasta')) return Icons.restaurant;
    return Icons.flatware_rounded;
  }

  LinearGradient _getCategoryGradient(String tag) {
    final t = tag.toLowerCase();
    if (t.contains('burger')) return LumiereColors.burgerGradient;
    if (t.contains('piz')) return LumiereColors.pizzaGradient;
    if (t.contains('sushi') || t.contains('roll')) return LumiereColors.sushiGradient;
    if (t.contains('dessert') || t.contains('sweet')) return LumiereColors.dessertGradient;
    return LumiereColors.allGradient;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    var result = products;
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        p.tag.toLowerCase().contains(q)
      ).toList();
    }
    if (_selectedCategory != 'All') {
      result = result.where((p) =>
        p.tag.toLowerCase() == _selectedCategory.toLowerCase() ||
        p.tag.toLowerCase().contains(_selectedCategory.toLowerCase().replaceAll('s', ''))
      ).toList();
    }
    return result;
  }

  void _showAiChat(List<Product> products) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiChatSheet(products: products),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final filteredProducts = _filterProducts(productProvider.products);
    final popularProducts = filteredProducts.where((p) => p.rating >= 4.8).toList();
    final featuredProduct = popularProducts.isNotEmpty
        ? popularProducts.first
        : filteredProducts.isNotEmpty
            ? filteredProducts.first
            : (productProvider.products.isNotEmpty ? productProvider.products.first : null);
    final quickPicks = filteredProducts.take(2).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'ai_fab',
            mini: true,
            backgroundColor: const Color(0xFF1A1A2E),
            elevation: 6,
            onPressed: () => _showAiChat(productProvider.products),
            child: const Text('G', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                children: [
                  Builder(builder: (context) {
                    return _buildIconShell(
                      icon: Icons.menu_rounded, 
                      onTap: () => Scaffold.of(context).openDrawer(),
                    );
                  }),
                  const Spacer(),
                  Column(
                    children: [
                      Text('Lumiere',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: LumiereColors.lightGray, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
                      Text('Gastronomy',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: LumiereColors.orangePrimary, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=300&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 8))],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 60.ms).slideY(begin: -0.08),

              const SizedBox(height: 24),

              Text('Find your next\nsignature meal',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  height: 1.08, fontWeight: FontWeight.w700),
              ).animate().fadeIn(delay: 120.ms).slideX(begin: -0.06),

              const SizedBox(height: 6),

              Text('Restaurant quality dishes, curated for comfort and delivered with style.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LumiereColors.lightGray.withOpacity(0.9), height: 1.4),
              ).animate().fadeIn(delay: 160.ms),

              const SizedBox(height: 22),

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 18, offset: const Offset(0, 8))],
                        border: Border.all(color: Colors.black.withOpacity(0.02)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: widget.searchFocusNode,
                        onChanged: (v) => setState(() => _query = v),
                        cursorColor: LumiereColors.orangePrimary,
                        style: const TextStyle(
                          color: LumiereColors.darkGray, 
                          fontWeight: FontWeight.w600, 
                          fontSize: 16
                        ),
                        decoration: InputDecoration(
                          hintText: context.t('search_hint'),
                          hintStyle: TextStyle(
                            color: LumiereColors.lightGray.withOpacity(0.6), 
                            fontSize: 14, 
                            fontWeight: FontWeight.w400
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, color: LumiereColors.orangePrimary, size: 24),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 17),
                          suffixIcon: _query.trim().isEmpty ? null : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20, color: LumiereColors.lightGray),
                            onPressed: () { 
                              _searchController.clear(); 
                              setState(() {
                                _query = '';
                              }); 
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildFilterButton(),
                ],
              ).animate().fadeIn(delay: 160.ms),

              const SizedBox(height: 22),

              _buildBannerCarousel(context),

              const SizedBox(height: 22),

              // Categories (tap to filter)
              _CategorySection(
                selectedCategory: _selectedCategory,
                categories: _getCategories(context, productProvider.products),
                onSelected: (cat) => setState(() => _selectedCategory = cat),
              ),

              const SizedBox(height: 24),

              // Grok AI Banner
              GestureDetector(
                onTap: () => _showAiChat(productProvider.products),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFF1A1A2E).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Center(
                          child: Text('G', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Grok AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: LumiereColors.orangePrimary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('YANGI', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(context.t('type_message'),
                              style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 2),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05),
              ),

              const SizedBox(height: 24),

              if (featuredProduct != null) ...[
                _SectionHeader(title: context.t('recommended'), action: context.t('see_all'), onTap: () {}),
                const SizedBox(height: 16),
                _FeaturedFoodCard(product: featuredProduct).animate().fadeIn(delay: 220.ms).slideY(begin: 0.08),
                const SizedBox(height: 26),
              ],

              if (quickPicks.length >= 2)
                Row(
                  children: quickPicks.map((product) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: product == quickPicks.first ? 10 : 0,
                        left: product == quickPicks.last ? 10 : 0,
                      ),
                      child: _QuickPickCard(product: product),
                    ),
                  )).toList(),
                ),

              const SizedBox(height: 16),

              _SectionHeader(title: context.t('restaurants'), action: context.t('see_all'), onTap: () {}),
              const SizedBox(height: 14),
              Column(children: _restaurantMocks.map((r) => _RestaurantCard(restaurant: r)).toList()),
              const SizedBox(height: 18),

              _SectionHeader(title: context.t('trending'), action: context.t('see_all'), onTap: () {}),
              const SizedBox(height: 14),

              // Optimized Filtering View
              if (_selectedCategory != 'All' || _query.isNotEmpty)
                productProvider.isLoading 
                  ? _buildSkeletonGrid()
                  : (filteredProducts.isEmpty
                      ? Center(child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(context.t('no_results'), style: const TextStyle(color: LumiereColors.lightGray)),
                        ))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.78,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) => _PopularCard(product: filteredProducts[index]).animate().fadeIn(delay: (index * 50).ms),
                        ))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 268,
                      child: productProvider.isLoading 
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) => const SkeletonCard(),
                          )
                        : (popularProducts.isEmpty
                            ? Center(child: Text(context.t('no_results'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: LumiereColors.lightGray, fontWeight: FontWeight.w600)))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: popularProducts.length,
                                itemBuilder: (context, index) => _PopularCard(product: popularProducts[index]),
                              )),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'All Dishes', action: '', onTap: null),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: productProvider.products.length,
                      itemBuilder: (context, index) => _PopularCard(product: productProvider.products[index]),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    final banners = productProvider.banners.isNotEmpty ? productProvider.banners : [
      BannerItem(
        id: '1',
        title: context.t('banner_promo'),
        subtitle: '50% OFF',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=600&auto=format&fit=crop',
        gradientColors: [const Color(0xFFFF5F6D), const Color(0xFFFFC371)],
        tag: 'HOT',
      ),
      BannerItem(
        id: '2',
        title: context.t('banner_free'),
        subtitle: 'Lumière Exclusive',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=600&auto=format&fit=crop',
        gradientColors: [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
        tag: 'NEW',
      ),
      BannerItem(
        id: '3',
        title: context.t('banner_new'),
        subtitle: 'Artisan Pasta',
        imageUrl: 'https://images.unsplash.com/photo-1473093226795-af9932fe5856?q=80&w=600&auto=format&fit=crop',
        gradientColors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      ),
    ];

    return CarouselSlider.builder(
      itemCount: banners.length,
      itemBuilder: (context, index, realIndex) {
        final banner = banners[index];
        return _buildBannerCard(context, banner);
      },
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.92,
        autoPlay: true,
        autoPlayInterval: 5.seconds,
        autoPlayAnimationDuration: 800.ms,
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.2,
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, BannerItem banner) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: banner.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: banner.gradientColors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background "Dancing" Food Image
          Positioned(
            right: -30,
            bottom: -20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                banner.imageUrl,
                height: 220,
                width: 220,
                fit: BoxFit.contain,
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 4.seconds, curve: Curves.easeInOut)
              .moveY(begin: 0, end: -10, duration: 3.seconds, curve: Curves.easeInOut),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (banner.tag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      banner.tag!,
                      style: TextStyle(
                        color: banner.gradientColors.first,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                const SizedBox(height: 12),
                Text(
                  banner.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (banner.productId != null) {
                      final productProvider = Provider.of<ProductProvider>(context, listen: false);
                      try {
                        final product = productProvider.products.firstWhere((p) => p.id == banner.productId);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetailScreen(product: product)));
                      } catch (_) {
                        // Product not found or error
                      }
                    } else if (banner.category != null) {
                      setState(() => _selectedCategory = banner.category!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: banner.gradientColors.first,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    context.t('order_now'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(),
              ],
            ),
          ),
        ],
      ),
    ).animate().shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.1));
  }

  Widget _buildIconShell({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 8))],
        ),
        child: Icon(icon, size: 20, color: LumiereColors.darkGray),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        gradient: LumiereColors.luxuryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: LumiereColors.orangePrimary.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 10))],
      ),
      child: const Icon(Icons.tune_rounded, color: Colors.white),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }
}

// ─────────────────────────────────────────────
// ADMIN QUICK ADD SHEET
// ─────────────────────────────────────────────

class _AdminQuickAddSheet extends StatefulWidget {
  final String initialCategory;
  const _AdminQuickAddSheet({required this.initialCategory});

  @override
  State<_AdminQuickAddSheet> createState() => _AdminQuickAddSheetState();
}

class _AdminQuickAddSheetState extends State<_AdminQuickAddSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late String _selectedTag;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.initialCategory;
  }
  bool _isLoading = false;

  final _tags = ['Burgers', 'Pizza', 'Sushi', 'Dessert'];

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _imageUrlCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, ism, narx va rasm URLini kiriting')));
      return;
    }
    setState(() => _isLoading = true);

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text,
      description: _descCtrl.text.isNotEmpty ? _descCtrl.text : 'Lumière oshxonasidan yangi taom.',
      imageUrl: _imageUrlCtrl.text,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      rating: 4.8,
      reviews: 0,
      calories: 400,
      protein: '12g',
      tag: _selectedTag,
    );

    await Provider.of<ProductProvider>(context, listen: false).addProduct(product);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mahsulot galereya qo\'shildi! 🎉'),
          backgroundColor: LumiereColors.orangePrimary,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(100)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t('add_product'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Rasm URL orqali qo\'shiladi', style: TextStyle(color: LumiereColors.lightGray)),
                  const SizedBox(height: 24),

                  // Image URL preview
                  _buildField(context.t('product_image'), _imageUrlCtrl, 'https://example.com/food.jpg'),
                  if (_imageUrlCtrl.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(_imageUrlCtrl.text, height: 160, width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 80, color: Colors.grey.shade100,
                            child: const Icon(Icons.broken_image, color: LumiereColors.lightGray)),
                        ),
                      ),
                    ),

                  _buildField(context.t('product_name'), _nameCtrl, 'masalan: Royal Burger'),
                  _buildField(context.t('product_price'), _priceCtrl, '14.99', keyboardType: TextInputType.number),
                  _buildField(context.t('description'), _descCtrl, 'Taom haqida qisqacha...', maxLines: 2),

                  const SizedBox(height: 4),
                  Text(context.t('categories'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: LumiereColors.lightGray)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _tags.map((tag) {
                      final isSelected = _selectedTag == tag;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTag = tag),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected ? LumiereColors.luxuryGradient : null,
                            color: isSelected ? null : LumiereColors.creamBg,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.grey.shade200),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected ? Colors.white : LumiereColors.darkGray,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LumiereColors.luxuryGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: LumiereColors.orangePrimary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
                      ),
                      child: MaterialButton(
                        onPressed: _isLoading ? null : _save,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Text(context.t('save_to_gallery'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: LumiereColors.lightGray)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: LumiereColors.lightGray, fontSize: 14),
              filled: true,
              fillColor: LumiereColors.creamBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
  }



class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: LumiereColors.darkGray,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: TextStyle(
              color: LumiereColors.orangePrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedFoodCard extends StatelessWidget {
  final Product product;

  const _FeaturedFoodCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FoodDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Image.network(
                    product.imageUrl,
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.45),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: LumiereColors.darkGray,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: LumiereColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Premium chef-crafted signature bowl',
                          style: TextStyle(
                            color: LumiereColors.lightGray,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: LumiereColors.orangePrimary,
                    ),
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

class _QuickPickCard extends StatelessWidget {
  final Product product;

  const _QuickPickCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FoodDetailScreen(product: product)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.imageUrl,
                height: 116,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: LumiereColors.darkGray,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: LumiereColors.orangePrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: LumiereColors.darkGray,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  final Product product;
  const _PopularCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetailScreen(product: product))),
      child: Container(
        width: 212,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(product.imageUrl, height: 146, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: LumiereColors.darkGray),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Curated by Lumiere Kitchen', style: TextStyle(color: LumiereColors.lightGray, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: LumiereColors.orangePrimary)),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(color: LumiereColors.darkGray, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
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

class _RestaurantCard extends StatelessWidget {
  final _Restaurant restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _RestaurantDetailView(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                restaurant.imageUrl,
                width: 78,
                height: 78,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            color: LumiereColors.darkGray,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.rating,
                        style: const TextStyle(
                          color: LumiereColors.darkGray,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.subtitle,
                    style: const TextStyle(
                      color: LumiereColors.lightGray,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        restaurant.badge,
                        style: const TextStyle(
                          color: LumiereColors.orangePrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        restaurant.deliveryTime,
                        style: const TextStyle(
                          color: LumiereColors.lightGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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


class _Restaurant {
  final String name;
  final String subtitle;
  final String rating;
  final String deliveryTime;
  final String badge;
  final String imageUrl;

  const _Restaurant({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.deliveryTime,
    required this.badge,
    required this.imageUrl,
  });
}

const List<_Restaurant> _restaurantMocks = [
  _Restaurant(
    name: 'The Urban Kitchen',
    subtitle: 'European • Contemporary',
    rating: '4.8',
    deliveryTime: '20-30 min',
    badge: 'FREE DELIVERY',
    imageUrl: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?q=80&w=600&auto=format&fit=crop',
  ),
  _Restaurant(
    name: 'Sushi Zen Master',
    subtitle: 'Japanese • Authentic',
    rating: '4.9',
    deliveryTime: '35-45 min',
    badge: 'MIN ORDER \$20',
    imageUrl: 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?q=80&w=600&auto=format&fit=crop',
  ),
  _Restaurant(
    name: 'Baker Street Co.',
    subtitle: 'Pastries • Coffee',
    rating: '4.6',
    deliveryTime: '15-20 min',
    badge: 'TOP RATED',
    imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=600&auto=format&fit=crop',
  ),
];
// Interactive Category Section
class _CategorySection extends StatelessWidget {
  final String selectedCategory;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<String> onSelected;

  const _CategorySection({
    required this.selectedCategory,
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: context.t('categories'), action: context.t('see_all')),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((c) {
              final name = c['name'] as String;
              final gradient = c['gradient'] as LinearGradient;
              final firstColor = gradient.colors.first;
              final isActive = name == selectedCategory;
              return GestureDetector(
                onTap: () => onSelected(name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isActive ? gradient : null,
                    color: isActive ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isActive
                            ? firstColor.withOpacity(0.45)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: isActive ? 18 : 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon with gradient container when inactive
                      if (!isActive)
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            c['icon'] as IconData,
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(
                          c['icon'] as IconData,
                          size: 20,
                          color: Colors.white,
                        ),
                      const SizedBox(width: 10),
                      Text(
                        c['label'] as String,
                        style: TextStyle(
                          color: isActive ? Colors.white : LumiereColors.darkGray,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RestaurantDetailView extends StatelessWidget {
  final _Restaurant restaurant;
  const _RestaurantDetailView({required this.restaurant});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(restaurant.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              centerTitle: true,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(restaurant.subtitle, style: const TextStyle(color: LumiereColors.lightGray, fontSize: 15)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: LumiereColors.orangePrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(restaurant.badge, style: const TextStyle(color: LumiereColors.orangePrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.timer_outlined, size: 16, color: LumiereColors.lightGray),
                              const SizedBox(width: 4),
                              Text(restaurant.deliveryTime, style: const TextStyle(color: LumiereColors.lightGray, fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Column(children: [const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 22), Text(restaurant.rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  const Text('Tavsif', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LumiereColors.darkGray)),
                  const SizedBox(height: 12),
                  Text('${restaurant.name} - bu ${restaurant.subtitle} yo\'nalishidagi eng sara taomlarni taqdim etuvchi restoran.', style: const TextStyle(color: LumiereColors.lightGray, fontSize: 14, height: 1.5)).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 28),
                  const Text('Manzil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LumiereColors.darkGray)),
                  const SizedBox(height: 12),
                  ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network('https://images.unsplash.com/photo-1526778548025-fa2f459cd5ce?q=80&w=600&auto=format&fit=crop', height: 160, width: double.infinity, fit: BoxFit.cover)).animate().fadeIn(delay: 200.ms).scale(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: LumiereColors.orangePrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4),
                      child: const Text('Stol band qilish', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
