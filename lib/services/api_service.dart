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

  Future<http.Response> verifyOtp(String mobileNumber, String otp, String role) async {
    final url = Uri.parse("${baseUrl}/auth/verify-otp");
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "contact": "+91$mobileNumber",
      "otp": otp,
      "role": role
    });

    return await http.post(url, headers: headers, body: body);
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

  Future<http.Response> uploadImage({required File imageFile}) async {

    String userId = box.read(StringConst.USER_ID);
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
}
