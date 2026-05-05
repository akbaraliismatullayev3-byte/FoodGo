import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../screens/extra_screens.dart';

class LumiereDrawer extends StatelessWidget {
  const LumiereDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final email = user?.email ?? 'akbar@gmail.com';
    const boyAvatar = 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=200&auto=format&fit=crop';

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            decoration: const BoxDecoration(
              gradient: LumiereColors.luxuryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(boyAvatar),
                  backgroundColor: Colors.white,
                ).animate().scale(duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  'Your name',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms),
                Text(
                  email,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildDrawerTile(context, Icons.home_rounded, context.t('home'), () => Navigator.pop(context)),
                _buildDrawerTile(context, Icons.newspaper_rounded, context.t('news'), () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen()));
                }),
                _buildDrawerTile(context, Icons.info_rounded, context.t('about_us'), () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                }),
                _buildDrawerTile(context, Icons.contact_support_rounded, context.t('contact_us'), () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
                }),
                const Divider(indent: 24, endIndent: 24, height: 40),
                _buildDrawerTile(context, Icons.logout_rounded, context.t('logout'), () {
                  Navigator.pop(context);
                  authProvider.signOut();
                }, color: LumiereColors.redAccent),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Lumière Gastronomy v1.0.4',
              style: TextStyle(color: LumiereColors.lightGray, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? LumiereColors.darkGray, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? LumiereColors.darkGray,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1);
  }
}
