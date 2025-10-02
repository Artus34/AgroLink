import 'package:flutter/foundation.dart';

import '../services/article_news_service.dart';
import '../services/video_news_service.dart';

class NewsProvider with ChangeNotifier {
  // --- State for Articles ---
  final ArticleNewsService _articleService = ArticleNewsService();
  List<NewsArticle> _articles = [];
  List<NewsArticle> get articles => _articles;
  bool _isArticlesLoading = false;
  bool get isArticlesLoading => _isArticlesLoading;
  String? _articleErrorMessage;
  String? get articleErrorMessage => _articleErrorMessage;

  // --- State for Videos ---
  final VideoNewsService _videoService = VideoNewsService();
  List<YouTubeVideo> _videos = [];
  List<YouTubeVideo> get videos => _videos;
  bool _isVideosLoading = false;
  bool get isVideosLoading => _isVideosLoading;
  String? _videoErrorMessage;
  String? get videoErrorMessage => _videoErrorMessage;

  // --- Shared Filter State ---
  String? _selectedCountryCode;
  String? get selectedCountryCode => _selectedCountryCode;

  // ✅ REMOVED: Language filter state is no longer needed.
  // String? _selectedLanguageCode;
  // String? get selectedLanguageCode => _selectedLanguageCode;


  // --- Methods ---

  /// ✅ RENAMED & UPDATED: Updates the country and triggers a refetch for BOTH articles and videos.
  Future<void> selectCountryAndFetchNews(String? newCountryCode) async {
    _selectedCountryCode = newCountryCode;
    
    // ✅ REMOVED: Logic for resetting language is no longer needed.
    
    await Future.wait([
      fetchArticles(force: true),
      fetchVideos(force: true),
    ]);
  }

  // ✅ REMOVED: Language selection method is no longer needed.
  // Future<void> selectLanguageAndFetchVideos(String? newLanguageCode) async { ... }

  /// Fetches articles, passing the selected country code to the service.
  Future<void> fetchArticles({bool force = false}) async {
    if (_articles.isNotEmpty && !force) return;

    _isArticlesLoading = true;
    _articleErrorMessage = null;
    notifyListeners();

    try {
      _articles = await _articleService.fetchLatestAgriNews(countryCode: _selectedCountryCode);
    } catch (e) {
      _articleErrorMessage = e.toString();
      debugPrint("NewsProvider (Articles) Error: $_articleErrorMessage");
    } finally {
      _isArticlesLoading = false;
      notifyListeners();
    }
  }

  /// ✅ UPDATED: Fetches videos, now only passing the selected country code.
  Future<void> fetchVideos({bool force = false}) async {
    if (_videos.isNotEmpty && !force) return;

    _isVideosLoading = true;
    _videoErrorMessage = null;
    notifyListeners();

    try {
      _videos = await _videoService.fetchLatestAgriVideos(
        regionCode: _selectedCountryCode,
        // languageCode parameter is removed.
      );
    } catch (e) {
      _videoErrorMessage = e.toString();
      debugPrint("NewsProvider (Videos) Error: $_videoErrorMessage");
    } finally {
      _isVideosLoading = false;
      notifyListeners();
    }
  }
}

