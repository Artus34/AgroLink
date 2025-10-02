import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service class to fetch agriculture-related videos from YouTube via Google's YouTube Data API.
class VideoNewsService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  /// Fetches the latest videos based on agricultural keywords.
  // ✅ REMOVED: The languageCode parameter has been removed.
  Future<List<YouTubeVideo>> fetchLatestAgriVideos({String? regionCode}) async {
    final apiKey = dotenv.env['YOUTUBE_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("YouTube API Key is not configured in your .env file.");
    }

    const List<String> keywords = [
      'agriculture',
      'farming',
      'crops',
      'harvest',
      'agritech',
      'agronomy',
      'livestock',
      'farm equipment',
      'soil health'
    ];
    final String searchQuery = keywords.join('|'); // Use '|' for OR in YouTube search

    var urlBuilder = StringBuffer('$_baseUrl?part=snippet&q=$searchQuery&type=video&order=date&maxResults=20&key=$apiKey');

    if (regionCode != null && regionCode.isNotEmpty) {
      urlBuilder.write('&regionCode=$regionCode');
    }

    final url = urlBuilder.toString();

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        return items
            .map((json) => YouTubeVideo.fromJson(json))
            .where((video) => video.title.isNotEmpty)
            .toList();
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown API Error';
        debugPrint("YouTube API Error Response: ${response.body}");
        throw Exception('Failed to load videos: $errorMessage');
      }
    } catch (e) {
      debugPrint("VideoNewsService Error: $e");
      throw Exception('Failed to connect to the video service.');
    }
  }
}

/// Data model representing a single YouTube video.
class YouTubeVideo {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publishedAt;

  YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
  });

  String get videoUrl => 'https://www.youtube.com/watch?v=$videoId';

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    return YouTubeVideo(
      videoId: (json['id'] != null ? json['id']['videoId'] : '') ?? '',
      title: snippet['title'] ?? 'No Title',
      description: snippet['description'] ?? '',
      thumbnailUrl: (snippet['thumbnails'] != null
              ? snippet['thumbnails']['high']['url']
              : '') ??
          '',
      channelTitle: snippet['channelTitle'] ?? 'Unknown Channel',
      publishedAt: DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

