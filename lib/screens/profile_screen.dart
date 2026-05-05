import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_go/providers/language_provider.dart';
import 'package:food_go/screens/extra_screens.dart';
import 'package:food_go/screens/orders_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  File? _localImageFile;
  final ImagePicker _picker = ImagePicker();

  // ──── Rasm tanlash ────────────────────────────────────────────
  Future<void> _pickImage() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _localImageFile = File(picked.path));
    }
  }

  // ──── Profilni tahrirlash dialog ──────────────────────────────
  void _showEditProfileDialog(BuildContext context, String currentName) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final controller = TextEditingController(text: currentName);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Text(
                context.t('edit_profile'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : LumiereColors.darkGray,
                ),
              ),
              const SizedBox(height: 20),

              // Avatar picker row
              GestureDetector(
                onTap: _pickImage,
                child: Row(
                  children: [
                    _buildAvatarWidget(
                      authProvider: authProvider,
                      radius: 36,
                      showEdit: false,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('edit_profile'),
                          style: const TextStyle(
                              color: LumiereColors.orangePrimary,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'JPG, PNG',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: LumiereColors.orangePrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: LumiereColors.orangePrimary, size: 20),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Name field
              Text(
                context.t('full_name'),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: LumiereColors.lightGray,
                    letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDark ? Colors.white : LumiereColors.darkGray,
                ),
                decoration: InputDecoration(
                  hintText: context.t('enter_name'),
                  hintStyle: const TextStyle(
                      color: LumiereColors.lightGray, fontSize: 14),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: LumiereColors.orangePrimary),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 16),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LumiereColors.luxuryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: LumiereColors.orangePrimary.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      // Ismni saqlash (Firebase update)
                      final newName = controller.text.trim();
                      if (newName.isNotEmpty) {
                        authProvider.user?.updateDisplayName(newName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.white),
                                SizedBox(width: 10),
                                Text('Profil yangilandi!'),
                              ],
                            ),
                            backgroundColor: LumiereColors.orangePrimary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Saqlash',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──── Avatar widget ───────────────────────────────────────────
  Widget _buildAvatarWidget({
    required AuthProvider authProvider,
    double radius = 60,
    bool showEdit = true,
  }) {
    final gender = authProvider.profile?.gender ?? 'Erkak';
    final defaultUrl = gender == 'Ayol'
        ? 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&auto=format&fit=crop'
        : 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=200&auto=format&fit=crop';

    final avatar = _localImageFile != null
        ? CircleAvatar(
            radius: radius,
            backgroundImage: FileImage(_localImageFile!),
          )
        : CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(defaultUrl),
          );

    if (!showEdit) return avatar;

    return Stack(
      children: [
        avatar,
        // Edit badge
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LumiereColors.luxuryGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: LumiereColors.orangePrimary.withOpacity(0.4),
                      blurRadius: 8)
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final profile = authProvider.profile;
    final displayName = authProvider.displayName ?? context.t('full_name');
    final email = profile?.email ?? authProvider.user?.email ?? '';
    final gender = profile?.gender ?? 'Erkak';

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final settingsCardColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.7);
    final textColor = isDark ? Colors.white : LumiereColors.darkGray;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Premium Profile Header ─────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.fromLTRB(24, 20, 24, 40),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LumiereColors.luxuryGradient,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark
                              ? const Color(0xFF1A1A2E)
                              : LumiereColors.orangePrimary)
                          .withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Top Row
                    Row(
                      children: [
                        const Icon(Icons.menu_rounded,
                            color: Colors.white70, size: 26),
                        const Spacer(),
                        const Text(
                          'Profil',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              color: Colors.white70),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Avatar with edit button
                    _buildAvatarWidget(
                      authProvider: authProvider,
                      radius: 56,
                      showEdit: true,
                    ).animate().scale(
                        duration: 600.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 16),

                    // Name (tap to edit)
                    GestureDetector(
                      onTap: () =>
                          _showEditProfileDialog(context, displayName),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded,
                                color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 6),
                    Text(
                      email.isNotEmpty ? email : 'Profil sozlang',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            context.t('gold_member'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Edit profile button
                    GestureDetector(
                      onTap: () =>
                          _showEditProfileDialog(context, displayName),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          context.t('edit_profile'),
                          style: const TextStyle(
                            color: LumiereColors.orangePrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Stats Cards ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const OrdersScreen())),
                        child: _buildStatCard(
                          icon: Icons.receipt_long_rounded,
                          title: context.t('order_history'),
                          value: '12',
                          subtitle: context.t('orders'),
                          color: LumiereColors.orangePrimary,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.favorite_rounded,
                        title: context.t('favorites'),
                        value: '24',
                        subtitle: context.t('favorites'),
                        color: Colors.redAccent,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department_rounded,
                        title: 'Bonuslar',
                        value: '350',
                        subtitle: 'ball',
                        color: Colors.amber.shade700,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
              ),

              const SizedBox(height: 28),

              // ── Settings Section ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('settings'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dark mode toggle
                    _buildSettingsToggle(
                      icon: isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_outlined,
                      title: context.t('dark_mode'),
                      value: themeProvider.isDarkMode,
                      onChanged: (v) => themeProvider.toggleTheme(v),
                      cardColor: settingsCardColor,
                      textColor: textColor,
                    ),

                    // Language selector
                    _buildLanguageSelector(
                        context, languageProvider, settingsCardColor, textColor),

                    // Notifications
                    _buildSettingsToggle(
                      icon: Icons.notifications_outlined,
                      title: 'Bildirishnomalar',
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                      cardColor: settingsCardColor,
                      textColor: textColor,
                    ),

                    const SizedBox(height: 6),
                    _buildSettingsTile(
                      Icons.info_outline_rounded,
                      context.t('about_us'),
                      cardColor: settingsCardColor,
                      textColor: textColor,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutScreen())),
                    ),
                    _buildSettingsTile(
                      Icons.contact_support_outlined,
                      context.t('contact_us'),
                      cardColor: settingsCardColor,
                      textColor: textColor,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ContactScreen())),
                    ),
                    _buildSettingsTile(
                      Icons.newspaper_outlined,
                      context.t('news'),
                      cardColor: settingsCardColor,
                      textColor: textColor,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewsScreen())),
                    ),
                    _buildSettingsTile(
                      Icons.article_outlined,
                      'Blog',
                      cardColor: settingsCardColor,
                      textColor: textColor,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BlogScreen())),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 32),

              // ── Logout ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        backgroundColor:
                            isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        title: Text(context.t('logout'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        content: Text(context.t('logout_confirm'),
                            style: TextStyle(color: Colors.grey.shade500)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(context.t('no'),
                                style: const TextStyle(
                                    color: LumiereColors.lightGray)),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await authProvider.signOut();
                            },
                            child: Text(context.t('yes'),
                                style: const TextStyle(
                                    color: LumiereColors.redAccent,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: LumiereColors.redAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: LumiereColors.redAccent.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: LumiereColors.redAccent),
                        const SizedBox(width: 10),
                        Text(
                          context.t('logout'),
                          style: const TextStyle(
                            color: LumiereColors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helper widgets ──────────────────────────────────────────

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : LumiereColors.darkGray,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 11, color: LumiereColors.lightGray),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context,
      LanguageProvider provider,
      Color cardColor,
      Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.language_rounded,
                color: LumiereColors.orangePrimary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              context.t('language'),
              style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
          DropdownButton<AppLanguage>(
            value: provider.currentLanguage,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(12),
            items: const [
              DropdownMenuItem(
                  value: AppLanguage.uz, child: Text('🇺🇿 UZ')),
              DropdownMenuItem(
                  value: AppLanguage.ru, child: Text('🇷🇺 RU')),
              DropdownMenuItem(
                  value: AppLanguage.en, child: Text('🇬🇧 EN')),
            ],
            onChanged: (lang) {
              if (lang != null) provider.setLanguage(lang);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsToggle({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: LumiereColors.orangePrimary, size: 18),
        ),
        title: Text(title,
            style: TextStyle(
                fontSize: 15, color: textColor, fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        activeColor: LumiereColors.orangePrimary,
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: LumiereColors.orangePrimary, size: 18),
        ),
        title: Text(title,
            style: TextStyle(
                fontSize: 15, color: textColor, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: LumiereColors.lightGray),
        onTap: onTap ?? () {},
      ),
    );
  }
}
