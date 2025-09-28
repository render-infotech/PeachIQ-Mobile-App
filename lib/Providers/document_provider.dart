import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
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

      if (kDebugMode) {
        print('=== FILE DEBUG INFO ===');
        print('File name: ${file.name}');
        print('File size: ${file.size}');
        print('File extension: ${file.extension}');
        print('File bytes is null: ${file.bytes == null}');
        print('File path is null: ${file.path == null}');
        if (file.bytes != null) {
          print('File bytes length: ${file.bytes!.length}');
        }
        if (file.path != null) {
          print('File path: ${file.path}');
        }
      }

      bool fileAdded = false;

      String getMimeType(String extension) {
        switch (extension.toLowerCase()) {
          case 'pdf':
            return 'application/pdf';
          case 'doc':
            return 'application/msword';
          case 'docx':
            return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          case 'jpg':
          case 'jpeg':
            return 'image/jpeg';
          case 'png':
            return 'image/png';
          default:
            return 'application/octet-stream';
        }
      }

      if (file.bytes != null && file.bytes!.isNotEmpty) {
        if (kDebugMode) {
          print('Adding file from bytes (web)');
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'document_file',
            file.bytes!,
            filename: file.name,
            contentType:
                http_parser.MediaType.parse(getMimeType(file.extension ?? '')),
          ),
        );
        fileAdded = true;
      } else if (file.path != null && file.path!.isNotEmpty) {
        if (kDebugMode) {
          print('Adding file from path (mobile): ${file.path}');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'document_file',
            file.path!,
            filename: file.name,
            contentType:
                http_parser.MediaType.parse(getMimeType(file.extension ?? '')),
          ),
        );
        fileAdded = true;
      }

      if (!fileAdded) {
        if (kDebugMode) {
          print('ERROR: No file could be added to request');
        }
        throw Exception(
            'Document file is mandatory - no valid file data found');
      }

      if (kDebugMode) {
        print('Request files count: ${request.files.length}');
        print('Request fields: ${request.fields}');
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
