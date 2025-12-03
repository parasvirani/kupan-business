import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../const/color_const.dart';
import '../../controllers/my_outlets_controller.dart';
import '../../utils/utils.dart';
import 'add_outlet_screen.dart';

class MyOutletsScreen extends StatefulWidget {
  const MyOutletsScreen({super.key});

  @override
  State<MyOutletsScreen> createState() => _MyOutletsScreenState();
}

class _MyOutletsScreenState extends State<MyOutletsScreen> {
  final MyOutletsController controller = Get.put(MyOutletsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => const AddOutletScreen());
          },
          backgroundColor: ColorConst.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Outlets',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorConst.primary,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red.withOpacity(0.5),
                ),
                SizedBox(height: size(20)),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: size(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: size(8)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size(20)),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size(14),
                      fontWeight: FontWeight.w400,
                      color: ColorConst.grey,
                    ),
                  ),
                ),
                SizedBox(height: size(20)),
                ElevatedButton(
                  onPressed: () {
                    controller.getOutlets();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.primary,
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.outletsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 80,
                  color: ColorConst.grey.withOpacity(0.5),
                ),
                SizedBox(height: size(20)),
                Text(
                  'No Outlets Yet',
                  style: TextStyle(
                    fontSize: size(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: size(8)),
                Text(
                  'You haven\'t added any outlets yet.\nTap the + button to add your first outlet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size(14),
                    fontWeight: FontWeight.w400,
                    color: ColorConst.grey,
                  ),
                ),
                SizedBox(height: size(40)),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const AddOutletScreen());
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Outlet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: size(40),
                      vertical: size(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.getOutlets(),
          child: ListView.builder(
            padding: EdgeInsets.all(size(16)),
            itemCount: controller.outletsList.length,
            itemBuilder: (context, index) {
              final outlet = controller.outletsList[index];
              return Container(
                margin: EdgeInsets.only(bottom: size(12)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(size(12)),
                  child: Row(
                    children: [
                      // Outlet Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: outlet.outletImages != null && outlet.outletImages!.isNotEmpty
                            ? Image.network(
                                outlet.outletImages![0],
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: ColorConst.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.store,
                                      color: ColorConst.primary,
                                      size: size(40),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: ColorConst.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.store,
                                  color: ColorConst.primary,
                                  size: size(40),
                                ),
                              ),
                      ),
                      SizedBox(width: size(12)),
                      // Outlet Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              outlet.outletName ?? 'N/A',
                              style: TextStyle(
                                fontSize: size(14),
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: size(4)),
                            Text(
                              outlet.businessType ?? 'N/A',
                              style: TextStyle(
                                fontSize: size(12),
                                fontWeight: FontWeight.w400,
                                color: ColorConst.grey,
                              ),
                            ),
                            SizedBox(height: size(6)),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: size(12),
                                  color: ColorConst.grey,
                                ),
                                SizedBox(width: size(3)),
                                Expanded(
                                  child: Text(
                                    '${outlet.location?.city ?? 'N/A'}, ${outlet.location?.state ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: size(11),
                                      color: ColorConst.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: size(8)),
                      // Action Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Edit functionality
                            },
                            child: Container(
                              padding: EdgeInsets.all(size(6)),
                              decoration: BoxDecoration(
                                color: ColorConst.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: size(18),
                                color: ColorConst.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
