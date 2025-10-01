import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
// --- Weather Feature Imports ---
import '../../market_info/weather/controllers/weather_provider.dart';
import '../../market_info/weather/services/weather_service.dart';
import '../../market_info/weather/views/weather_screen.dart';
// --- Other Feature Imports ---
import '../../predictions/fertilizer_recommendation/views/fertilizer_recommendation_screen.dart';
import '../../predictions/rainfall_prediction/views/rainfall_prediction_screen.dart';

// 1. Converted to a StatefulWidget to fetch data on initial load
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. Fetch weather data when the screen is first built
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use listen: false because we are in initState
      Provider.of<WeatherProvider>(context, listen: false).fetchWeatherForecast();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ Read the argument passed from the admin screen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isAdminViewing = args?['isAdminViewing'] ?? false;

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
        automaticallyImplyLeading: Navigator.canPop(context),
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

              // 3. Replaced static weather card with the dynamic one
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
                      } else if (cardData['title'] == 'Predict Rainfall') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RainfallPredictionScreen(),
                          ),
                        );
                      } else if (cardData['title'] == 'Fertilizer Suggestion') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FertilizerRecommendationScreen(),
                          ),
                        );
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
      // ⭐️ Add a conditional FloatingActionButton visible only to admins
      floatingActionButton: isAdminViewing
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context);
              },
              label: const Text('Back to Admin'),
              icon: const Icon(Icons.shield_outlined),
              backgroundColor: AppColors.primaryGreen,
            )
          : null, // Don't show the button for regular users
    );
  }

  // 4. This helper now uses a Consumer to listen to WeatherProvider state changes
  Widget _buildWeatherCard() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        // Handle loading state
        if (provider.isLoading && provider.weatherData == null) {
          return const Card(
            child: SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            ),
          );
        }

        // Handle error state
        if (provider.errorMessage != null && provider.weatherData == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Could not load weather data.\nPlease check your connection.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        // Handle success state
        if (provider.weatherData != null) {
          return _WeatherDisplayCard(weatherData: provider.weatherData!);
        }

        // Default empty state
        return const SizedBox.shrink();
      },
    );
  }

  // Helper widget for the Crop Sales Card (Unchanged)
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

// 5. A new, dedicated widget to display the weather card and handle taps
class _WeatherDisplayCard extends StatelessWidget {
  final WeatherData weatherData;

  const _WeatherDisplayCard({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final current = weatherData.current;
    final location = weatherData.location;

    return Card(
      elevation: 4.0,
      color: AppColors.lightCard,
      shadowColor: AppColors.primaryGreen.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to the detailed weather screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeatherScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${current.tempC.round()}°C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https:${current.iconUrl}',
                    width: 70,
                    height: 70,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.cloud_off, color: AppColors.textSecondary, size: 70),
                  ),
                  Text(
                    current.conditionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A reusable widget for the feature cards in the grid (Unchanged)
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
        final screenWidth = MediaQuery.of(context).size.width;
        int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);
        double itemWidth = (screenWidth - (16 * (crossAxisCount + 1))) / crossAxisCount;

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

