// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_businesses_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBusinessesRes _$UserBusinessesResFromJson(Map<String, dynamic> json) =>
    UserBusinessesRes(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : UserBusinessData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserBusinessesResToJson(UserBusinessesRes instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'statusCode': instance.statusCode,
      'data': instance.data,
    };

UserBusinessData _$UserBusinessDataFromJson(Map<String, dynamic> json) =>
    UserBusinessData(
      id: json['_id'] as String?,
      contact: json['contact'] as String?,
      role: json['role'] as String?,
      profilePic: json['profilePic'] as String?,
      name: json['name'] as String?,
      sellerBusinesses: (json['sellerBusinesses'] as List<dynamic>?)
          ?.map((e) => SellerBusiness.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$UserBusinessDataToJson(UserBusinessData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'contact': instance.contact,
      'role': instance.role,
      'profilePic': instance.profilePic,
      'name': instance.name,
      'sellerBusinesses': instance.sellerBusinesses,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

SellerBusiness _$SellerBusinessFromJson(Map<String, dynamic> json) =>
    SellerBusiness(
      id: json['_id'] as String?,
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
      outletNumber: json['outletNumber'] as String?,
      location: json['location'] == null
          ? null
          : BusinessLocation.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SellerBusinessToJson(SellerBusiness instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'email': instance.email,
      'businessName': instance.businessName,
      'businessType': instance.businessType,
      'outletName': instance.outletName,
      'outletDay': instance.outletDay,
      'outletTime': instance.outletTime,
      'outletImages': instance.outletImages,
      'outletNumber': instance.outletNumber,
      'location': instance.location,
    };

BusinessLocation _$BusinessLocationFromJson(Map<String, dynamic> json) =>
    BusinessLocation(
      lat: (json['lat'] as num?)?.toDouble(),
      long: (json['long'] as num?)?.toDouble(),
      city: json['city'] as String?,
      pincode: json['pincode'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$BusinessLocationToJson(BusinessLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'long': instance.long,
      'city': instance.city,
      'pincode': instance.pincode,
      'state': instance.state,
      'address': instance.address,
    };
