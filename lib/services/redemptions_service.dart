import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kupan_business/const/string_const.dart';
import 'package:kupan_business/models/redemptions_res.dart';

class RedemptionsService {
  static const String baseUrl = 'https://kupan-backend.vercel.app/api/v1/kupan';
  final GetStorage _storage = GetStorage();

  Future<RedemptionsResponse?> getRedemptions({
    required String vendorId,
    required String range, // 'weekly', 'monthly', 'all'
  }) async {
    try {
      final token = _storage.read(StringConst.TOKEN);

      if (token == null) {
        print("❌ No authentication token found in storage");
        throw Exception('No authentication token found');
      }

      print("🔐 Using token: ${token.toString().substring(0, 20)}...");
      print("🔗 Fetching redemptions for vendorId: $vendorId, range: $range");

      final url = Uri.parse(
        '$baseUrl/vendor/redemptions?vendorId=$vendorId&range=$range',
      );

      print("📍 URL: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print("📊 Response Status: ${response.statusCode}");
      print("📊 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final result = RedemptionsResponse.fromJson(jsonData);
        print("✅ Redemptions parsed successfully: ${result.data.length} items");
        return result;
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - Token may have expired");
        throw Exception('Unauthorized - Token may have expired');
      } else {
        print("❌ Failed to fetch redemptions: ${response.statusCode}");
        throw Exception(
          'Failed to fetch redemptions: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ RedemptionsService Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> editKupan({
    required String kupanId,
    required String title,
    required List<String> kupanImages,
    required List<String> kupanDays,
  }) async {
    try {
      final token = _storage.read(StringConst.TOKEN);

      if (token == null) {
        print("❌ No authentication token found in storage");
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$baseUrl/$kupanId');

      print("📍 Editing kupan: $kupanId");

      final body = jsonEncode({
        'title': title,
        'kupanImages': kupanImages,
        'kupanDays': kupanDays,
      });

      print("📤 Request body: $body");

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print("📊 Response Status: ${response.statusCode}");
      print("📊 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        print("✅ Kupan updated successfully");
        return jsonData;
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - Token may have expired");
        throw Exception('Unauthorized - Token may have expired');
      } else {
        print("❌ Failed to edit kupan: ${response.statusCode}");
        throw Exception(
          'Failed to edit kupan: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Edit Kupan Error: $e");
      rethrow;
    }
  }
}
