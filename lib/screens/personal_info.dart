import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common_view/common_textfield.dart';
import '../controllers/details_controller.dart';
import '../utils/utils.dart';

class UserDetailsScreen extends StatefulWidget {
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final DetailsController detailsController = Get.put(DetailsController());
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tab Section
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.deepOrange,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Personal Info',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                    Text(
                      'Outlet Info',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Avatar Section
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CommonTextfield(
                controller: detailsController.nameController,
                hintText: 'Enter Your Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name.";
                  } else if (value.length < 2) {
                    return "Name must be at least 2 characters long.";
                  }
                  return null;
                },
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size(10)),
                  child: Icon(Icons.person_outline),
                ),
                keyboardType: TextInputType.name,
              ),

              SizedBox(height: 16),
              CommonTextfield(
                controller: detailsController.phoneController,
                hintText: 'Enter Your Mobile Number',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size(10)),
                  child: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 60),

              // Error Message
              Obx(
                () => detailsController.errorMessage.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: Text(
                            detailsController.errorMessage.value,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),

                  // Continue Button
                  Obx(
                    () => Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: detailsController.isLoading.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  detailsController.submitPersonalInfo();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          disabledBackgroundColor: Colors.deepOrange.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: detailsController.isLoading.value
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Processing...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}