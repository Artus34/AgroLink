// lib/features/home/views/home_screen.dart

import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data for the feature cards
    final List<Map<String, dynamic>> featureCards = [
      {'icon': Icons.grass, 'title': 'Predict Crop', 'subtitle': 'Get AI-powered crop suggestions.'},
      {'icon': Icons.trending_up, 'title': 'Yield Prediction', 'subtitle': 'Predict your crop yield.'},
      {'icon': Icons.water_drop_outlined, 'title': 'Predict Rainfall', 'subtitle': 'Estimate annual rainfall.'},
      {'icon': Icons.science_outlined, 'title': 'Fertilizer Suggestion', 'subtitle': 'Find the right fertilizer.'},
      {'icon': Icons.wb_sunny_outlined, 'title': 'Weather Forecast', 'subtitle': 'View detailed weather forecast.'},
      {'icon': Icons.feedback_outlined, 'title': 'Submit Feedback', 'subtitle': 'Share your thoughts with us.'},
    ];

    return Scaffold(
      backgroundColor: AppColors.lightScaffoldBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'AGROLINK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              child: Text('FJ', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              const Text('Welcome back, Farmer Joe!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text("Here's an overview of your farm and available tools.", style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 24),

              // Weather Card
              _buildWeatherCard(),
              const SizedBox(height: 24),

              // Feature Grid (Responsive)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: featureCards.map((cardData) {
                  return _FeatureCard(
                    icon: cardData['icon'],
                    title: cardData['title'],
                    subtitle: cardData['subtitle'],
                    onTap: () {
                      if (cardData['title'] == 'Predict Crop') {
                        Navigator.pushNamed(context, '/predict_crop');
                      } else if (cardData['title'] == 'Yield Prediction') {
                        Navigator.pushNamed(context, '/predict_yield');
                      }
                      // You can add navigation logic for other cards here
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Crop Sales Card
              _buildCropSalesCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the Weather Card
  Widget _buildWeatherCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Weather", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Farm Location: Green Valley', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherMetric(icon: Icons.wb_sunny, value: '28°C', label: 'Temperature'),
                _buildWeatherMetric(icon: Icons.opacity, value: '65%', label: 'Humidity'),
                _buildWeatherMetric(icon: Icons.grain, value: '10%', label: 'Rain Chance'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for individual weather metrics
  Widget _buildWeatherMetric({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppColors.primaryGreen),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    );
  }

  // Helper widget for the Crop Sales Card
  Widget _buildCropSalesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crop Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Track your crop sales and revenue.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            const Text('Monitor sales performance and generate reports.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('View Sales (Placeholder)'),
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable widget for the feature cards in the grid
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the number of columns based on screen width
        final screenWidth = constraints.maxWidth;
        int crossAxisCount = 2; // Default for mobile
        if (screenWidth > 600 && screenWidth < 900) {
          crossAxisCount = 3; // For tablets
        } else if (screenWidth >= 900) {
          crossAxisCount = 4; // For desktops/web
        }
        
        final double itemWidth = (screenWidth - (16 * (crossAxisCount + 1))) / crossAxisCount;

        return SizedBox(
          width: itemWidth,
          child: Card(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 24, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis,),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}