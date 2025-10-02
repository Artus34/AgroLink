import 'package:agrolink/features/home/widgets/features_card_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../crop_analysis/views/crop_analysis_screen.dart';
import '../../market_info/weather/controllers/weather_provider.dart';
import '../../market_info/news/controllers/news_provider.dart';
import '../../predictions/fertilizer_recommendation/views/fertilizer_recommendation_screen.dart';
import '../../predictions/rainfall_prediction/views/rainfall_prediction_screen.dart';
import '../widgets/weather_display_card.dart';
import '../widgets/news_panel.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      weatherProvider.fetchWeatherForecast();
      newsProvider.fetchArticles();
      newsProvider.fetchVideos();
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Welcome back, Farmer Joe!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Here's an overview of your farm and available tools.",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Weather card
              _buildWeatherCard(),
              const SizedBox(height: 24),

              // News
              NewsPanel(onLaunchUrl: _launchUrl),
              const SizedBox(height: 24),

              // Features
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: featureCardsData.map((cardData) {
                  return FeatureCard(
                    icon: cardData['icon'],
                    title: cardData['title'],
                    subtitle: cardData['subtitle'],
                    onTap: () {
                      if (cardData['title'] == 'Predict Crop') {
                        Navigator.pushNamed(context, '/predict_crop');
                      } else if (cardData['title'] == 'Yield Prediction') {
                        Navigator.pushNamed(context, '/predict_yield');
                      } else if (cardData['title'] == 'Crop Analysis') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CropAnalysisScreen()),
                        );
                      } else if (cardData['title'] == 'Predict Rainfall') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RainfallPredictionScreen()),
                        );
                      } else if (cardData['title'] == 'Fertilizer Suggestion') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FertilizerRecommendationScreen()),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat-bot'),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.support_agent_sharp, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildWeatherCard() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
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
        if (provider.errorMessage != null && provider.weatherData == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Could not load weather data.\nPlease check your connection.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        if (provider.weatherData != null) {
          return WeatherDisplayCard(weatherData: provider.weatherData!);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
