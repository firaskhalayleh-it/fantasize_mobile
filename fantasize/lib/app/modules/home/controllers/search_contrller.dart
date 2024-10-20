import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeSearchController extends GetxController {
  var searchQuery = ''.obs; // Observable string to track the search query
  TextEditingController searchController = TextEditingController();

  // Method to handle search bar input changes
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  // Dispose of the controller when not needed
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
