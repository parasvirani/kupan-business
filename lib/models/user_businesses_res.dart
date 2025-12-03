import 'package:json_annotation/json_annotation.dart';
part 'user_businesses_res.g.dart';

@JsonSerializable()
class UserBusinessesRes {
  bool? success;
  String? message;
  int? statusCode;
  UserBusinessData? data;

  UserBusinessesRes({this.success, this.message, this.statusCode, this.data});

  factory UserBusinessesRes.fromJson(Map<String, dynamic> json) => _$UserBusinessesResFromJson(json);

  Map<String, dynamic> toJson() => _$UserBusinessesResToJson(this);
}

@JsonSerializable()
class UserBusinessData {
  @JsonKey(name: "_id")
  String? id;
  String? contact;
  String? role;
  String? profilePic;
  String? name;
  List<SellerBusiness>? sellerBusinesses;
  String? createdAt;
  String? updatedAt;

  UserBusinessData({
    this.id,
    this.contact,
    this.role,
    this.profilePic,
    this.name,
    this.sellerBusinesses,
    this.createdAt,
    this.updatedAt,
  });

  factory UserBusinessData.fromJson(Map<String, dynamic> json) => _$UserBusinessDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserBusinessDataToJson(this);
}

@JsonSerializable()
class SellerBusiness {
  @JsonKey(name: "_id")
  String? id;
  String? email;
  String? businessName;
  String? businessType;
  String? outletName;
  List<String>? outletDay;
  String? outletTime;
  List<String>? outletImages;
  String? outletNumber;
  BusinessLocation? location;

  SellerBusiness({
    this.id,
    this.email,
    this.businessName,
    this.businessType,
    this.outletName,
    this.outletDay,
    this.outletTime,
    this.outletImages,
    this.outletNumber,
    this.location,
  });

  factory SellerBusiness.fromJson(Map<String, dynamic> json) => _$SellerBusinessFromJson(json);

  Map<String, dynamic> toJson() => _$SellerBusinessToJson(this);
}

@JsonSerializable()
class BusinessLocation {
  double? lat;
  double? long;
  String? city;
  String? pincode;
  String? state;
  String? address;

  BusinessLocation({
    this.lat,
    this.long,
    this.city,
    this.pincode,
    this.state,
    this.address,
  });

  factory BusinessLocation.fromJson(Map<String, dynamic> json) => _$BusinessLocationFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessLocationToJson(this);
}

