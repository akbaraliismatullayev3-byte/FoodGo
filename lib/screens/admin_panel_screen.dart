import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/banner_model.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../services/firebase_service.dart';
import '../core/theme.dart';
import '../widgets/lumiere_button.dart';
import '../models/extra_content_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: LumiereColors.creamBg,
        appBar: AppBar(
          title: const Text('Lumière Admin', style: TextStyle(color: LumiereColors.darkGray, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: LumiereColors.darkGray),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: LumiereColors.orangePrimary,
            unselectedLabelColor: LumiereColors.lightGray,
            indicatorColor: LumiereColors.orangePrimary,
            tabs: [
              Tab(text: 'Products', icon: Icon(Icons.restaurant_menu)),
              Tab(text: 'Banners', icon: Icon(Icons.campaign_outlined)),
              Tab(text: 'News', icon: Icon(Icons.newspaper_outlined)),
              Tab(text: 'Blog', icon: Icon(Icons.article_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductsList(context, productProvider),
            _buildBannersList(context, productProvider),
            _buildExtraContentList(context, 'news'),
            _buildExtraContentList(context, 'blog'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, ProductProvider provider) {
    if (provider.products.isEmpty) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: provider.products.length,
        itemBuilder: (context, index) => _buildProductTile(context, provider.products[index]),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_product',
        onPressed: () => _showProductForm(context),
        backgroundColor: LumiereColors.orangePrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBannersList(BuildContext context, ProductProvider provider) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: provider.banners.isEmpty 
          ? const Center(child: Text('No banners curated yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.banners.length,
              itemBuilder: (context, index) => _buildBannerTile(context, provider.banners[index]),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_banner',
        onPressed: () => _showBannerForm(context),
        backgroundColor: LumiereColors.orangePrimary,
        child: const Icon(Icons.campaign, color: Colors.white),
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('\$${product.price.toStringAsFixed(2)} - ${product.tag}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: LumiereColors.lightGray), onPressed: () => _showProductForm(context, product: product)),
            IconButton(icon: const Icon(Icons.delete_outline, color: LumiereColors.redAccent), onPressed: () => _showDeleteConfirmation(context, product.id, isProduct: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerTile(BuildContext context, BannerItem banner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(banner.imageUrl, width: 80, height: 50, fit: BoxFit.cover),
        ),
        title: Text(banner.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(banner.tag ?? 'Promotion'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: LumiereColors.redAccent),
          onPressed: () => _showDeleteConfirmation(context, banner.id, isProduct: false),
        ),
      ),
    );
  }

  Widget _buildExtraContentList(BuildContext context, String type) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<ExtraContent>>(
        stream: _firestoreService.getExtraContent(type),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          if (items.isEmpty) return Center(child: Text('No ${type} posts yet.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: LumiereColors.redAccent),
                    onPressed: () {
                      _firestoreService.deleteExtraContent(item.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_${type}',
        onPressed: () => _showExtraContentForm(context, type),
        backgroundColor: LumiereColors.orangePrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showExtraContentForm(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExtraContentForm(type: type, firestoreService: _firestoreService),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id, {required bool isProduct}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isProduct ? 'Delete Product' : 'Delete Banner'),
        content: const Text('Are you sure you want to remove this?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (isProduct) {
                Provider.of<ProductProvider>(context, listen: false).deleteProduct(id);
              } else {
                Provider.of<ProductProvider>(context, listen: false).deleteBanner(id);
              }
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: LumiereColors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductForm(product: product, firestoreService: _firestoreService),
    );
  }

  void _showBannerForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BannerForm(firestoreService: _firestoreService),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final Product? product;
  final FirestoreService firestoreService;

  const _ProductForm({this.product, required this.firestoreService});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _tagController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  XFile? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _tagController = TextEditingController(text: widget.product?.tag ?? 'Burgers');
    _caloriesController = TextEditingController(text: widget.product?.calories.toString() ?? '400');
    _proteinController = TextEditingController(text: widget.product?.protein ?? '12g');
    _currentImageUrl = widget.product?.imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = _currentImageUrl ?? '';
      if (_selectedImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await widget.firestoreService.uploadProductImage(fileName, _selectedImage);
      }

      final newProduct = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descController.text,
        imageUrl: imageUrl,
        price: double.tryParse(_priceController.text) ?? 0.0,
        rating: widget.product?.rating ?? 4.5,
        reviews: widget.product?.reviews ?? 0,
        calories: int.tryParse(_caloriesController.text) ?? 400,
        protein: _proteinController.text,
        tag: _tagController.text,
      );

      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (widget.product == null) {
        await provider.addProduct(newProduct);
      } else {
        await provider.updateProduct(newProduct);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product == null ? 'Curation New Dish' : 'Refine Creation',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: LumiereColors.creamBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: LumiereColors.orangePrimary.withOpacity(0.3)),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(_selectedImage!.path, fit: BoxFit.cover)) // Note: on web/mobile path handling differs, but pickImage usually provides a local path or data
                      : (_currentImageUrl != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(_currentImageUrl!, fit: BoxFit.cover))
                          : const Icon(Icons.add_a_photo_outlined, size: 40, color: LumiereColors.orangePrimary)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildField('Dish Name', _nameController, 'e.g. Truffle Symphony'),
            _buildField('Price (\$)', _priceController, 'e.g. 18.50', keyboardType: TextInputType.number),
            _buildField('Description', _descController, 'Curation details...', maxLines: 3),
            
            // Category Dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: LumiereColors.lightGray)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: ['Burgers', 'Pizza', 'Sushi', 'Dessert'].contains(_tagController.text) ? _tagController.text : 'Burgers',
                    items: ['Burgers', 'Pizza', 'Sushi', 'Dessert'].map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(fontSize: 14)),
                    )).toList(),
                    onChanged: (v) => setState(() => _tagController.text = v!),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: LumiereColors.creamBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Expanded(child: _buildField('Calories', _caloriesController, '400', keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Protein', _proteinController, '12g')),
              ],
            ),
            const SizedBox(height: 40),
            LumiereButton(
              text: widget.product == null ? 'Add to Gallery' : 'Update Masterpiece',
              isLoading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: LumiereColors.lightGray)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: LumiereColors.lightGray, fontSize: 14),
              filled: true,
              fillColor: LumiereColors.creamBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerForm extends StatefulWidget {
  final FirestoreService firestoreService;
  const _BannerForm({required this.firestoreService});

  @override
  State<_BannerForm> createState() => _BannerFormState();
}

class _BannerFormState extends State<_BannerForm> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _tagController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _imageUrlController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final newBanner = BannerItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      subtitle: _subtitleController.text,
      tag: _tagController.text.isNotEmpty ? _tagController.text : null,
      imageUrl: _imageUrlController.text,
      gradientColors: [const Color(0xFFFF5F6D), const Color(0xFFFFC371)],
    );

    await Provider.of<ProductProvider>(context, listen: false).addBanner(newBanner);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Curate Banner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildField('Title', _titleController, 'e.g. 50% OFF'),
          _buildField('Subtitle', _subtitleController, 'e.g. Use code LUMIERE'),
          _buildField('Tag (Optional)', _tagController, 'e.g. NEW'),
          _buildField('Image URL', _imageUrlController, 'https://...'),
          const Spacer(),
          LumiereButton(text: 'Publish Banner', isLoading: _isLoading, onPressed: _save),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: LumiereColors.lightGray)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: LumiereColors.creamBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
class _ExtraContentForm extends StatefulWidget {
  final String type;
  final FirestoreService firestoreService;
  const _ExtraContentForm({required this.type, required this.firestoreService});

  @override
  State<_ExtraContentForm> createState() => _ExtraContentFormState();
}

class _ExtraContentFormState extends State<_ExtraContentForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _imageUrlController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final content = ExtraContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      imageUrl: _imageUrlController.text,
      type: widget.type,
      date: DateTime.now(),
    );

    await widget.firestoreService.addExtraContent(content);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text('Create ${widget.type.toUpperCase()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildField('Title', _titleController, 'Post title...'),
            _buildField('Content', _contentController, 'Write something...', maxLines: 5),
            _buildField('Image URL', _imageUrlController, 'https://...'),
            const SizedBox(height: 40),
            LumiereButton(text: 'Publish', isLoading: _isLoading, onPressed: _save),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: LumiereColors.lightGray)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: LumiereColors.creamBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
