import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.t('about_us')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: LumiereColors.luxuryGradient,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: LumiereColors.orangePrimary.withOpacity(0.3), blurRadius: 20)],
              ),
              child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 60),
            ).animate().scale(duration: 600.ms),
            const SizedBox(height: 32),
            Text(
              'Lumière Gastronomy',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: LumiereColors.darkGray),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            Text(
              'Lumière is not just a food delivery app. It is a portal to the finest culinary experiences. Our mission is to connect food lovers with world-class chefs and restaurants, delivering excellence directly to your plate.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.6, color: LumiereColors.lightGray, fontSize: 15),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 40),
            _buildStatRow(context, '500+', 'Premium Restaurants'),
            _buildStatRow(context, '50k+', 'Happy Foodies'),
            _buildStatRow(context, '15 min', 'Avg. Delivery Time'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: LumiereColors.orangePrimary)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: LumiereColors.darkGray, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.t('contact_us')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildContactCard(context, Icons.phone_rounded, 'Call Us', '+998 90 123 45 67'),
            _buildContactCard(context, Icons.email_rounded, 'Email', 'support@lumiere.com'),
            _buildContactCard(context, Icons.location_on_rounded, 'Visit Us', 'Tashkent, Amir Temur Street 15'),
            const SizedBox(height: 40),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1526772662000-3f88f10405ff?q=80&w=1000&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on, color: LumiereColors.orangePrimary, size: 30),
                ),
              ),
            ).animate().fadeIn().scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, color: LumiereColors.orangePrimary),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: LumiereColors.lightGray, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: LumiereColors.darkGray, fontSize: 16)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Latest News'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=600&auto=format&fit=crop',
                    height: 180, width: double.infinity, fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FOOD TRENDS', style: TextStyle(color: LumiereColors.orangePrimary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      const Text('Top 10 Healthy Breakfast Ideas for 2026', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: LumiereColors.darkGray)),
                      const SizedBox(height: 12),
                      const Text('Discover the nutrients your body needs to start the day with energy and focus.', style: TextStyle(color: LumiereColors.lightGray, fontSize: 14)),
                      const SizedBox(height: 16),
                      TextButton(onPressed: () {}, child: const Text('Read More', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
        },
      ),
    );
  }
}
class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Culinary Blog'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 4,
        itemBuilder: (context, index) {
          final blogTitles = [
            'The Art of Perfect Sourdough',
            'Sourcing Sustainable Ingredients',
            'A Day in the Life of a Michelin Star Chef',
            'Exploring the Spice Markets of Asia'
          ];
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=600&auto=format&fit=crop',
                    height: 180, width: double.infinity, fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CULTURAL', style: TextStyle(color: LumiereColors.orangePrimary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(blogTitles[index], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: LumiereColors.darkGray)),
                      const SizedBox(height: 12),
                      const Text('Embark on a journey through the heart of world-class kitchens and discover the secrets behind every signature dish.', style: TextStyle(color: LumiereColors.lightGray, fontSize: 14)),
                      const SizedBox(height: 16),
                      TextButton(onPressed: () {}, child: const Text('Read More', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
        },
      ),
    );
  }
}
