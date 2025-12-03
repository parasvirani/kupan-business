import 'package:json_annotation/json_annotation.dart';
part 'business_outlets_res.g.dart';

@JsonSerializable()
class BusinessOutletsRes {
  bool? success;
  String? message;
  int? statusCode;
  List<OutletData>? data;

  BusinessOutletsRes({this.success, this.message, this.statusCode, this.data});

  factory BusinessOutletsRes.fromJson(Map<String, dynamic> json) => _$BusinessOutletsResFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessOutletsResToJson(this);
}

@JsonSerializable()
class OutletData {
  String? email;
  String? businessName;
  String? businessType;
  String? outletName;
  List<String>? outletDay;
  String? outletTime;
  List<String>? outletImages;
  String? outletNumber;
  OutletLocation? location;
  @JsonKey(name: "_id")
  String? id;

  OutletData({
    this.email,
    this.businessName,
    this.businessType,
    this.outletName,
    this.outletDay,
    this.outletTime,
    this.outletImages,
    this.outletNumber,
    this.location,
    this.id,
  });

  factory OutletData.fromJson(Map<String, dynamic> json) => _$OutletDataFromJson(json);

  Map<String, dynamic> toJson() => _$OutletDataToJson(this);
}

@JsonSerializable()
class OutletLocation {
  double? lat;
  double? long;
  String? city;
  String? pincode;
  String? state;
  String? address;

  OutletLocation({
    this.lat,
    this.long,
    this.city,
    this.pincode,
    this.state,
    this.address,
  });

  factory OutletLocation.fromJson(Map<String, dynamic> json) => _$OutletLocationFromJson(json);

  Map<String, dynamic> toJson() => _$OutletLocationToJson(this);
}

