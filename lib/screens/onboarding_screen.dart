import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/language_provider.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Delicious Gastronomy',
      subtitle: 'Premium culinary experiences delivered directly to your door.',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=600&auto=format&fit=crop',
      color: LumiereColors.orangePrimary,
    ),
    OnboardingData(
      title: 'Global Cuisine',
      subtitle: 'From Italian Pasta to Japanese Sushi, explore the flavors of the world.',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      color: Colors.teal,
    ),
    OnboardingData(
      title: 'Fast Delivery',
      subtitle: 'Your favorite meals, delivered fresh and fast, every single day.',
      imageUrl: 'https://images.unsplash.com/photo-1526367790999-0150786486a9?q=80&w=600&auto=format&fit=crop',
      color: const Color(0xFF673AB7),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [page.color, page.color.withOpacity(0.7)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(60)),
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.network(
                            page.imageUrl,
                            width: 320,
                            height: 320,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ).animate(onPlay: (controller) => controller.repeat())
                               .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.3));
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 320,
                              height: 320,
                              color: Colors.white.withOpacity(0.1),
                              child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 80),
                            ),
                          ),
                        ),
                      ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: LumiereColors.darkGray),
                          ).animate().fadeIn().slideY(begin: 0.2),
                          const SizedBox(height: 16),
                          Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: LumiereColors.lightGray, height: 1.5),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Navigation Controls
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(_pages.length, (idx) => 
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      width: _currentPage == idx ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == idx ? LumiereColors.orangePrimary : LumiereColors.lightGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                // Button
                GestureDetector(
                  onTap: () {
                    if (_currentPage == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOut);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LumiereColors.luxuryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: LumiereColors.orangePrimary.withOpacity(0.3), blurRadius: 10)],
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'GET STARTED' : 'NEXT',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().scale(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color color;

  OnboardingData({required this.title, required this.subtitle, required this.imageUrl, required this.color});
}
