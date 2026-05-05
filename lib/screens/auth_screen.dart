import 'package:flutter/material.dart';
import 'package:food_go/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'akbar@gmail.com');
  final _passwordController = TextEditingController(text: 'akbar_007');
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    // Navigation
    final bool success = await authProvider.loginOrRegister(
        email, password, name.isEmpty ? 'Lumière User' : name);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainShell()),
        (route) => false,
      );
      return;
    }

    if (!success && mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: LumiereColors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Bar for Language & Theme
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Language Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<AppLanguage>(
                        value: languageProvider.currentLanguage,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.language, size: 18),
                        items: const [
                          DropdownMenuItem(value: AppLanguage.uz, child: Text('UZ')),
                          DropdownMenuItem(value: AppLanguage.ru, child: Text('RU')),
                          DropdownMenuItem(value: AppLanguage.en, child: Text('EN')),
                        ],
                        onChanged: (lang) {
                          if (lang != null) languageProvider.setLanguage(lang);
                        },
                      ),
                    ),
                    // Theme Toggle
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? Colors.orangeAccent : LumiereColors.darkGray,
                      ),
                      onPressed: () => themeProvider.toggleTheme(!isDark),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LumiereColors.luxuryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: LumiereColors.orangePrimary.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 36),
                        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        _isLogin ? context.t('welcome_back') : context.t('create_account'),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : LumiereColors.darkGray,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin ? context.t('sign_in_subtitle') : context.t('sign_up_subtitle'),
                        style: const TextStyle(fontSize: 16, color: LumiereColors.lightGray),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: 40),

                      // Name Field (only for signup)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isLogin
                            ? const SizedBox.shrink()
                            : Column(
                                key: const ValueKey('name_field'),
                                children: [
                                  _buildField(
                                    isDark: isDark,
                                    controller: _nameController,
                                    label: context.t('full_name'),
                                    icon: Icons.person_outline,
                                    validator: (v) => !_isLogin && (v == null || v.isEmpty) ? context.t('enter_name') : null,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                      ),

                      // Email Field
                      _buildField(
                        isDark: isDark,
                        controller: _emailController,
                        label: context.t('email_address'),
                        icon: Icons.alternate_email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t('enter_email');
                          if (!v.contains('@')) return context.t('invalid_email');
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildField(
                        isDark: isDark,
                        controller: _passwordController,
                        label: context.t('password'),
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: LumiereColors.lightGray,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t('enter_password');
                          if (v.length < 6) return context.t('password_too_short');
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password strength bar
                      _buildPasswordStrength(),
                      const SizedBox(height: 40),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LumiereColors.luxuryGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: LumiereColors.orangePrimary.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: authProvider.isLoading ? null : _submit,
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text(
                                    _isLogin ? context.t('enter_gallery') : context.t('begin_journey'),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                      const SizedBox(height: 32),


                      Center(
                        child: GestureDetector(
                          onTap: () => setState(() => _isLogin = !_isLogin),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 15, color: LumiereColors.lightGray),
                              children: [
                                TextSpan(
                                  text: _isLogin ? '${context.t('no_account')} ' : '${context.t('already_have_account')} ',
                                ),
                                TextSpan(
                                  text: _isLogin ? context.t('signup') : context.t('login'),
                                  style: const TextStyle(
                                    color: LumiereColors.orangePrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    final pwd = _passwordController.text;
    if (pwd.isEmpty) return const SizedBox.shrink();

    String label = context.t('weak');
    Color color = Colors.red;
    double factor = 0.3;

    if (pwd.length >= 8 && pwd.contains(RegExp(r'[A-Z]')) &&
        pwd.contains(RegExp(r'[0-9]'))) {
      label = context.t('strong');
      color = Colors.green;
      factor = 1.0;
    } else if (pwd.length >= 6) {
      label = context.t('medium');
      color = Colors.orange;
      factor = 0.6;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${context.t('password_strength')}: ',
                style: TextStyle(fontSize: 12, color: LumiereColors.lightGray)),
            Text(label, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: factor,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: LumiereColors.lightGray,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252525) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? []
                : [
              BoxShadow(color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: isDark ? Border.all(color: Colors.white10) : null,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: validator,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isDark ? Colors.white : LumiereColors.darkGray,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                  icon, color: LumiereColors.orangePrimary, size: 22),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 18, horizontal: 16),
              errorStyle: const TextStyle(height: 0),
            ),
          ),
        ),
      ],
    );
  }
}
