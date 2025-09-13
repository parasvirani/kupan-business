// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdateRes _$UserUpdateResFromJson(Map<String, dynamic> json) =>
    UserUpdateRes(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : UserUpdateData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserUpdateResToJson(UserUpdateRes instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'statusCode': instance.statusCode,
      'data': instance.data,
    };

UserUpdateData _$UserUpdateDataFromJson(Map<String, dynamic> json) =>
    UserUpdateData(
      sellerInfo: json['sellerInfo'] == null
          ? null
          : UserUpdateSellerInfo.fromJson(
              json['sellerInfo'] as Map<String, dynamic>),
      id: json['_id'] as String?,
      name: json['name'] as String?,
      contact: json['contact'] as String?,
      role: json['role'] as String?,
      profilePic: json['profilePic'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$UserUpdateDataToJson(UserUpdateData instance) =>
    <String, dynamic>{
      'sellerInfo': instance.sellerInfo,
      '_id': instance.id,
      'name': instance.name,
      'contact': instance.contact,
      'role': instance.role,
      'profilePic': instance.profilePic,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

UserUpdateSellerInfo _$UserUpdateSellerInfoFromJson(
        Map<String, dynamic> json) =>
    UserUpdateSellerInfo(
      email: json['email'] as String?,
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      outletName: json['outletName'] as String?,
      outletDay: (json['outletDay'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      outletTime: json['outletTime'] as String?,
      outletImages: (json['outletImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      location: json['location'] == null
          ? null
          : UserUpdateLocation.fromJson(
              json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserUpdateSellerInfoToJson(
        UserUpdateSellerInfo instance) =>
    <String, dynamic>{
      'email': instance.email,
      'businessName': instance.businessName,
      'businessType': instance.businessType,
      'outletName': instance.outletName,
      'outletDay': instance.outletDay,
      'outletTime': instance.outletTime,
      'outletImages': instance.outletImages,
      'location': instance.location,
    };

UserUpdateLocation _$UserUpdateLocationFromJson(Map<String, dynamic> json) =>
    UserUpdateLocation(
      lat: (json['lat'] as num?)?.toDouble(),
      long: (json['long'] as num?)?.toDouble(),
      city: json['city'] as String?,
      pincode: json['pincode'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
      address2: json['address2'] as String?,
      landmark: json['landmark'] as String?,
    );

Map<String, dynamic> _$UserUpdateLocationToJson(UserUpdateLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'long': instance.long,
      'city': instance.city,
      'pincode': instance.pincode,
      'state': instance.state,
      'address': instance.address,
      'address2': instance.address2,
      'landmark': instance.landmark,
    };
