import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../data/models/user_model.dart';
import '../../../global/strings.dart';

class ProfileController extends GetxController {
  var user = Rxn<User>(); // Rxn will allow null values
  var isLoading = true.obs;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Fetch user data using the user ID from the JWT token
  Future<void> fetchUserData() async {
    try {
      isLoading(true);

      // Get JWT token from secure storage
      String? token = await secureStorage.read(key: 'jwt_token');

      if (token != null) {
        // Decode the token to get the user ID
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken['payload']['userId']; // Extract user ID

        // Send the token as a cookie in the request
        var cookieHeader = 'authToken=$token'; // Name of the cookie as 'authToken'

        // Fetch user data from the API
        final response = await http.get(
          Uri.parse('${Strings().apiUrl}/getusers/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': cookieHeader, // Send the token as a cookie
          },
        );

        // Debugging: Print the response status and body
      
        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          var fetchedUser = User.fromJson(jsonData);

         
          // Update the user data in the controller
          user.value = fetchedUser;
        } else {
          Get.snackbar('Error', 'Failed to load user data');
        }
      } else {
        Get.snackbar('Error', 'No token found. Please login again.');
        Get.offAllNamed('/login'); // Redirect to login if no token
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Function to log out the user
  Future<void> logout() async {
    await secureStorage.delete(key: 'jwt_token');
    await secureStorage.delete(key: 'user_data');
    user.value = null;
    Get.offAllNamed('/login'); // Navigate back to the login page
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserData(); // Fetch user data when the controller initializes
  }
}
