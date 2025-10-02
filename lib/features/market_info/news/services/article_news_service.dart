import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ✅ NEW: A map to get the country name from the code for the search query.
const Map<String, String> _countryCodeToNameMap = {
  'us': 'USA',
  'in': 'India',
  'gb': 'UK',
  'ca': 'Canada',
  'au': 'Australia',
  'de': 'Germany',
  'fr': 'France',
  'br': 'Brazil',
  'za': 'South Africa',
  'ng': 'Nigeria',
  'ke': 'Kenya',
  'ph': 'Philippines',
};

/// Service to fetch text-based news articles from the NewsAPI.org service.
class ArticleNewsService {
  // ✅ UPDATED: Always use the '/everything' endpoint for keyword searching.
  static const String _baseUrl = 'https://newsapi.org/v2/everything';

  final List<String> _keywords = [
    'agriculture', 'farming', 'crops', 'harvest', 'agritech',
    'agronomy', 'livestock', '"farm equipment"' // Using quotes for multi-word term
  ];

  /// Fetches the latest agriculture news, with an option to filter by country.
  Future<List<NewsArticle>> fetchLatestAgriNews({String? countryCode}) async {
    final apiKey = dotenv.env['NEWS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("NEWS_API_KEY from NewsAPI.org is missing from .env file.");
      throw Exception("News API Key is not configured.");
    }

    // ✅ IMPROVEMENT: Build a more precise search query.
    // 1. Group the keywords in parentheses for proper boolean logic.
    final String keywordQuery = '(${_keywords.join(' OR ')})';
    String finalQuery = keywordQuery;

    // 2. If a country is selected, add it to the query.
    if (countryCode != null && countryCode.isNotEmpty) {
      final countryName = _countryCodeToNameMap[countryCode];
      if (countryName != null) {
        finalQuery = '$keywordQuery AND $countryName';
      }
    }

    // 3. Construct the final URL.
    final url = '$_baseUrl?q=${Uri.encodeComponent(finalQuery)}&language=en&sortBy=publishedAt&pageSize=40';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        
        final results = decodedJson['articles'];
        if (results is List) {
          return results
              .map((json) => NewsArticle.fromJson(json))
              .where((article) => article.title != "[Removed]" && article.imageUrl.isNotEmpty) // Also filter out articles without images
              .toList();
        } else {
          return [];
        }
      } else {
        debugPrint("NewsAPI.org Error Response: ${response.body}");
        throw Exception(
          'Failed to load articles. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("Error fetching articles: $e");
      throw Exception('Failed to connect to the article service.');
    }
  }
}

/// Data model representing a single news article from NewsAPI.org.
class NewsArticle {
  final String title;
  final String description;
  final String articleUrl;
  final String imageUrl;
  final String sourceName;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.articleUrl,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No description available.',
      articleUrl: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      sourceName: json['source']?['name'] ?? 'Unknown Source',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

