import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/news_provider.dart';
import '../services/article_news_service.dart';
import '../services/video_news_service.dart';

// ✅ REMOVED: Pakistan has been removed from the list.
const Map<String, String> _countryMap = {
  'All Countries': '',
  'United States': 'us',
  'India': 'in',
  'United Kingdom': 'gb',
  'Canada': 'ca',
  'Australia': 'au',
  'Germany': 'de',
  'France': 'fr',
  'Brazil': 'br',
  'South Africa': 'za',
  'Nigeria': 'ng',
  'Kenya': 'ke',
  'Philippines': 'ph',
};


class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      provider.fetchArticles();
      provider.fetchVideos();
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.lightScaffoldBackground,
        appBar: AppBar(
          title: const Text('Agriculture News', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: AppColors.lightScaffoldBackground,
          elevation: 1,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'ARTICLES', icon: Icon(Icons.article_outlined)),
              Tab(text: 'VIDEOS', icon: Icon(Icons.videocam_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ArticleFeedView(onLaunchUrl: _launchUrl),
            _VideoFeedView(onLaunchUrl: _launchUrl),
          ],
        ),
      ),
    );
  }
}

// --- ARTICLES TAB VIEW ---
class _ArticleFeedView extends StatelessWidget {
  final Function(String) onLaunchUrl;
  const _ArticleFeedView({required this.onLaunchUrl});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _CountryDropdown(
              selectedCountryCode: provider.selectedCountryCode,
              onChanged: (newCode) {
                provider.selectCountryAndFetchNews(newCode);
              },
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.isArticlesLoading && provider.articles.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                  }
                  if (provider.articleErrorMessage != null && provider.articles.isEmpty) {
                    return Center(child: Text('Error: ${provider.articleErrorMessage}'));
                  }
                  if (provider.articles.isEmpty && !provider.isArticlesLoading) {
                    return const Center(child: Text('No articles found for the selected country.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchArticles(force: true),
                    color: AppColors.primaryGreen,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: provider.articles.length,
                      itemBuilder: (context, index) {
                        final article = provider.articles[index];
                        return _ArticleListItem(article: article, onTap: () => onLaunchUrl(article.articleUrl));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- VIDEOS TAB VIEW ---
class _VideoFeedView extends StatelessWidget {
  final Function(String) onLaunchUrl;
  const _VideoFeedView({required this.onLaunchUrl});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // ✅ UPDATED: The video tab now only shows the country dropdown.
            _CountryDropdown(
              selectedCountryCode: provider.selectedCountryCode,
              onChanged: (newCode) {
                provider.selectCountryAndFetchNews(newCode);
              },
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.isVideosLoading && provider.videos.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                  }
                  if (provider.videoErrorMessage != null && provider.videos.isEmpty) {
                    return Center(child: Text('Error: ${provider.videoErrorMessage}'));
                  }
                   if (provider.videos.isEmpty && !provider.isVideosLoading) {
                    return const Center(child: Text('No videos found for the selected country.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchVideos(force: true),
                    color: AppColors.primaryGreen,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: provider.videos.length + 1, 
                      itemBuilder: (context, index) {
                        if (index == provider.videos.length) {
                          return const _DisclaimerCard();
                        }
                        final video = provider.videos[index];
                        return _VideoListItem(video: video, onTap: () => onLaunchUrl(video.videoUrl));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}


// --- DROPDOWN WIDGETS ---

class _CountryDropdown extends StatelessWidget {
  final String? selectedCountryCode;
  final ValueChanged<String?> onChanged;

  const _CountryDropdown({this.selectedCountryCode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: AppColors.lightCard,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedCountryCode ?? '',
            icon: const Icon(Icons.public, color: AppColors.primaryGreen),
            items: _countryMap.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.value,
                child: Text(entry.key),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

// ✅ REMOVED: The language dropdown widget is no longer needed.

// --- OTHER WIDGETS (UNCHANGED) ---

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: AppColors.lightCard,
      margin: EdgeInsets.all(12.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
          'Video results are based on YouTube search queries and may not always be accurate or directly related to farming.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ArticleListItem extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  const _ArticleListItem({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  article.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 180, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(article.description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(article.sourceName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryGreen), overflow: TextOverflow.ellipsis)),
                      Text(DateFormat.yMMMd().format(article.publishedAt), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoListItem extends StatelessWidget {
  final YouTubeVideo video;
  final VoidCallback onTap;
  const _VideoListItem({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  video.thumbnailUrl,
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(width: 120, height: 90, color: Colors.grey[200], child: const Icon(Icons.play_circle_outline, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(video.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary), maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(video.channelTitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

