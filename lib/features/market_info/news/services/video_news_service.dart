// lib/features/market_info/news/services/video_news_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service to fetch agriculture-related videos from the YouTube Data API.
class VideoNewsService {
  // YouTube Data API Search endpoint
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  // Core search keywords for agriculture content
  final String _coreQuery = 'agriculture OR farming OR crops OR harvest OR agritech';

  /// Fetches the latest agriculture videos
  Future<List<YouTubeVideo>> fetchLatestAgriVideos() async {
    final apiKey = dotenv.env['YOUTUBE_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("YOUTUBE_API_KEY is missing from .env file.");
      throw Exception("YouTube API Key is not configured.");
    }

    // Build the query parameters
    final Map<String, dynamic> queryParams = {
      'part': 'snippet',       // Needed for title, description, and thumbnail
      'q': _coreQuery,
      'type': 'video',         // Only search for videos
      'maxResults': 20,        // Number of results
      'key': apiKey,
      'order': 'date',         // Sort by date published
    };

    // Construct the final URL
    final uri = Uri.parse(_baseUrl).replace(
        queryParameters:
            queryParams.map((key, value) => MapEntry(key, value.toString())));

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        final results = decodedJson['items'];

        if (results is List) {
          return results
              .map((json) => YouTubeVideo.fromJson(json))
              // Filter out any videos missing ID or thumbnail
              .where((video) =>
                  video.videoId.isNotEmpty && video.thumbnailUrl.isNotEmpty)
              .toList();
        } else {
          return [];
        }
      } else {
        debugPrint("YouTube API Error Response: ${response.body}");
        throw Exception(
          'Failed to load videos. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("Error fetching videos: $e");
      throw Exception('Failed to connect to the video service.');
    }
  }
}

/// Data model representing a single YouTube video
class YouTubeVideo {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String videoUrl; // Full watch URL

  YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  }) : videoUrl = 'https://www.youtube.com/watch?v=$videoId';

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final id = json['id']['videoId'] ?? '';
    final snippet = json['snippet'];

    return YouTubeVideo(
      videoId: id,
      title: snippet['title'] ?? 'No Title',
      channelTitle: snippet['channelTitle'] ?? 'Unknown Channel',
      thumbnailUrl: snippet['thumbnails']?['high']?['url'] ?? '',
    );
  }
}
