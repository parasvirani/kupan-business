
import 'package:json_annotation/json_annotation.dart';
part 'user_update_res.g.dart';

@JsonSerializable()
class UserUpdateRes {
  bool? success;
  String? message;
  int? statusCode;
  UserUpdateData? data;

  UserUpdateRes({this.success, this.message, this.statusCode, this.data});

  factory UserUpdateRes.fromJson(Map<String, dynamic> json) => _$UserUpdateResFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateResToJson(this);
}

@JsonSerializable()
class UserUpdateData {
  UserUpdateSellerInfo? sellerInfo;
  @JsonKey(name: "_id")
  String? id;
  String? name;
  String? contact;
  String? role;
  String? profilePic;
  String? createdAt;
  String? updatedAt;

  UserUpdateData(
      {this.sellerInfo,
      this.id,
      this.name,
      this.contact,
      this.role,
      this.profilePic,
      this.createdAt,
      this.updatedAt});

  factory UserUpdateData.fromJson(Map<String, dynamic> json) => _$UserUpdateDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateDataToJson(this);
}

@JsonSerializable()
class UserUpdateSellerInfo {
  String? email;
  String? businessName;
  String? businessType;
  String? outletName;
  List<String>? outletDay;
  String? outletTime;
  List<String>? outletImages;
  UserUpdateLocation? location;

  UserUpdateSellerInfo(
      {this.email,
      this.businessName,
      this.businessType,
      this.outletName,
      this.outletDay,
      this.outletTime,
      this.outletImages,
      this.location});

  factory UserUpdateSellerInfo.fromJson(Map<String, dynamic> json) => _$UserUpdateSellerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateSellerInfoToJson(this);
}

@JsonSerializable()
class UserUpdateLocation{
  double? lat;
  double? long;
  String? city;
  String? pincode;
  String? state;
  String? address;
  String? address2;
  String? landmark;

  UserUpdateLocation(
      {this.lat,
      this.long,
      this.city,
      this.pincode,
      this.state,
      this.address,
      this.address2,
      this.landmark});

  factory UserUpdateLocation.fromJson(Map<String, dynamic> json) => _$UserUpdateLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateLocationToJson(this);
}