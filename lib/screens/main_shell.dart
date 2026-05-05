import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_go/providers/language_provider.dart';
import 'package:food_go/screens/orders_screen.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/cart_provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../widgets/lumiere_drawer.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  Timer? _connectivityTimer;

  @override
  void initState() {
    super.initState();
    _startConnectivityCheck();
  }

  void _startConnectivityCheck() {
    _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        final isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        if (isOnline != _isOnline) {
          setState(() => _isOnline = isOnline);
        }
      } on SocketException catch (_) {
        if (_isOnline) setState(() => _isOnline = false);
      }
    });
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(),
      const SearchScreen(),
      const CartScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Scaffold(
          drawer: const LumiereDrawer(),
          body: Column(
            children: [
              if (!_isOnline)
                Container(
                  width: double.infinity,
                  color: LumiereColors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Center(
                    child: Text(
                      'No Internet Connection',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().slideY(begin: -1),
              Expanded(child: screens[_selectedIndex]),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home, context.t('home')),
                    _buildNavItem(1, Icons.search_outlined, Icons.search_rounded, context.t('search')),
                    _buildCartNavItem(
                      cartCount: cartProvider.itemCount,
                      index: 2,
                      icon: Icons.shopping_cart_outlined,
                      activeIcon: Icons.shopping_cart,
                      label: context.t('cart'),
                    ),
                    _buildNavItem(3, Icons.receipt_long_outlined, Icons.receipt_long, context.t('orders')),
                    _buildNavItem(4, Icons.person_outline, Icons.person, context.t('profile')),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? LumiereColors.orangePrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? LumiereColors.orangePrimary : LumiereColors.lightGray,
              size: 26,
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  color: LumiereColors.orangePrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int cartCount,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? LumiereColors.orangePrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? LumiereColors.orangePrimary : LumiereColors.lightGray,
                  size: 26,
                ),
                if (cartCount > 0)
                  Positioned(
                    right: -6,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: LumiereColors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  color: LumiereColors.orangePrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
