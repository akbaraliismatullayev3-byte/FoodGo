import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import 'main_shell.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String _selectedGender = 'Male';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await auth.signUp(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      gender: _selectedGender,
    );

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainShell()),
        (route) => false,
      );
    }
  }

  String _getStrengthLabel(BuildContext context, String pwd) {
    if (pwd.length >= 8 && pwd.contains(RegExp(r'[A-Z]')) && pwd.contains(RegExp(r'[0-9]'))) return context.t('strong');
    if (pwd.length >= 6) return context.t('medium');
    return context.t('weak');
  }

  Color _getStrengthColor(String pwd) {
    if (pwd.length >= 8 && pwd.contains(RegExp(r'[A-Z]')) && pwd.contains(RegExp(r'[0-9]'))) return Colors.green;
    if (pwd.length >= 6) return Colors.orange;
    return Colors.red;
  }

  double _getStrengthValue(String pwd) {
    if (pwd.length >= 8 && pwd.contains(RegExp(r'[A-Z]')) && pwd.contains(RegExp(r'[0-9]'))) return 1.0;
    if (pwd.length >= 6) return 0.6;
    if (pwd.isNotEmpty) return 0.3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final pwd = _passwordController.text;

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
              // Top header
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('signup'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : LumiereColors.darkGray,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 6),
                      Text(
                        context.t('sign_up_subtitle'),
                        style: const TextStyle(color: LumiereColors.lightGray, fontSize: 14),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 32),

                      // Full Name
                      _buildLabel(context.t('full_name')),
                      const SizedBox(height: 8),
                      _buildField(
                        isDark: isDark,
                        controller: _nameController,
                        hint: 'Akbar Toshmatov',
                        icon: Icons.person_outline_rounded,
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t('enter_name');
                          if (v.length < 3) return context.t('name_too_short');
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildLabel(context.t('email')),
                      const SizedBox(height: 8),
                      _buildField(
                        isDark: isDark,
                        controller: _emailController,
                        hint: 'example@mail.com',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t('enter_email');
                          if (!v.contains('@') || !v.contains('.')) return context.t('invalid_email');
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Gender Selection
                      _buildLabel(context.t('gender')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildGenderOption(context.t('male'), Icons.male_rounded, isDark)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGenderOption(context.t('female'), Icons.female_rounded, isDark)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Password
                      _buildLabel(context.t('password')),
                      const SizedBox(height: 8),
                      _buildField(
                        isDark: isDark,
                        controller: _passwordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePass,
                        onChanged: (_) => setState(() {}),
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: LumiereColors.lightGray,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t('enter_password');
                          if (v.length < 6) return context.t('password_too_short');
                          return null;
                        },
                      ),
                      // Strength indicator
                      if (pwd.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${context.t('password_strength')}: ',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            Text(
                              _getStrengthLabel(context, pwd),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStrengthColor(pwd),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _getStrengthValue(pwd),
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(pwd)),
                            minHeight: 5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Confirm Password
                      _buildLabel(context.t('confirm_password')),
                      const SizedBox(height: 8),
                      _buildField(
                        isDark: isDark,
                        controller: _confirmController,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscureConfirm,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: LumiereColors.lightGray,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return context.t('confirm_password');
                          if (v != _passwordController.text) return context.t('passwords_not_match');
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Error
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

                      // Register Button
                      _buildSubmitButton(
                        label: context.t('signup'),
                        isLoading: auth.isLoading,
                        onPressed: _register,
                      ),
                      const SizedBox(height: 24),

                      // Login link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 15, color: LumiereColors.lightGray),
                              children: [
                                TextSpan(text: '${context.t('already_have_account')} '),
                                TextSpan(
                                  text: context.t('login'),
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
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LumiereColors.luxuryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 30),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          const Text(
            'Lumière',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: LumiereColors.lightGray,
          letterSpacing: 1.2,
        ),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
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
        onChanged: onChanged,
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
                  width: 24, height: 24,
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

  Widget _buildGenderOption(String gender, IconData icon, bool isDark) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected 
              ? LumiereColors.orangePrimary.withOpacity(0.1) 
              : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F8F8)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? LumiereColors.orangePrimary : (isDark ? Colors.white10 : Colors.grey.shade100),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? LumiereColors.orangePrimary : LumiereColors.lightGray, size: 20),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected 
                    ? LumiereColors.orangePrimary 
                    : (isDark ? Colors.white70 : LumiereColors.darkGray),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
