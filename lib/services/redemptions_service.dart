import 'dart:convert';

import 'package:kupan_business/models/redemptions_res.dart';

import 'api_client.dart';

class RedemptionsService {
  // Token + transport (pinning, timeout) handled centrally by ApiClient.
  Future<RedemptionsResponse?> getRedemptions({
    required String vendorId,
    required String range, // 'weekly', 'monthly', 'all'
  }) async {
    try {
      final response = await ApiClient.instance.get(
        '/kupan/vendor/redemptions',
        query: {'vendorId': vendorId, 'range': range},
      );

      if (response.statusCode == 200) {
        return RedemptionsResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token may have expired');
      } else {
        throw Exception('Failed to fetch redemptions: ${response.statusCode}');
      }
    } catch (e) {
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
      final response = await ApiClient.instance.put(
        '/kupan/$kupanId',
        body: {
          'title': title,
          'kupanImages': kupanImages,
          'kupanDays': kupanDays,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token may have expired');
      } else {
        throw Exception('Failed to edit kupan: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
