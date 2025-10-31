import 'dart:convert';
import 'package:peach_iq/Models/caregiver_profile_model.dart';
import 'package:peach_iq/Models/get_address_model.dart';

CaregiverProfileResponse caregiverProfileResponseFromJson(String str) =>
    CaregiverProfileResponse.fromJson(json.decode(str));

class CaregiverProfileResponse {
  final ProfileData data;
  final String message;
  final int status;

  CaregiverProfileResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory CaregiverProfileResponse.fromJson(Map<String, dynamic> json) =>
      CaregiverProfileResponse(
        data: ProfileData.fromJson(json["data"]),
        message: json["message"] ?? "",
        status: json["status"] ?? 500,
      );
}

class ProfileData {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final CaregiverDetails caregiverDetails;

  ProfileData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.caregiverDetails,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
        id: json["id"],
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        email: json["email"] ?? "",
        caregiverDetails: CaregiverDetails.fromJson(json["caregiver_details"]),
      );
}

class CaregiverDetails {
  final int caregiverId;
  final String caregiverIdentifier;
  final int gender;
  final String socialId;
  final int countryId;
  final int stateId;
  final int cityId;
  final String addressLine;
  final String postalCode;
  final String phone1;
  final String phone1CountryCode;
  final String phone1Code;
  final String? phone2;
  final String? phone2CountryCode;
  final String? phone2Code;
  final String location;
  final String about;
  final Country country;
  final StateDetails state;
  final City city;

  CaregiverDetails({
    required this.caregiverId,
    required this.caregiverIdentifier,
    required this.gender,
    required this.socialId,
    required this.countryId,
    required this.stateId,
    required this.cityId,
    required this.addressLine,
    required this.postalCode,
    required this.phone1,
    required this.phone1CountryCode,
    required this.phone1Code,
    this.phone2,
    this.phone2CountryCode,
    this.phone2Code,
    required this.location,
    required this.about,
    required this.country,
    required this.state,
    required this.city,
  });

  factory CaregiverDetails.fromJson(Map<String, dynamic> json) =>
      CaregiverDetails(
        caregiverId: json["caregiver_id"],
        caregiverIdentifier: json["caregiver_identifier"] ?? "",
        gender: json["gender"],
        socialId: json["social_id"] ?? "",
        countryId: json["country_id"],
        stateId: json["state_id"],
        cityId: json["city_id"],
        addressLine: json["address_line"] ?? "",
        postalCode: json["postal_code"] ?? "",
        phone1: json["phone_1"] ?? "",
        phone1CountryCode: json["phone_1_country_code"] ?? "",
        phone1Code: json["phone_1_code"] ?? "",
        phone2: json["phone_2"],
        phone2CountryCode: json["phone_2_country_code"],
        phone2Code: json["phone_2_code"],
        location: json["location"] ?? "",
        about: json["about"] ?? "",
        country: Country.fromJson(json["country"]),
        state: StateDetails.fromJson(json["state"]),
        city: City.fromJson(json["city"]),
      );
}

// DELETE THE City, Country, and StateDetails CLASSES FROM HERE
