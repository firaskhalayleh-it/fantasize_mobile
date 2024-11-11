// lib/app/modules/address/controllers/address_controller.dart

import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fantasize/app/data/models/address_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressController extends GetxController {
  // Define TextEditingControllers for each field
  TextEditingController addressLineController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController regionController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  ProfileController profileController = Get.find();
  // Store the AddressId if updating an existing address
  int? addressId;
  Address? address;

  // Base URL for your API
  final String baseUrl = '${Strings().apiUrl}/user';

  @override
  void onInit() {
    super.onInit();

    // Check if an Address object was passed as an argument
    if (Get.arguments != null &&
        Get.arguments['address'] != null &&
        Get.arguments['address'] is Address) {
      address = Get.arguments['address'] as Address;
      initializeWithAddress(address!);
    } else {
      // No address passed; we're creating a new address
      addressId = null;
      address = Address();
    }
    // If no arguments, we're creating a new address; fields remain empty
  }

  // Method to initialize controllers with existing address data
  void initializeWithAddress(Address address) {
    addressId = address.addressID;
    addressLineController.text = address.addressLine ?? '';
    streetController.text = address.state ?? '';
    regionController.text = address.postalCode ?? '';
    cityController.text = address.city ?? '';
    countryController.text = address.country ?? '';
    print('Address ID: $addressId');
    print('Address Line: ${addressLineController.text}');
    print('Street: ${streetController.text}');
    print('Region: ${regionController.text}');
    print('City: ${cityController.text}');
    print('Country: ${countryController.text}');
  }

  @override
  void onClose() {
    // Dispose of the controllers when not needed
    addressLineController.dispose();
    streetController.dispose();
    regionController.dispose();
    cityController.dispose();
    countryController.dispose();
    super.onClose();
  }

  // Save address method
  void saveAddress() async {
    String addressLine = addressLineController.text.trim();
    String street = streetController.text.trim();
    String region = regionController.text.trim();
    String city = cityController.text.trim();
    String country = countryController.text.trim();

    // (Form validation is handled in the View; no need to re-validate here)

    String? token = await secureStorage.read(key: 'jwt_token');

    if (token != null) {
      // Map token as a cookie
      var cookieHeader = 'authToken=$token';

      // Prepare the data to send
      Map<String, dynamic> data = {
        'AddressLine': addressLine,
        'City': city,
        'State': street,
        'Country': country,
        'PostalCode': region,
      };

      String url;
      http.Response response = http.Response('', 500);

      try {
        if (addressId != null) {
          // Update existing address
          data['AddressId'] = addressId;
          url = '$baseUrl/create_address_user';
          response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'cookie': cookieHeader,
            },
            body: json.encode(data),
          );
        } else {
          // Create new address
          url = '$baseUrl/create_address_user';
          response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'cookie': cookieHeader,
            },
            body: json.encode(data),
          );
        }

        if (response.statusCode == 201 || response.statusCode == 200) {
          Get.snackbar(
            'Success',
            'Address saved successfully.',
          );
          profileController.fetchUserData();
          print('Address saved successfully');

        } else {
          Get.snackbar('Error', 'Failed to save address.');
        }
      } catch (e) {
        print('Exception: $e');
        Get.snackbar('Error', 'Failed to save address: $e');
      }
    } else {
      Get.snackbar('Error', 'No token available');
    }
  }

  void deleteAddress() async {
    String? token = await secureStorage.read(key: 'jwt_token');

    if (token != null) {
      // Map token as a cookie
      var cookieHeader = 'authToken=$token';

      String url;

      try {
        if (addressId != null) {
          // Delete existing address
          url = '$baseUrl/delete_address_user/$addressId';
          http.Response response = await http.delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'cookie': cookieHeader,
            },
          );

          if (response.statusCode == 201 || response.statusCode == 200) {
            Get.snackbar(
              'Success',
              'Address deleted successfully.',
            );
            profileController.fetchUserData();
            print('Address deleted successfully');

          } else {
            print('Error: ${response.statusCode}');
            print('Response body: ${response.body}');
            Get.snackbar('Error', 'Failed to delete address.');
          }
        } else {
          Get.snackbar('Error', 'Address ID is null. Cannot delete address.');
        }
      } catch (e) {
        print('Exception: $e');
        Get.snackbar('Error', 'Failed to delete address: $e');
      }
    } else {
      Get.snackbar('Error', 'No token available');
    }
  }
}
