import 'package:fantasize/app/modules/explore/controllers/explore_controller.dart';
import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../../data/models/user_model.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late ExploreController exploreController;

  RxInt currentIndexNavigationBar = 0.obs; // Bottom Navigation Bar index
  RxInt currentIndexTabBar = RxInt(0); // TabBar index (only for Home)
  Rxn<User> user = Rxn<User>(); // User data fetched from secure storage

  // List of categories (for the TabBar in the Home page)
  List<Map<String, dynamic>> categories = [
    {"icon": Icons.grid_view_rounded, "text": "All"},
    {"icon": Icons.new_label, "text": "New Arrivals"},
    {"icon": Icons.local_offer_rounded, "text": "Offers"},
    {"icon": Icons.person, "text": "Recommended"},
  ];

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => ExploreController());
    exploreController = Get.find<ExploreController>();

    tabController = TabController(length: categories.length, vsync: this);

    // Listen to tab changes in TabBar and update currentIndexTabBar
    tabController.addListener(() {
      currentIndexTabBar.value = tabController.index;
    });

    loadUserData(); // Load user data from secure storage
  }

  void changeTabBarIndex(int index) {
    currentIndexTabBar.value = index;
  }

  void changeNavigationBarIndex(int index) {
    if (currentIndexNavigationBar.value == 2 && index != 2) {
      exploreController.disableAllControllers();
    }

    currentIndexNavigationBar.value = index;
  }

  // Load user data from secure storage
  Future<void> loadUserData() async {
    String? userData = await secureStorage.read(key: 'user_data');
    if (userData != null) {
      user.value = User.fromJson(jsonDecode(userData));
    }


    if (user.value != null) {
      print('Username: ${user.value!.username}');
      print('Email: ${user.value!.email}');
      print('Profile Picture: ${user.value!.userProfilePicture?.filePath}');
    }
  
    if (userData != null) {
      user.value = User.fromJson(jsonDecode(userData));
    }
  }

  // Return the username of the user
  String getUserName() {
    return user.value?.username.isNotEmpty == true ? user.value!.username : 'User';
  }

  void goToProfile() {
    Get.toNamed('/profile');
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
