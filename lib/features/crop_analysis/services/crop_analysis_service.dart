import 'dart:convert';
import 'package:agrolink/features/config.dart';
import 'package:agrolink/features/crop_analysis/models/Price_data.dart';
import 'package:http/http.dart' as http;

class CropAnalysisService {
  static const String _CropAnalysisApiKey = Config.CropAnalysisApiKey;
  static const String _CropAnalysisApiUrl = Config.CropAnalysisApiUrl;

  Future<List<PriceData>> fetchPriceData({
    required int commodityId,
    required int stateId,
    List<int>? districtIds,
    List<int>? marketIds,
    required String fromDate,
    required String toDate,
  }) async {
    const url = '$_CropAnalysisApiUrl/prices';

    final requestBody = jsonEncode({
      "commodity_id": commodityId,
      "state_id": stateId,
      if (districtIds != null && districtIds.isNotEmpty)
        "district_id": districtIds,
      if (marketIds != null && marketIds.isNotEmpty) "market_id": marketIds,
      "from_date": fromDate,
      "to_date": toDate,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $_CropAnalysisApiKey',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('🔎 API Status Code: ${response.statusCode}');
      print('🔎 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('output') &&
            data['output'] != null &&
            data['output']['data'] != null) {
          final List<dynamic> priceListJson = data['output']['data'];

          return priceListJson
              .map((json) => PriceData.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          print('⚠️ API response has no "output.data".');
          return [];
        }
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw Exception('Authentication failed. Check your API Key.');
        } else if (response.statusCode == 400) {
          throw Exception(
              'Bad Request: Check your POST body filters/dates for validity.');
        } else {
          throw Exception(
              'Failed to load price data. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Network/Parsing Error: $e');
      throw Exception(
          'An error occurred while fetching price data: ${e.toString()}');
    }
  }
}
