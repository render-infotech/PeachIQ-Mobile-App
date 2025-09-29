import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/constants/api_utils.dart';
import 'package:peach_iq/models/caregiver_profile_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileUpdateProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ProfileData?> fetchCaregiverDetailsForUpdate() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception('Authentication token not found');

      final uri = Uri.parse(ApiUrls.getCaregiver());
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final decodedResponse = caregiverProfileResponseFromJson(response.body);
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(
            'caregiver_id',
            decodedResponse.data.caregiverDetails.caregiverId,
          );
        } catch (_) {}
        return decodedResponse.data;
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            responseBody['message'] ?? 'Failed to load profile details');
      }
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePhoneNumber({
    required BuildContext context,
    required ProfileData profileData,
    required String newPhoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception('Token not found');

      final uri = Uri.parse(ApiUrls.updateCaregiverStep1());
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      final details = profileData.caregiverDetails;

      request.fields['caregiver_id'] = details.caregiverId.toString();
      request.fields['first_name'] = profileData.firstName;
      request.fields['last_name'] = profileData.lastName;
      request.fields['email'] = profileData.email;
      request.fields['gender'] = details.gender.toString();
      request.fields['social_id'] = details.socialId;
      request.fields['country_id'] = details.countryId.toString();
      request.fields['state_id'] = details.stateId.toString();
      request.fields['city_id'] = details.cityId.toString();
      request.fields['address_line'] = details.addressLine;
      request.fields['location'] = details.location;
      request.fields['about'] = details.about;
      request.fields['phone_1_country_code'] = details.phone1CountryCode;
      request.fields['phone_1_code'] = details.phone1Code;
      request.fields['postal_code'] = details.postalCode;

      request.fields['phone_1'] = newPhoneNumber;

      if (details.phone2CountryCode != null) {
        request.fields['phone_2_country_code'] = details.phone2CountryCode!;
      }
      if (details.phone2Code != null) {
        request.fields['phone_2_code'] = details.phone2Code!;
      }
      if (details.phone2 != null) {
        request.fields['phone_2'] = details.phone2!;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await Provider.of<ProfileProvider>(context, listen: false)
            .fetchMyProfile();
        return true;
      } else {
        final responseBody = json.decode(response.body);
        _errorMessage = responseBody['message'] ?? 'Failed to update profile';
        throw Exception(_errorMessage);
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress({
    required BuildContext context,
    required ProfileData profileData,
    required int newCountryId,
    required int newStateId,
    required int newCityId,
    required String newAddressLine,
    required String newPostalCode,
    required String newLocation,
    required String newAbout,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception('Token not found');

      final uri = Uri.parse(ApiUrls.updateCaregiverStep1());
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      final details = profileData.caregiverDetails;

      // Populate non-address fields from existing profile data
      request.fields['caregiver_id'] = details.caregiverId.toString();
      request.fields['first_name'] = profileData.firstName;
      request.fields['last_name'] = profileData.lastName;
      request.fields['email'] = profileData.email;
      request.fields['gender'] = details.gender.toString();
      request.fields['social_id'] = details.socialId;
      request.fields['phone_1_country_code'] = details.phone1CountryCode;
      request.fields['phone_1_code'] = details.phone1Code;
      request.fields['phone_1'] = details.phone1;
      if (details.phone2CountryCode != null)
        request.fields['phone_2_country_code'] = details.phone2CountryCode!;
      if (details.phone2Code != null)
        request.fields['phone_2_code'] = details.phone2Code!;
      if (details.phone2 != null) request.fields['phone_2'] = details.phone2!;

      // Populate with NEW address data from the popup
      request.fields['country_id'] = newCountryId.toString();
      request.fields['state_id'] = newStateId.toString();
      request.fields['city_id'] = newCityId.toString();
      request.fields['address_line'] = newAddressLine;
      request.fields['postal_code'] = newPostalCode;
      request.fields['location'] = newLocation;
      request.fields['about'] = newAbout;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await Provider.of<ProfileProvider>(context, listen: false)
            .fetchMyProfile();
        return true;
      } else {
        final responseBody = json.decode(response.body);
        _errorMessage = responseBody['message'] ?? 'Failed to update address';
        throw Exception(_errorMessage);
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
