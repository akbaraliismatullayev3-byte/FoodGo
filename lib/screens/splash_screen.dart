import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    // Luxury delay for brand immersion
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB92905),
                Color(0xFFE24A10),
                Color(0xFFFF5A36),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -65,
                top: 175,
                child: _DecorativeFoodOrb(
                  size: 190,
                  imageUrl:
                      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1200&auto=format&fit=crop',
                ),
              ),
              Positioned(
                right: -85,
                bottom: 110,
                child: _DecorativeFoodOrb(
                  size: 220,
                  imageUrl:
                      'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=1200&auto=format&fit=crop',
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.03),
                        Colors.black.withOpacity(0.10),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      Container(
                        width: 102,
                        height: 102,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 26,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          color: Color(0xFFB93A10),
                          size: 52,
                        ),
                      ).animate().scale(
                            delay: 120.ms,
                            duration: 650.ms,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 22),
                      Text(
                        'Lumière',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                              letterSpacing: 0.3,
                            ),
                      ).animate().fadeIn(delay: 220.ms),
                      const SizedBox(height: 4),
                      Text(
                        'Gastronomy',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white.withOpacity(0.96),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                      ).animate().fadeIn(delay: 280.ms),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'THE ART OF FLAVOR',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.82),
                                    letterSpacing: 2.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 360.ms),
                      const SizedBox(height: 16),
                      Text(
                        'The Art of Flavor, Curated for Your Senses',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.86),
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                      ).animate().fadeIn(delay: 460.ms),
                      const Spacer(flex: 4),
                      Container(
                        width: 120,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ).animate().fadeIn(delay: 620.ms),
                      const SizedBox(height: 14),
                      Text(
                        'Curated premium dining experience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.72),
                              fontWeight: FontWeight.w500,
                            ),
                      ).animate().fadeIn(delay: 700.ms),
                      const SizedBox(height: 10),
                      Text(
                        'Tap anywhere to continue',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.62),
                              fontSize: 12,
                            ),
                      ).animate().fadeIn(delay: 780.ms),
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
}

class _DecorativeFoodOrb extends StatelessWidget {
  final double size;
  final String imageUrl;

  const _DecorativeFoodOrb({
    required this.size,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.09),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: ClipOval(
          child: Opacity(
            opacity: 0.28,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}