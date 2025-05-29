import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SellerSignupService {
  static Future<Map<String, dynamic>> signup({
    required String businessName,
    required String firstname,
    required String middlename,
    required String lastname,
    required String email,
    required String password,
    required String conpas,
    required String phone,
    required String province,
    required String municipality,
    required String barangay,
    required String zipcode,
    required String role,
    required File validIdFile,
    required File businessPermitFile,
  }) async {
    try {
      var uri = Uri.parse('http://192.168.213.19:5000/seller_signup');
      var request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields.addAll({
        'business_name': businessName,
        'firstname': firstname,
        'middlename': middlename,
        'lastname': lastname,
        'seller_email': email,  // Ensure correct key for seller_email
        'password': password,
        'conpas': conpas,
        'phone': phone,
        'province': province,
        'municipality': municipality,
        'barangay': barangay,
        'zipcode': zipcode,
        'role': role,
      });

      // Add files
      request.files.add(await http.MultipartFile.fromPath('valid_id', validIdFile.path));
      request.files.add(await http.MultipartFile.fromPath('business_permit', businessPermitFile.path));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseBody = json.decode(response.body);

      // Check server response
      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {'success': false, 'message': responseBody['message'] ?? "Signup failed"};
      }
    } catch (e) {
      print("Error: $e");
      return {'success': false, 'message': "An error occurred. Please try again."};
    }
  }
}
