import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../services/api_exception.dart';
import '../services/api_service.dart';

/// Drives the "Waiting for admin approval" screen: fetches the vendor's own
/// account approval status, exposes it reactively, and light-polls for changes.
class ApprovalController extends GetxController {
  final ApiService _apiService = ApiService();

  /// One of: "pending" | "approved" | "rejected" | "" (unknown / not fetched).
  final status = ''.obs;
  final rejectionReason = ''.obs;
  final isChecking = false.obs;
  final errorMessage = ''.obs;

  Timer? _poll;

  bool get isApproved => status.value == 'approved';
  bool get isRejected => status.value == 'rejected';

  /// Fetches the current approval status. Returns the resolved status string, or
  /// null on a network/parse error (leaving [status] unchanged).
  Future<String?> checkStatus() async {
    isChecking.value = true;
    errorMessage.value = '';
    try {
      final http.Response res = await _apiService.getApprovalStatus();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final payload = data is Map ? data['data'] : null;
        final fetched = (payload?['approvalStatus'] ?? '').toString();
        if (fetched.isNotEmpty) status.value = fetched;
        rejectionReason.value =
            (payload?['rejectionReason'] ?? '').toString();
        return status.value;
      }
      errorMessage.value = 'Could not check status (${res.statusCode})';
      return null;
    } catch (e) {
      errorMessage.value = mapError(e).userMessage;
      return null;
    } finally {
      isChecking.value = false;
    }
  }

  /// Polls every [interval] until approved (caller stops it on navigation).
  void startPolling({Duration interval = const Duration(seconds: 15)}) {
    _poll?.cancel();
    _poll = Timer.periodic(interval, (_) async {
      if (isChecking.value) return;
      await checkStatus();
    });
  }

  void stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }
}
