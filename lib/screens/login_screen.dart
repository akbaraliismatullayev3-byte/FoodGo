import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import 'admin/admin_dashboard.dart';
import 'main_shell.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@foodgo.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      // Check if user is admin
      if (auth.isAdmin) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainShell()),
          (route) => false,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
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
              // Top gradient header
              _buildHeader(),
              // Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('welcome_back'),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : LumiereColors.darkGray,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 6),
                      Text(
                        context.t('sign_in_subtitle'),
                        style: const TextStyle(color: LumiereColors.lightGray, fontSize: 14),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 36),

                      // Email
                      _buildLabel(context.t('email')),
                      const SizedBox(height: 8),
                      _buildTextFormField(
                        isDark: isDark,
                        controller: _emailController,
                        hint: 'example@mail.com',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t('enter_email');
                          if (!v.contains('@')) return context.t('invalid_email');
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password
                      _buildLabel(context.t('password')),
                      const SizedBox(height: 8),
                      _buildTextFormField(
                        isDark: isDark,
                        controller: _passwordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: LumiereColors.lightGray,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t('enter_password');
                          if (v.length < 6) return context.t('password_too_short');
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: Text(
                            context.t('forgot_password'),
                            style: const TextStyle(
                              color: LumiereColors.orangePrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Error message
                      if (auth.errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: LumiereColors.redAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: LumiereColors.redAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: LumiereColors.redAccent, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  auth.errorMessage!,
                                  style: const TextStyle(color: LumiereColors.redAccent, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().shake(),

                      // Login Button
                      _buildSubmitButton(
                        label: context.t('login'),
                        isLoading: auth.isLoading,
                        onPressed: _login,
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              context.t('or'),
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Register link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 15, color: LumiereColors.lightGray),
                              children: [
                                TextSpan(text: '${context.t('no_account')} '),
                                TextSpan(
                                  text: context.t('signup'),
                                  style: const TextStyle(
                                    color: LumiereColors.orangePrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms),
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

  Widget _buildHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB92905), Color(0xFFFF5A36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 36),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          const Text(
            'Lumière',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const Text(
            'Gastronomy',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: LumiereColors.lightGray,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontWeight: FontWeight.w600, 
          fontSize: 15, 
          color: isDark ? Colors.white : LumiereColors.darkGray,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: LumiereColors.lightGray, fontWeight: FontWeight.normal, fontSize: 14),
          prefixIcon: Icon(icon, color: LumiereColors.orangePrimary, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LumiereColors.luxuryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: LumiereColors.orangePrimary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }
}
