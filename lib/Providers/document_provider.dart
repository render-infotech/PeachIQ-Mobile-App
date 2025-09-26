import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:peach_iq/constants/api_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> uploadDocument({
    required String documentName,
    String? type,
    String? membershipName,
    required PlatformFile file,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final caregiverId = prefs.getInt('caregiver_id');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }
      if (caregiverId == null) {
        throw Exception('Caregiver ID not found. Please log in again.');
      }

      final uri = Uri.parse(ApiUrls.AddDocument());
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['caregiver_id'] = caregiverId.toString();
      request.fields['document_name'] = documentName;

      request.fields['type'] = (type != null && type.isNotEmpty) ? type : 'NA';
      request.fields['membership_name'] =
          (membershipName != null && membershipName.isNotEmpty)
              ? membershipName
              : 'NA';

      if (issueDate != null) {
        request.fields['issue_date'] =
            DateFormat('yyyy-MM-dd').format(issueDate);
      } else {
        request.fields['issue_date'] = 'NA';
      }

      if (expiryDate != null) {
        request.fields['expiry_date'] =
            DateFormat('yyyy-MM-dd').format(expiryDate);
      } else {
        request.fields['expiry_date'] = 'NA';
      }

      // Attach file (required)
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        // Prefer bytes whenever available (works on web and some desktops)
        request.files.add(
          http.MultipartFile.fromBytes(
            'document',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null && file.path!.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'document',
            file.path!,
            filename: file.name,
          ),
        );
      } else {
        throw Exception('Document file is mandatory');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final decodedBody = json.decode(responseBody);
        _errorMessage = decodedBody['message'] ?? 'Failed to upload document.';
        throw Exception('API Error (${response.statusCode}): $_errorMessage');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error uploading document: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
