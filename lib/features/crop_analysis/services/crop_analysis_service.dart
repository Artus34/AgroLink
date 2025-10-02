import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/commodity_model.dart';

class CropAnalysisService {
  // ⚠️ IMPORTANT: Replace this placeholder with your actual CEDA API key.
  // The API key is required in the Authorization header.
  static const String _apiKey = 'af854182725b6ab4699c5395edb9614827afabace29734ba5464ae48d377d0b3';
  static const String _baseUrl = 'https://api.ceda.ashoka.edu.in/v1/agmarknet';

  /// Fetches the list of all available commodities from the CEDA Agmarknet API.
  Future<List<Commodity>> fetchCommodities() async {
    const url = '$_baseUrl/commodities';
    
    try {
      // ✅ FIX: The Authorization header is crucial to avoid the 400 Bad Request error.
      // It must be included in the headers map.
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Check if the response structure is as expected: { "output": { "data": [...] } }
        final List<dynamic>? commodityListJson = data['output']?['data'];

        if (commodityListJson != null) {
          return commodityListJson
              .map((json) => Commodity.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Failed to parse commodity data: Invalid structure.');
        }
      } else {
        // Handle specific API errors
        print('API Error: Status Code ${response.statusCode}');
        print('API Response Body: ${response.body}');
        
        if (response.statusCode == 401 || response.statusCode == 403) {
           throw Exception('Authentication failed. Check your API Key.');
        } else {
           throw Exception('Failed to load commodities. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Network/Parsing Error: $e');
      throw Exception('An error occurred while fetching commodities: $e');
    }
  }
}
