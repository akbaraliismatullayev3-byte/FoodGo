import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../core/theme.dart';

class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final tags = productProvider.products.map((p) => p.tag).where((t) => t.isNotEmpty).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: tags.isEmpty
          ? const Center(child: Text('No categories found. Add products with tags to create categories.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: LumiereColors.orangePrimary.withOpacity(0.1),
                      child: const Icon(Icons.tag, color: LumiereColors.orangePrimary, size: 20),
                    ),
                    title: Text(tag, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${productProvider.products.where((p) => p.tag == tag).length} Products'),
                    trailing: const Icon(Icons.chevron_right, color: LumiereColors.lightGray),
                  ),
                );
              },
            ),
    );
  }
}
