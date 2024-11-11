import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthController extends GetxController {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  var isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    String? token = await secureStorage.read(key: 'jwt_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      isAuthenticated.value = true;
      // Optionally, decode the token and set user data here
    } else {
      await secureStorage.deleteAll();
      isAuthenticated.value = false;
    }
  }

  Future<void> login(String token) async {
    await secureStorage.write(key: 'jwt_token', value: token);
    isAuthenticated.value = true;
  }

  Future<void> logout() async {
    await secureStorage.deleteAll();
    isAuthenticated.value = false;
  }
}
