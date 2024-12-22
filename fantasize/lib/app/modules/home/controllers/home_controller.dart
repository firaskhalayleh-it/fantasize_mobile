// lib/app/modules/home/controllers/home_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fantasize/app/data/models/offer_model.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/data/models/user_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/explore/controllers/explore_controller.dart';
import 'package:fantasize/app/modules/home/controllers/new_arrival_controller.dart';
import 'package:fantasize/app/modules/home/controllers/offers_controller.dart';
import 'package:fantasize/app/modules/home/controllers/recommended_for_you_controller.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  // ================== Controllers ==================
  late TabController tabController;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late ExploreController exploreController;

  /// Keep the TextEditingController for the actual text field,
  /// but also have a reactive string to track changes in real-time.
  final searchController = TextEditingController();
  RxString searchText = ''.obs; // Reactive text for Obx usage

  Timer? _debounceTimer;

  // Subcategory controllers
  final OffersController offersController = Get.put(OffersController());
  final NewArrivalController newArrivalController = Get.put(NewArrivalController());
  final RecommendedForYouController recommendedForYouController =
      Get.put(RecommendedForYouController());

  // ================== Animation Controllers ==================
  late AnimationController animationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  // ================== Observable Variables ==================
  RxInt currentIndexNavigationBar = 0.obs;
  RxInt currentIndexTabBar = 0.obs;
  Rxn<User> user = Rxn<User>();
  RxList<dynamic> offersItems = <dynamic>[].obs;
  RxList<dynamic> newCollectionItems = <dynamic>[].obs;

  RxBool isLoading = false.obs;
  RxBool isQuickSearching = false.obs;
  RxBool showQuickResults = false.obs;
  RxList<dynamic> quickSearchResults = <dynamic>[].obs;

  // Categories list
  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.grid_view_rounded, "text": "All"},
    {"icon": Icons.new_label, "text": "New Arrivals"},
    {"icon": Icons.local_offer_rounded, "text": "Offers"},
    {"icon": Icons.person, "text": "Recommended"},
  ];

  // Extracted User ID from JWT (nullable)
  RxnString userId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _setupTabController();
    _setupAnimations();
    loadUserData();
    _setupNavigationBarListener();

    // 1) Load offers/new-arrivals immediately so they show up first
    fetchOffers();
    fetchNewArrivals();

    // 2) Then load user data if needed
  }

  /// Initializes necessary controllers
  void _initializeControllers() {
    // Initialize ExploreController as permanent to retain its state
    Get.put(ExploreController(), permanent: true);
    exploreController = Get.find<ExploreController>();
  }

  /// Sets up the TabController for category tabs
  void _setupTabController() {
    tabController = TabController(length: categories.length, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        currentIndexTabBar.value = tabController.index;
      }
    });
  }

  /// Sets up animations for the controller
  void _setupAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    // Start animations
    animationController.forward();
  }

  /// Sets up listener for navigation bar index changes
  void _setupNavigationBarListener() {
    ever(currentIndexNavigationBar, (index) {
      if (index != 2) {
        Get.find<ExploreController>().pauseAllVideos();
        if (Get.isRegistered<ExploreController>()) {
          exploreController = Get.find<ExploreController>();
        }
      }
    });
  }

  // ================== Search Methods ==================

  /// Performs a debounced quick search based on user input
  void performQuickSearch(String value) {
    // Update the reactive searchText so Obx can listen to it
    searchText.value = value;

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (value.isEmpty) {
      quickSearchResults.clear();
      showQuickResults.value = false;
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      isQuickSearching.value = true;
      try {
        final token = await secureStorage.read(key: 'jwt_token');
        if (token == null) {
          // If no token is found, you might skip or handle differently
          // For now, skip the search
          isQuickSearching.value = false;
          return;
        }

        final response = await http.post(
          Uri.parse('${Strings().searchUrl}?page=1&limit=5'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'cookie': 'authToken=$token',
          },
          body: jsonEncode({
            'search': {'Name': value}
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final products = responseData['data']['products'] ?? [];
          final packages = responseData['data']['packages'] ?? [];

          final combinedResults = [
            ...products.map((json) => Product.fromJson(json)),
            ...packages.map((json) => Package.fromJson(json))
          ];

          quickSearchResults.value = combinedResults;
          showQuickResults.value = true;
        }
      } catch (e) {
        print('Quick search error: $e');
      } finally {
        isQuickSearching.value = false;
      }
    });
  }

  /// Clears the search input and results
  void clearSearch() {
    searchText.value = ''; // Clear reactive text
    searchController.clear();
    quickSearchResults.clear();
    showQuickResults.value = false;
  }

  // ================== Data Loading Methods ==================

  /// Loads user data from the server (if needed)
  Future<void> loadUserData() async {
    await _extractUserIdFromToken();
    if (userId.value == null || userId.value!.isEmpty) {
      Get.snackbar('Error', 'User ID not found');
      print('User ID not found');
    }

    try {
      isLoading.value = true;
      final token = await secureStorage.read(key: 'jwt_token');
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }

      final response = await http.get(
        Uri.parse('${Strings().apiUrl}/getusers/${userId.value}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final updatedUser = User.fromJson(userData);
        user.value = updatedUser;
        await _storeUserData(userData);
        
      } else {
        Get.snackbar('Error', 'Failed to load user data');
      }
    } catch (e) {
      print('Error loading user data: $e');
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches offers from the server
  Future<void> fetchOffers() async {
    try {
      final token = await secureStorage.read(key: 'jwt_token');
      if (token == null) {
        // If your API requires a token, handle the case accordingly.
        print('No token found. Offers might not load.');
        return;
      }

      final response = await http.get(
        Uri.parse('${Strings().apiUrl}/offers_homeOffers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        offersItems.value = data
            .map((json) {
              if (json.containsKey('ProductID')) {
                return Product.fromJson(json);
              } else if (json.containsKey('PackageID')) {
                return Package.fromJson(json);
              }
              return null;
            })
            .whereType<dynamic>()
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to load offers');
      }
    } catch (e) {
      print('Error fetching offers: $e');
      Get.snackbar('Error', 'Failed to load offers');
    }
  }

  /// Fetches new arrivals from the server
  Future<void> fetchNewArrivals() async {
    try {
      final token = await secureStorage.read(key: 'jwt_token');
      if (token == null) {
        print('No token found. New arrivals might not load.');
        return;
      }

      final response = await http.get(
        Uri.parse('${Strings().apiUrl}/categories/newCollection'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        newCollectionItems.value = data
            .map((json) {
              if (json.containsKey('ProductID')) {
                return Product.fromJson(json);
              } else if (json.containsKey('PackageID')) {
                return Package.fromJson(json);
              }
              return null;
            })
            .whereType<dynamic>()
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to load new arrivals');
      }
    } catch (e) {
      print('Error fetching new arrivals: $e');
      Get.snackbar('Error', 'Failed to load new arrivals');
    }
  }

  // ================== Navigation and UI Methods ==================

  /// Navigates to the profile page
  void goToProfile() {
    Get.toNamed('/profile');
  }

  /// Changes the selected tab in the TabBar
  void changeTabBarIndex(int index) {
    if (index < categories.length && index >= 0) {
      currentIndexTabBar.value = index;
      tabController.animateTo(index);
    }
  }

  /// Changes the selected index in the NavigationBar
  void changeNavigationBarIndex(int index) {
    currentIndexNavigationBar.value = index;
  }

  // ================== Category Methods ==================

  /// Handles selection of "New Collection" subcategory
  void getNewCollectionSubcategory(String category) {
    fetchNewArrivals();
    fetchOffers();
  }

  /// Handles selection of "Offers" subcategory
  void getOffersSubcategory(String category) {
    offersController.fetchOffers();
  }

  /// Handles selection of "New Arrivals" subcategory
  void getNewArrivalsSubcategory(String category) {
    newArrivalController.fetchNewArrivals();
  }

  /// Handles selection of "Recommended For You" subcategory
  void getRecommendedForYouSubcategory(String category) {
    recommendedForYouController.fetchRecommendedForYou();
  }

  // ================== Clean Up Methods ==================

  @override
  void onClose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    tabController.dispose();
    animationController.dispose();
    super.onClose();
  }

  /// Disposes the video player in ExploreController
  
  // ================== Helper Methods ==================

  /// Extracts the user ID from the JWT token
 Future<void> _extractUserIdFromToken() async {
  final token = await secureStorage.read(key: 'jwt_token');

  if (token != null) {
    final parts = token.split('.');
    // A valid JWT usually consists of three parts (header, payload, signature)
    if (parts.length != 3) return;

    final payloadBase64 = parts[1];
    // Normalize base64 URL string before decoding
    final normalized = base64Url.normalize(payloadBase64);
    final decoded = utf8.decode(base64Url.decode(normalized));

    // Convert the decoded JSON to a Dart Map
    final data = json.decode(decoded);

    // According to the new token structure, the token data is inside 'payload'
    // e.g. { "payload": { "userId": "...", "userName": "..." }, "iat": ..., "exp": ... }
    if (data.containsKey('payload')) {
      final payloadData = data['payload'];

      // Check if 'userId' exists and is a String
      if (payloadData.containsKey('userId') && payloadData['userId'] is String) {
        userId.value = payloadData['userId'];
        print('User ID: ${userId.value}');
      } else {
        userId.value = null;
        print('User ID not found in token payload');
      }
    } else {
      userId.value = null;
      print('Token payload not found');
    }
  } else {
    userId.value = null;
    print('No token found');
  }

  return;
}


  /// Stores user data securely
  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    await secureStorage.write(key: 'user_data', value: jsonEncode(userData));
  }
}
