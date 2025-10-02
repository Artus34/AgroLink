import 'package:agrolink/features/crop_analysis/views/crop_analysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/controllers/auth_provider.dart';
import '../../auth/views/profile_screen.dart';
// ⭐️ ADDED: Import for the Sales Dashboard Screen
import '../../crop_sales/views/sales_dashboard_screen.dart';
import '../../market_info/weather/controllers/weather_provider.dart';
import '../../market_info/weather/services/weather_service.dart';
import '../../market_info/weather/views/weather_screen.dart';
import '../../market_info/news/controllers/news_provider.dart';
import '../../market_info/news/views/news_feed_screen.dart';
import '../../predictions/fertilizer_recommendation/views/fertilizer_recommendation_screen.dart';
import '../../predictions/rainfall_prediction/views/rainfall_prediction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all necessary data when the screen is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);

      // Fetch weather and both types of news.
      weatherProvider.fetchWeatherForecast();
      newsProvider.fetchArticles();
      newsProvider.fetchVideos();
    });
  }

  // Helper method to launch URLs safely.
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isAdminViewing = args?['isAdminViewing'] ?? false;
    
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    final List<Map<String, dynamic>> featureCards = [
      // ⭐️ ADDED: The new Marketplace feature card
      {'icon': Icons.storefront_outlined, 'title': 'Marketplace', 'subtitle': 'Buy and sell crops directly.'},
      {'icon': Icons.grass, 'title': 'Predict Crop', 'subtitle': 'Get AI-powered crop suggestions.'},
      {'icon': Icons.trending_up, 'title': 'Yield Prediction', 'subtitle': 'Predict your crop yield.'},
      {'icon': Icons.show_chart, 'title': 'Crop Analysis', 'subtitle': 'View market and price trends.'},
      {'icon': Icons.water_drop_outlined, 'title': 'Predict Rainfall', 'subtitle': 'Estimate annual rainfall.'},
      {'icon': Icons.science_outlined, 'title': 'Fertilizer Suggestion', 'subtitle': 'Find the right fertilizer.'},
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.account_circle, size: 30, color: AppColors.primaryGreen),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              tooltip: 'View Profile',
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
              Text(
                'Welcome back, ${user?.name ?? 'User'}!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),

              if (user != null)
                Chip(
                  label: Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  backgroundColor: user.role == 'farmer' ? Colors.green.shade100 : Colors.blue.shade100,
                  avatar: Icon(
                    user.role == 'farmer' ? Icons.eco : Icons.person,
                    color: user.role == 'farmer' ? Colors.green : Colors.blue,
                  ),
                ),

              const SizedBox(height: 24),
              _buildWeatherCard(),
              const SizedBox(height: 24),
              _NewsPanel(onLaunchUrl: _launchUrl),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: featureCards.map((cardData) {
                  return _FeatureCard(
                    icon: cardData['icon'],
                    title: cardData['title'],
                    subtitle: cardData['subtitle'],
                    onTap: () {
                      // ⭐️ ADDED: Navigation logic for the new Marketplace card
                      if (cardData['title'] == 'Marketplace') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SalesDashboardScreen()),
                        );
                      } else if (cardData['title'] == 'Predict Crop') {
                        Navigator.pushNamed(context, '/predict_crop');
                      } else if (cardData['title'] == 'Yield Prediction') {
                        Navigator.pushNamed(context, '/predict_yield');
                      }
                      else if (cardData['title'] == 'Crop Analysis') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CropAnalysisScreen(),
                          ),
                        );
                      }
                      else if (cardData['title'] == 'Predict Rainfall') {
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
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: isAdminViewing
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context);
              },
              label: const Text('Back to Admin'),
              icon: const Icon(Icons.shield_outlined),
              backgroundColor: AppColors.primaryGreen,
            )
          : null,
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
          return _WeatherDisplayCard(weatherData: provider.weatherData!);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _NewsPanel extends StatelessWidget {
  final Function(String) onLaunchUrl;
  const _NewsPanel({required this.onLaunchUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: AppColors.lightCard,
      shadowColor: AppColors.primaryGreen.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: AppColors.primaryGreen,
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: Color.fromARGB(255, 251, 137, 137),
              tabs: [
                Tab(text: 'ARTICLES'),
                Tab(text: 'VIDEOS'),
              ],
            ),
            SizedBox(
              height: 240, // Constrained height for the panel
              child: Consumer<NewsProvider>(
                builder: (context, provider, child) {
                  return TabBarView(
                    children: [
                      _buildArticlePreview(context, provider),
                      _buildVideoPreview(context, provider),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsFeedScreen()),
                );
              },
              child: const Text('VIEW ALL NEWS', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlePreview(BuildContext context, NewsProvider provider) {
    if (provider.isArticlesLoading && provider.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }
    if (provider.articleErrorMessage != null) {
      return Center(child: Text(provider.articleErrorMessage!));
    }
    final articlesToShow = provider.articles.take(3).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: articlesToShow.length,
      itemBuilder: (context, index) {
        final article = articlesToShow[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              article.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image),
            ),
          ),
          title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
          onTap: () => onLaunchUrl(article.articleUrl),
        );
      },
      separatorBuilder: (_, __) => const Divider(indent: 72),
    );
  }

  Widget _buildVideoPreview(BuildContext context, NewsProvider provider) {
    if (provider.isVideosLoading && provider.videos.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }
    if (provider.videoErrorMessage != null) {
      return Center(child: Text(provider.videoErrorMessage!));
    }
    final videosToShow = provider.videos.take(3).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: videosToShow.length,
      itemBuilder: (context, index) {
        final video = videosToShow[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              video.thumbnailUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.play_circle_outline),
            ),
          ),
          title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
          onTap: () => onLaunchUrl(video.videoUrl),
        );
      },
      separatorBuilder: (_, __) => const Divider(indent: 72),
    );
  }
}


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

