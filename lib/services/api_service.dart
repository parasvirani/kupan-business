import 'dart:convert';
import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../const/string_const.dart';

class ApiService {
  static const String baseUrl = "https://kupan-backend.vercel.app/api/v1";
  final box = GetStorage();

  Future<http.Response> loginUser(String mobileNumber) async {
    final url = Uri.parse("${baseUrl}/auth/send-otp");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "contact": "+91$mobileNumber",
    });

    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> verifyOtp(String idToken, String role) async {
    return await http.post(
      Uri.parse('${baseUrl}/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firebaseToken': idToken,
        'role': role,
      }),
    );
  }

  Future<http.Response> updateUser(Map<String, dynamic> map) async {


    String userId = box.read(StringConst.USER_ID);
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/users/$userId");
    final headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};
    final body = jsonEncode(map);

    return await http.put(url, headers: headers, body: body);
  }

  Future<http.Response> getUser() async {


    String userId = box.read(StringConst.USER_ID);
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/users/$userId");
    final headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

    return await http.get(url, headers: headers);
  }

  Future<http.Response> createKupan(Map<String, dynamic> map) async {

    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/kupan/create");
    final headers = {"Content-Type":"application/json","Authorization": "Bearer $token"};
    final body = jsonEncode(map);
    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> getKupan() async {

    String userId = box.read(StringConst.USER_ID);
    String token = box.read(StringConst.TOKEN);

    print("ASDF:::${userId}");

    final url = Uri.parse("$baseUrl/kupan/vendor/$userId");
    final headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

    return await http.get(url, headers: headers);
  }

  Future<http.Response> getKupanWithFilters({
    required String vendorId,
    required String businessId,
    int limit = 10,
  }) async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse(
      "$baseUrl/kupan?vendorId=$vendorId&businessId=$businessId&limit=$limit"
    );
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return await http.get(url, headers: headers);
  }

  Future<http.Response> getKupanByVendor({
    required String vendorId,
    int limit = 10,
  }) async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse(
      "$baseUrl/kupan?vendorId=$vendorId&limit=$limit"
    );
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return await http.get(url, headers: headers);
  }

  Future<http.Response> uploadImage({required File imageFile}) async {

    String token = box.read(StringConst.TOKEN);

    var request = http.MultipartRequest('POST', Uri.parse("${baseUrl}/uploads"));
    request.headers['Authorization'] = "Bearer $token";

    // detect file type
    String ext = imageFile.path.split('.').last.toLowerCase();
    String mainType = (ext == 'mp4' || ext == 'mov') ? 'video' : 'image';

    request.files.add(await http.MultipartFile.fromPath(
      'files',
      imageFile.path,
      contentType: MediaType(mainType, ext),
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  Future<http.Response> getBusinessOutlets() async {
    String token = box.read(StringConst.TOKEN);
    String userId = box.read(StringConst.USER_ID);

    final url = Uri.parse("$baseUrl/users/$userId");
    final headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

    return await http.get(url, headers: headers);
  }

  Future<http.Response> addBusiness(Map<String, dynamic> map) async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/users/business");
    final headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};
    final body = jsonEncode(map);

    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> deleteBusiness(String businessId) async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/users/business/$businessId");
    final headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};

    return await http.delete(url, headers: headers);
  }

  Future<http.Response> updateBusiness(String businessId, Map<String, dynamic> map) async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/users/business/$businessId");
    final headers = {"Content-Type": "application/json", "Authorization": "Bearer $token"};
    final body = jsonEncode(map);

    return await http.put(url, headers: headers, body: body);
  }

  Future<http.Response> generateQRCode({required String kupanId}) async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/qr/generate/$kupanId");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return await http.get(url, headers: headers);
  }

  Future<http.Response> deleteKupan(String kupanId) async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/kupan/$kupanId");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return await http.delete(url, headers: headers);
  }

  Future<http.Response> getNotifications() async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/notifications");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return await http.get(url, headers: headers);
  }

  Future<http.Response> markAllNotificationsRead() async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/notifications/read-all");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return await http.patch(url, headers: headers);
  }

  Future<http.Response> deleteNotification(String notifId) async {
    String token = box.read(StringConst.TOKEN);

    final url = Uri.parse("$baseUrl/notifications/$notifId");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return await http.delete(url, headers: headers);
  }
}
