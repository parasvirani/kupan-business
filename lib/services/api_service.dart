import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_client.dart';
import '../utils/phone_utils.dart';
import 'secure_store.dart';

/// Thin endpoint layer. All transport concerns (base URL, auth header, timeout,
/// TLS pinning, fail-open) live in [ApiClient]; methods here just name endpoints.
class ApiService {
  final ApiClient _api = ApiClient.instance;

  Future<http.Response> loginUser(String mobileNumber) {
    return _api.post("/auth/send-otp",
        body: {"contact": normalizePhone(mobileNumber)});
  }

  Future<http.Response> verifyOtp(String idToken, String role) {
    return _api.post("/auth/verify-otp", body: {
      'firebaseToken': idToken,
      'role': role,
    });
  }

  // Backend derives the user from the Bearer token; the path id is ignored.
  Future<http.Response> updateUser(Map<String, dynamic> map) {
    return _api.put("/users/me", body: map);
  }

  Future<http.Response> getUser() => _api.get("/users/me");

  Future<http.Response> createKupan(Map<String, dynamic> map) {
    return _api.post("/kupan/create", body: map);
  }

  Future<http.Response> getKupan() {
    // The backend derives the vendor from the token; we still supply our own id
    // in the path so this keeps working before and after the Phase-2 vendor fix.
    return _api.get("/kupan/vendor/${SecureStore.i.userId}");
  }

  Future<http.Response> getKupanWithFilters({
    required String vendorId,
    required String businessId,
    int limit = 10,
  }) {
    return _api.get("/kupan", query: {
      "vendorId": vendorId,
      "businessId": businessId,
      "limit": limit,
    });
  }

  Future<http.Response> getKupanByVendor({
    required String vendorId,
    int limit = 10,
  }) {
    return _api.get("/kupan", query: {"vendorId": vendorId, "limit": limit});
  }

  Future<http.Response> uploadImage({required File imageFile}) {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mainType = (ext == 'mp4' || ext == 'mov') ? 'video' : 'image';

    return _api.multipart(
      "/uploads",
      filesBuilder: () async => [
        await http.MultipartFile.fromPath(
          'files',
          imageFile.path,
          contentType: MediaType(mainType, ext),
        ),
      ],
    );
  }

  Future<http.Response> getBusinessOutlets() => _api.get("/users/me");

  Future<http.Response> addBusiness(Map<String, dynamic> map) {
    return _api.post("/users/business", body: map);
  }

  Future<http.Response> deleteBusiness(String businessId) {
    return _api.delete("/users/business/$businessId");
  }

  Future<http.Response> updateBusiness(
      String businessId, Map<String, dynamic> map) {
    return _api.put("/users/business/$businessId", body: map);
  }

  Future<http.Response> generateQRCode({required String kupanId}) {
    return _api.get("/qr/generate/$kupanId");
  }

  Future<http.Response> deleteKupan(String kupanId) {
    return _api.delete("/kupan/$kupanId");
  }

  Future<http.Response> getNotifications() => _api.get("/notifications");

  Future<http.Response> markAllNotificationsRead() =>
      _api.patch("/notifications/read-all");

  Future<http.Response> deleteNotification(String notifId) {
    return _api.delete("/notifications/$notifId");
  }

  Future<http.Response> updateFcmToken(String fcmToken) {
    if (SecureStore.i.token.isEmpty)
      return Future.value(http.Response('', 401));
    return _api.patch("/users/fcm-token", body: {"fcmToken": fcmToken});
  }
}
