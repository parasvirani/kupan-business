
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../common_view/common_text.dart';
import '../common_view/common_textfield.dart';
import '../const/color_const.dart';
import '../const/image_const.dart';
import '../utils/utils.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              labelColor: Color(0xFFFF4500),
              unselectedLabelColor: Colors.grey[400],
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Color(0xFFFF4500),
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Personal Info'),
                Tab(text: 'Outlet Info'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Personal Info Tab
                _buildPersonalInfoTab(),
                // Outlet Info Tab (placeholder)
                Center(
                  child: Text(
                    'Outlet Info',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 30),
          // Profile Avatar
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF7FB3D3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: Color(0xFFFF4500),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 40),

          // Form Fields
          Expanded(
            child: Column(
              children: [
                CommonTextfield(
                  controller: _nameController,
                  hintText: 'Enter Your Name',
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size(10)),
                    child: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.name,
                ),

                SizedBox(height: 16),
                CommonTextfield(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  isNumber: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size(10)),
                    child: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 16),

                CommonTextfield(
                  controller: _emailController,
                  hintText: 'Add Email',
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size(10)),
                    child: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),


                SizedBox(height: 16),

                CommonTextfield(
                  controller: _businessController,
                  hintText: 'Business Name',
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size(10)),
                    child: Icon(Icons.business_outlined),
                  ),
                  keyboardType: TextInputType.name,
                ),


                SizedBox(height: 16),

                // Continue Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle continue action
                      print('Continue pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF4500),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.grey[50],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey[600],
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
