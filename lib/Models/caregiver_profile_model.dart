import 'dart:convert';

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
  final String location; // <-- FIXED
  final String about; // <-- FIXED
  final Country country;
  final StateDetails state;
  final City city;

  CaregiverDetails({
    required this.caregiverId,
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
    required this.location, // <-- FIXED
    required this.about, // <-- FIXED
    required this.country,
    required this.state,
    required this.city,
  });

  factory CaregiverDetails.fromJson(Map<String, dynamic> json) =>
      CaregiverDetails(
        caregiverId: json["caregiver_id"],
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
        location: json["location"] ?? "", // <-- FIXED
        about: json["about"] ?? "", // <-- FIXED
        country: Country.fromJson(json["country"]),
        state: StateDetails.fromJson(json["state"]),
        city: City.fromJson(json["city"]),
      );
}

class City {
  final int id;
  final String cityName;

  City({required this.id, required this.cityName});

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"],
        cityName: json["city_name"] ?? "",
      );
}

class Country {
  final int id;
  final String countryName;

  Country({required this.id, required this.countryName});

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"],
        countryName: json["country_name"] ?? "",
      );
}

class StateDetails {
  final int id;
  final String stateName;

  StateDetails({required this.id, required this.stateName});

  factory StateDetails.fromJson(Map<String, dynamic> json) => StateDetails(
        id: json["id"],
        stateName: json["state_name"] ?? "",
      );
}
