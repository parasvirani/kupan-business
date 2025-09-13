import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kupan_business/common_view/common_text.dart';
import 'package:kupan_business/common_view/common_textfield.dart';
import 'package:kupan_business/const/color_const.dart';
import 'package:kupan_business/controllers/details_controller.dart';
import '../utils/utils.dart';

class StateSheet extends StatefulWidget {
  const StateSheet({super.key});

  @override
  State<StateSheet> createState() => _StateSheetState();
}

class _StateSheetState extends State<StateSheet> with TickerProviderStateMixin {
  DetailsController detailsController = Get.find();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  List<dynamic> get filteredStates {
    if (searchQuery.isEmpty) {
      return detailsController.states;
    }
    return detailsController.states
        .where((state) =>
            state.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: size(8)),
            width: size(40),
            height: size(4),
            decoration: BoxDecoration(
              color: ColorConst.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(size(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  text: 'Select State',
                  color: Colors.black,
                  fontSize: size(18),
                  fontWeight: FontWeight.w600,
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.all(size(8)),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close,
                      size: size(18),
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size(20)),
            child: CommonTextfield(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              hintText: "Search states...",
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: size(10)),
                child: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                ),
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? Padding(
                padding: EdgeInsets.symmetric(horizontal: size(10)),
                    child: GestureDetector(
                        onTap: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.grey[500],
                          size: size(18),
                        ),
                      ),
                  )
                  : null,
            ),
          ),

          SizedBox(height: size(16)),

          // States List
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: filteredStates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: size(48),
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: size(12)),
                          CommonText(
                            text: 'No states found',
                            color: Colors.grey[600]!,
                            fontSize: size(16),
                          ),
                          SizedBox(height: size(4)),
                          CommonText(
                            text: 'Try searching with different keywords',
                            color: Colors.grey[500]!,
                            fontSize: size(12),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: size(16)),
                      itemBuilder: (context, index) {
                        final state = filteredStates[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              // Handle state selection
                              detailsController.updateState(state);
                              Get.back();
                              //Navigator.pop(context, state);
                            },
                            child: Container(
                              padding: EdgeInsets.all(size(16)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // State Icon
                                  Container(
                                    width: size(40),
                                    height: size(40),
                                    decoration: BoxDecoration(
                                      color: ColorConst.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: ColorConst.primary,
                                      size: size(20),
                                    ),
                                  ),

                                  SizedBox(width: size(12)),

                                  // State Name
                                  Expanded(
                                    child: CommonText(
                                      text: state.name,
                                      color: Colors.black,
                                      fontSize: size(15),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  // Arrow Icon
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey[400],
                                    size: size(14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(
                        height: size(12),
                      ),
                      itemCount: filteredStates.length,
                    ),
            ),
          ),

          // Bottom Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom + size(16)),
        ],
      ),
    );
  }
}

// Usage: Show the bottom sheet
void showStateBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => const StateSheet(),
  );
}
