import 'dart:convert';
import 'package:http/http.dart' as http;

class STEMPredictionService {
  // Change this URL to match your API endpoint from Task 2
  static const String baseUrl =
      'https://fem-2sgu.onrender.com'; // Updated with your API URL
  static const String predictEndpoint = '/predict';

  static Future<Map<String, dynamic>> predictSTEMGraduation({
    required double year,
    required double femaleEnrollmentPercentage,
    required double genderGapIndex,
    required String country,
    required String stemField,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$predictEndpoint');

      final requestBody = {
        'year': year,
        'female_enrollment_percent': femaleEnrollmentPercentage,
        'gender_gap_index': genderGapIndex,
        'country': country,
        'stem_field': stemField,
      };

      print('Sending request to: $url');
      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 422) {
        // Validation error
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error':
              'Validation Error: ${errorData['detail'] ?? 'Invalid input values'}',
        };
      } else {
        return {
          'success': false,
          'error': 'Server Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Network error: $e');
      return {
        'success': false,
        'error':
            'Network Error: Failed to connect to the prediction service. Please check your connection and ensure the API server is running.',
      };
    }
  }

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final url = Uri.parse('$baseUrl/health');

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'API service is running'};
      } else {
        return {'success': false, 'error': 'API service unavailable'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Cannot connect to API service'};
    }
  }
}
