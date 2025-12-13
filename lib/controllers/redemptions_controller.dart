import 'package:get/get.dart';
import 'package:kupan_business/models/redemptions_res.dart';
import 'package:kupan_business/services/redemptions_service.dart';

class RedemptionsController extends GetxController {
  final RedemptionsService _service = RedemptionsService();

  final Rx<RedemptionsResponse?> weeklyRedemptions = Rx(null);
  final Rx<RedemptionsResponse?> monthlyRedemptions = Rx(null);
  final Rx<RedemptionsResponse?> allRedemptions = Rx(null);

  final RxString selectedRange = 'weekly'.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  late String vendorId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      vendorId = Get.arguments['vendorId'] ?? '';
    }
  }

  Future<void> fetchRedemptions({required String vendorId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final weekly = await _service.getRedemptions(
        vendorId: vendorId,
        range: 'weekly',
      );

      final monthly = await _service.getRedemptions(
        vendorId: vendorId,
        range: 'monthly',
      );

      final all = await _service.getRedemptions(
        vendorId: vendorId,
        range: 'all',
      );

      weeklyRedemptions.value = weekly;
      monthlyRedemptions.value = monthly;
      allRedemptions.value = all;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  void setSelectedRange(String range) {
    selectedRange.value = range;
  }

  RedemptionsResponse? get currentRedemptions {
    switch (selectedRange.value) {
      case 'weekly':
        return weeklyRedemptions.value;
      case 'monthly':
        return monthlyRedemptions.value;
      case 'all':
        return allRedemptions.value;
      default:
        return null;
    }
  }

  int get totalRedemptionsCount {
    final current = currentRedemptions;
    if (current == null) return 0;
    return current.data.fold<int>(0, (sum, item) => sum + item.totalRedemptions);
  }
}
