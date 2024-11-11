import 'package:fantasize/app/data/models/offer_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/explore/controllers/explore_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/models/user_model.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late ExploreController exploreController;

  RxInt currentIndexNavigationBar = 0.obs; // Bottom Navigation Bar index
  RxInt currentIndexTabBar = RxInt(0); // TabBar index (only for Home)
  Rxn<User> user = Rxn<User>(); // User data fetched from secure storage
  RxList<Product> newCollectionProducts = <Product>[].obs;

  // List of categories (for the TabBar in the Home page)
  List<Map<String, dynamic>> categories = [
    {"icon": Icons.grid_view_rounded, "text": "All"},
    {"icon": Icons.new_label, "text": "New Arrivals"},
    {"icon": Icons.local_offer_rounded, "text": "Offers"},
    {"icon": Icons.person, "text": "Recommended"},
  ];
  RxList<Offer> offers = <Offer>[].obs;

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

    fetchOffers();
    fetchNewCollectionProducts(); // Fetch new collection products

    loadUserData(); // Load user data from secure storage
  }

  Future<void> fetchOffers() async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? token = await secureStorage.read(key: 'jwt_token');
    final response = await http
        .get(Uri.parse('${Strings().apiUrl}/offers_homeOffers'), headers: {
      'Content-Type': 'application/json',
      'cookie': 'authToken=$token',
    });

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      offers.value = data.map((json) => Offer.fromJson(json)).toList();
    } else {
      // Handle error
      print('Failed to load offers');
    }
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

  Future<void> fetchNewCollectionProducts() async {
    String? token = await secureStorage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('${Strings().apiUrl}/categories/newCollection'),
      headers: {
        'Content-Type': 'application/json',
        'cookie': 'authToken=$token',
      },
    );

    print('New Collection Products: ${newCollectionProducts.length}');
    print('status code: ${response.statusCode}');
    print('response body: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      newCollectionProducts.value =
          data.map((json) => Product.fromJson(json)).toList();
    } else {
      // Handle error
      print('Failed to load new collection products');
    }
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
    return user.value?.username.isNotEmpty == true
        ? user.value!.username
        : 'User';
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
