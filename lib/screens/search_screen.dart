import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/product_provider.dart';
import '../providers/language_provider.dart';
import '../models/product_model.dart';
import 'food_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> _getCategories(BuildContext context) => [
    {'name': 'All',     'icon': Icons.apps_rounded,   'gradient': LumiereColors.allGradient, 'label': context.t('see_all')},
    {'name': 'Burgers', 'icon': Icons.lunch_dining,   'gradient': LumiereColors.burgerGradient, 'label': context.t('burgers')},
    {'name': 'Pizza',   'icon': Icons.local_pizza,    'gradient': LumiereColors.pizzaGradient, 'label': context.t('pizza')},
    {'name': 'Sushi',   'icon': Icons.set_meal,       'gradient': LumiereColors.sushiGradient, 'label': context.t('sushi')},
    {'name': 'Dessert', 'icon': Icons.icecream,       'gradient': LumiereColors.dessertGradient, 'label': context.t('desserts')},
  ];

  List<Product> _filterProducts(List<Product> products) {
    var result = products;
    final q = _query.trim().toLowerCase();
    
    // Text search
    if (q.isNotEmpty) {
      result = result.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q) ||
        p.tag.toLowerCase().contains(q)
      ).toList();
    }
    
    // Category filter
    if (_selectedCategory != 'All') {
      result = result.where((p) =>
        p.tag.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final results = _filterProducts(productProvider.products);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context),
            const SizedBox(height: 20),
            _buildCategoryFilter(context),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty 
                ? _buildEmptyState(context)
                : _buildResultsGrid(results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('search'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: LumiereColors.darkGray)),
          const SizedBox(height: 18),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: LumiereColors.creamBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              autofocus: true,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: context.t('search_hint'),
                hintStyle: const TextStyle(color: LumiereColors.lightGray, fontWeight: FontWeight.normal),
                prefixIcon: const Icon(Icons.search_rounded, color: LumiereColors.orangePrimary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                suffixIcon: _query.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: () { _searchController.clear(); setState(() => _query = ''); })
                  : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final categories = _getCategories(context);
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? (cat['gradient'] as LinearGradient) : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (isSelected) BoxShadow(color: (cat['gradient'] as LinearGradient).colors.first.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
                  if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Icon(cat['icon'], size: 18, color: isSelected ? Colors.white : LumiereColors.darkGray),
                  const SizedBox(width: 8),
                  Text(cat['label'], style: TextStyle(color: isSelected ? Colors.white : LumiereColors.darkGray, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductSearchCard(product: product).animate().fadeIn(delay: (index * 50).ms).scale();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded, size: 80, color: LumiereColors.lightGray.withOpacity(0.5)),
        const SizedBox(height: 20),
        Text(context.t('no_results'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LumiereColors.lightGray)),
      ],
    ).animate().fadeIn();
  }
}

class _ProductSearchCard extends StatelessWidget {
  final Product product;
  const _ProductSearchCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${product.price}', style: const TextStyle(fontWeight: FontWeight.w900, color: LumiereColors.orangePrimary)),
                      const Icon(Icons.add_circle_rounded, color: LumiereColors.orangePrimary, size: 24),
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
