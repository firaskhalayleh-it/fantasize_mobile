import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/modules/cart/controllers/cart_controller.dart';
import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';

class PackageDetailsController extends GetxController {
  final storage = FlutterSecureStorage();
  var package = Rxn<Package>();
  var isLoading = false.obs;
  var quantity = 1.obs;
  var isLiked = false.obs;
  var currentUsername = ''.obs;
  var isReviewFormVisible = false.obs;
  var isEditing = false.obs;
  var reviewBeingEdited = Rxn<Review>();
  var TotalPrice = 0.0.obs;

  final cartController = Get.find<CartController>();

  @override
  void onInit() {
    super.onInit();
    var arguments = Get.arguments;

    if (arguments == null) {
      Get.snackbar('Error', 'No package ID provided.');
      return;
    }

    int packageId = arguments as int;
    fetchPackageDetails(packageId);
    checkIfLiked(packageId);
  }

  void incrementQuantity() => quantity.value++;
  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  Future<void> fetchPackageDetails(int packageId) async {
    isLoading.value = true;
    final token = await storage.read(key: 'jwt_token');

    if (token == null) {
      Get.snackbar('Authorization Error', 'Token is not available.');
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Strings().apiUrl}/packages/$packageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'cookie': 'authToken=$token',
        },
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data is Map<String, dynamic>) {
          package.value = Package.fromJson(data);

          // make the video is the first item in the resources list
          if (package.value!.resources.isNotEmpty) {
            var videoIndex = package.value!.resources
                .indexWhere((element) => element.fileType == 'video/mp4');
            if (videoIndex != -1) {
              var video = package.value!.resources.removeAt(videoIndex);
              package.value!.resources.insert(0, video);
            }
          }
        } else {
          Get.snackbar('No Data', 'No package data found for this ID.');
        }
      } else if (response.statusCode == 401) {
        Get.snackbar(
            'Unauthorized', 'Your session has expired. Please log in again.');
      } else {
        Get.snackbar('Error',
            'Failed to fetch package details. Error code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Network Error',
          'Unable to fetch package details. Please try again later.');
      print('Error fetching package details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  toggleLike() async {
    final isCurrentlyLiked = isLiked.value ?? false;
    try {
      String? token = await storage.read(key: 'jwt_token');
      var url;
      if (!isCurrentlyLiked) {
        // Add product to favorites
        url = Uri.parse(
            '${Strings().apiUrl}/favoritePackages/${package.value!.packageId}');
        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
            'Accept': 'application/json',
            'cookie': 'authToken=$token',
          },
        );

        if (response.statusCode != 200) {
          print(response.body);
          print(response.statusCode);
          Get.snackbar('Error', 'Failed to add package to favorites');
          return;
        }

        print(response.body);
        print(response.statusCode);

        isLiked.value = true;
        Get.snackbar('Success', 'Package added to favorites', overlayBlur: 3.0);
      } else {
        // Remove product from favorites
        url = Uri.parse(
            '${Strings().apiUrl}/favoritePackages/${package.value!.packageId}');
        await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
            'Accept': 'application/json',
            'cookie': 'authToken=$token',
          },
        );
        isLiked.value = false;
        Get.snackbar('Success', 'Package removed from favorites');
      }

      // Reload the favorites after the product is added/removed from the list
      final FavoritesController favoritesController =
          Get.find<FavoritesController>();
      favoritesController.reloadFavorites();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorites: $e');
    }
  }

  Future<void> checkIfLiked(int packageId) async {
    try {
      String? token = await storage.read(key: 'jwt_token');
      var url = Uri.parse('${Strings().apiUrl}/favoritePackages');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
          'Accept': 'application/json',
          'cookie': 'authToken=$token',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var favoritePackages = jsonData as List<dynamic>;

        // Check if the package exists in the favorites list by PackageID
        isLiked.value = favoritePackages.any((favorite) {
          var favoritePackage = favorite['Package'];
          return favoritePackage != null &&
              favoritePackage['PackageID'] == packageId;
        });
      } else {
        Get.snackbar('Error', 'Failed to fetch favorite packages');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch favorite packages: $e');
    }
  }

  Future<void> fetchCurrentUser() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String username = decodedToken['payload']['userName'];
      currentUsername.value = username;
    }
  }

  bool isReviewFromCurrentUser(Review review) {
    return review.user!.username == currentUsername.value;
  }

  bool changeReviewFormVisibility() {
    isReviewFormVisible.value = !isReviewFormVisible.value;
    return isReviewFormVisible.value;
  }

  void startEditingReview(Review review) {
    isEditing(true);
    reviewBeingEdited.value = review;
  }

  Future<void> addOrUpdateReview(
      int PackageId, String comment, int rating) async {
    String? token = await storage.read(key: 'jwt_token');
    var url;
    var method;
    var reviewId = reviewBeingEdited.value?.reviewId;

    // If we are editing an existing review
    if (isEditing.value && reviewId != null) {
      url = Uri.parse('${Strings().apiUrl}/reviews/$reviewId');
      method = http.put;
    } else {
      // New review
      url = Uri.parse('${Strings().apiUrl}/reviews/package');
      method = http.post;
    }

    var response = await method(
      url,
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
        'Accept': 'application/json',
        'cookie': 'authToken=$token'
      },
      body: json.encode({
        'PackageId': PackageId,
        'Comment': comment,
        'Rating': rating,
      }),
    );

    if (response.statusCode == 200) {
      // Hide the form after successful submission
      isEditing(false);
      isReviewFormVisible(false);

      // Refresh the product details to reflect the added/updated review
      await fetchPackageDetails(PackageId);

      Get.snackbar(
          'Success', isEditing.value ? 'Review updated!' : 'Review added!',
          overlayBlur: 2);
    } else {
      Get.snackbar('Error', 'Failed to add/update review');
    }
  }

  void toggleReviewFormVisibility() {
    isReviewFormVisible.value = !isReviewFormVisible.value;
  }

  Future<void> deleteReview(int reviewId, int productId) async {
    String? token = await storage.read(key: 'jwt_token');
    var url = Uri.parse('${Strings().apiUrl}/reviews/$reviewId');

    var response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
        'Accept': 'application/json',
        'cookie': 'authToken=$token'
      },
    );

    if (response.statusCode == 200) {
      fetchPackageDetails(productId); // Refresh product details after deletion
    } else {
      Get.snackbar('Error', 'Failed to delete review');
    }
  }

  calcTotalPrice() {
    if (package.value != null) {
      TotalPrice.value = package.value!.price * quantity.value;
    } else {
      TotalPrice.value = 0.0;
    }
    return TotalPrice.value;
  }

   void showAddToCartDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        width: Get.width,
        height: Get.height * 0.28,
        color: Colors.white,
        child: Column(
          children: [
            Text(
              'Product added to cart',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/cart'); // Navigate to the checkout page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: Get.height * 0.025, horizontal: Get.width * 0.3),
              ),
              child: Text(
                'Go to checkout',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Jost', fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.until((route) => route.settings.name == '/products');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: Get.height * 0.025, horizontal: Get.width * 0.27),
              ),
              child: Text(
                'Continue shopping',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Jost', fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle adding a product to the cart
  Future<void> addToCart(
      Package package, List<OrderedOption> orderedOptions, int quantity) async {
    try {
      String? token = await storage.read(key: 'jwt_token');
      var response = await http.post(
        Uri.parse('${Strings().apiUrl}/orderpackage'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
          'cookie': 'authToken=$token',
        },
        body: json.encode({
          "packageId": package.packageId,
          "quantity": quantity,
          "orderedOptions":
              orderedOptions.map((option) => option.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Product added to cart');
        showAddToCartDialog();
        cartController.fetchCart();
      
      } else {
        Get.snackbar('Error', 'Failed to add product to cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product to cart: $e');
    }
  }

  List<OrderedOption> convertCustomizationsToOrderedOptions(
      List<Customization> customizations) {
    return customizations.map((customization) {
      return OrderedOption(
        name: customization.options.first.name,
        type: customization.options.first.type,
        optionValues:
            customization.options.first.optionValues.map((optionValue) {
          return OrderedOptionValue(
            name: optionValue.value,
            value: optionValue.value,
            isSelected: optionValue.isSelected,
          );
        }).toList(),
      );
    }).toList();
  }

  void navigateToCart() {
    Get.toNamed('/cart');
  }
}
