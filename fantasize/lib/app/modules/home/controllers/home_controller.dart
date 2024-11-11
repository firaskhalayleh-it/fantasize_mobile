// lib/app/modules/home/controllers/home_controller.dart

import 'package:fantasize/app/data/models/offer_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/explore/controllers/explore_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/models/user_model.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late ExploreController exploreController;

  RxInt currentIndexNavigationBar = 0.obs;
  RxInt currentIndexTabBar = 0.obs;
  Rxn<User> user = Rxn<User>();
  RxList<dynamic> offersItems = <dynamic>[].obs; // Stores both Product and Package
  RxList<dynamic> newCollectionItems = <dynamic>[].obs;

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

    tabController.addListener(() {
      currentIndexTabBar.value = tabController.index;
    });

    fetchOffers();
    fetchNewArrivals();
    loadUserData();
  }

  Future<void> fetchOffers() async {
    String? token = await secureStorage.read(key: 'jwt_token');
    final response = await http
        .get(Uri.parse('${Strings().apiUrl}/offers_homeOffers'), headers: {
      'Content-Type': 'application/json',
      'cookie': 'authToken=$token',
    });

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Parse offers to handle both Product and Package types
      offersItems.value = data.map((json) {
        if (json.containsKey('ProductID')) {
          return Product.fromJson(json);
        } else if (json.containsKey('PackageID')) {
          return Package.fromJson(json);
        } else {
          return null;
        }
      }).whereType<dynamic>().toList(); // Filter out any null values

      // print resources for each offer
  
    } else {
      print('Failed to load offers');
    }
  }

  Future<void> fetchNewArrivals() async {
    String? token = await secureStorage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('${Strings().apiUrl}/categories/newCollection'),
      headers: {
        'Content-Type': 'application/json',
        'cookie': 'authToken=$token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Parse new arrivals to handle both Product and Package types
      newCollectionItems.value = data.map((json) {
        if (json.containsKey('ProductID')) {
          return Product.fromJson(json);
        } else if (json.containsKey('PackageID')) {
          return Package.fromJson(json);
        } else {
          return null;
        }
      }).whereType<dynamic>().toList(); // Filter out any null values
    } else {
      print('Failed to load new arrivals');
    }
  }

  Future<void> loadUserData() async {
    String? userData = await secureStorage.read(key: 'user_data');
    if (userData != null) {
      user.value = User.fromJson(jsonDecode(userData));
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  String getUserName() {
    return user.value?.username ?? '';
  }

  void goToProfile() {
    Get.toNamed('/profile');
  }

  void changeTabBarIndex(int index) {
    currentIndexTabBar.value = index;
    tabController.animateTo(index);
  }

  void changeNavigationBarIndex(int index) {
    currentIndexNavigationBar.value = index;
  }
}
