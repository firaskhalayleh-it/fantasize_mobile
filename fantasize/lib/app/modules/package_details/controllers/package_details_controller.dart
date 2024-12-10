import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/ordered_customization.dart';
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
  List<OrderedCustomization> orderedCustomizations = [];
  final Map<String, RxBool> _attachMessageVisibility = {};
  var package = Rxn<Package>();
  var isLoading = false.obs;
  var quantity = 1.obs;
  var isLiked = false.obs;
  var currentUsername = ''.obs;
  var isReviewFormVisible = false.obs;
  var isEditing = false.obs;
  var reviewBeingEdited = Rxn<Review>();
  var TotalPrice = 0.0.obs;
  final Map<String, TextEditingController> _textControllers = {};

  // Map to store image paths for uploadPicture options
  final Map<String, RxString> _uploadedImages = {};
  final cartController = Get.find<CartController>();
  var InitialPrice = 0.0;
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
          // Parse package data
          package.value = Package.fromJson(data);

          InitialPrice = package.value!.price;
          // Sort resources: videos first, images last
          package.value!.resources.sort((a, b) {
            if (a.fileType == 'video/mp4' && b.fileType != 'video/mp4') {
              return -1; // Video comes before non-video
            } else if (a.fileType != 'video/mp4' && b.fileType == 'video/mp4') {
              return 1; // Non-video comes after video
            }
            return 0; // No change if both are the same type
          });

          // Initialize ordered customizations after sorting
          initializeOrderedCustomizations();
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
      body: isEditing.value && reviewId != null
          ? json.encode({
              'Rating': rating,
              'Comment': comment,
            })
          : json.encode({
              'PackageId': PackageId,
              'Rating': rating,
              'Comment': comment,
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

  TextEditingController getTextController(
      int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController();
      // Listen to changes and update the option value
      _textControllers[key]!.addListener(() {
        updateSelectedOption(
            customizationId, optionName, _textControllers[key]!.text);
      });
    }
    return _textControllers[key]!;
  }

  // Method to get image path
  RxString getUploadedImagePath(int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    if (!_uploadedImages.containsKey(key)) {
      _uploadedImages[key] = ''.obs;
    }
    return _uploadedImages[key]!;
  }

  // Method to update image path
  void updateUploadedImage(
      int customizationId, String optionName, String imagePath) {
    final key = '$customizationId-$optionName';
    getUploadedImagePath(customizationId, optionName).value = imagePath;
    // Update the OptionValue in orderedCustomizations
    updateSelectedOption(customizationId, optionName, imagePath);
  }
  // handle the ordered customizations

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

  String calcTotalPrice() {
    // Parse the base price from the package and calculate total price based on quantity
    double basePrice = (package.value?.price ?? 0.0);
    basePrice *= quantity.value;

    double discount = 0.0;

    // Check if the package has a valid active offer
    if (package.value != null &&
        package.value!.offer != null &&
        package.value!.offer!.isActive &&
        package.value!.offer!.discount.isNotEmpty) {
      var offer = package.value!.offer!;
      // Calculate percentage-based discount
      double offerDiscount = double.tryParse(offer.discount) ?? 0.0;
      discount = (basePrice * offerDiscount) / 100;
    }

    // Calculate the total price after applying the discount
    double totalPrice = basePrice - discount;

    print('Calculated Total Price: $totalPrice');

    // Ensure the result is formatted to 2 decimal places
    return totalPrice.toStringAsFixed(2);
  }

  String getThePrice() {
    // Parse the base price from the package
    double basePrice = (InitialPrice);

    double discount = 0.0;

    // Check if the package has a valid active offer
    if (package.value!.offer != null &&
        package.value!.offer!.isActive &&
        package.value!.offer!.discount.isNotEmpty) {
      var offer = package.value!.offer!;
      // Calculate percentage-based discount
      double offerDiscount = double.tryParse(offer.discount) ?? 0.0;
      discount = (basePrice * offerDiscount) / 100;
    }

    // Calculate the price after applying the discount
    double priceWithDiscount = basePrice - discount;

    print('Price with Discount: $priceWithDiscount');

    // Ensure the result is formatted to 2 decimal places
    return priceWithDiscount.toStringAsFixed(2);
  }

  void showAddToCartDialog() {
    Get.bottomSheet(AddToCartBottomSheet());
  }

  // Function to handle adding a product to the cart
  Future<void> addToCart(Package package,
      List<OrderedCustomization> orderedCustomizations, int quantity) async {
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
              orderedCustomizations.map((option) => option.toJson()).toList(),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print(
          'Ordered options: ${json.encode(orderedCustomizations.map((option) => option.toJson()).toList())}');
      debugPrint(response.statusCode.toString());
      print('orderedCustomizations: ');
      orderedCustomizations.forEach((element) {
        print(element.toJson());
      });

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'package added to cart');
        showAddToCartDialog();
        cartController.fetchCart();
      } else {
        Get.snackbar('Error', 'Failed to add package to cart');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add package to cart: $e');
    }
  }

  List<OrderedCustomization> convertCustomizationsToOrderedCustomization(
      List<Customization> customizations) {
    return customizations.map((customization) {
      return OrderedCustomization(
        orderedCustomizationId: customization.customizationId,
        selectedOptions: customization.options.map((option) {
          return OrderedOption(
            name: option.name,
            type: option.type,
            optionValues: option.optionValues.map((optionValue) {
              return OrderedOptionValue(
                name: optionValue.name,
                value: optionValue.value,
                isSelected: optionValue.isSelected,
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  void initializeOrderedCustomizations() {
    if (package.value == null || package.value!.customizations.isEmpty) return;

    // Use a Set to keep track of customization IDs we've already added
    final Set<int> seenCustomizationIds = {};

    orderedCustomizations =
        package.value!.customizations.where((customization) {
      if (seenCustomizationIds.contains(customization.customizationId)) {
        return false; // If already seen, exclude it
      } else {
        seenCustomizationIds.add(customization.customizationId);
        return true; // Include if not seen
      }
    }).map((customization) {
      return OrderedCustomization(
        orderedCustomizationId: customization.customizationId,
        selectedOptions: customization.options.map((option) {
          return OrderedOption(
            name: option.name,
            type: option.type,
            optionValues: option.optionValues.map((value) {
              return OrderedOptionValue(
                name: value.name,
                value: value.value,
                isSelected: false, // Use RxBool for observability
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  // Method to get the visibility observable
  RxBool getAttachMessageVisibility(int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    if (!_attachMessageVisibility.containsKey(key)) {
      _attachMessageVisibility[key] = false.obs;
    }
    return _attachMessageVisibility[key]!;
  }

  // Method to toggle visibility
  void toggleAttachMessageVisibility(int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    getAttachMessageVisibility(customizationId, optionName).toggle();
  }
  // Inside PackageDetailsController

  void updateSelectedOption(
      int customizationId, String optionName, String selectedValue) {
    final customization = orderedCustomizations.firstWhere(
      (c) => c.orderedCustomizationId == customizationId,
      orElse: () =>
          OrderedCustomization(orderedCustomizationId: -1, selectedOptions: []),
    );

    if (customization == null) return;

    final option = customization.selectedOptions.firstWhere(
      (o) => o.name == optionName,
      orElse: () => OrderedOption(name: '', type: '', optionValues: []),
    );

    if (option == null) return;

    if (option.type == 'attachMessage') {
      // For text input, update the value directly
      final optionValue = option.optionValues.first;
      optionValue.value = selectedValue;
    } else if (option.type == 'uploadPicture') {
      // For image upload, update the fileName
      final optionValue = option.optionValues.first;
      optionValue.fileName = selectedValue; // selectedValue is image path
    } else {
      // For other types, handle selection
      // Deselect all options first
      for (var optionValue in option.optionValues) {
        optionValue.isSelected.value = false;
      }

      // Select the specified option value
      final selectedOptionValue = option.optionValues.firstWhere(
        (optionValue) => optionValue.value == selectedValue,
        orElse: () =>
            OrderedOptionValue(name: '', value: '', isSelected: false),
      );

      if (selectedOptionValue != null) {
        selectedOptionValue.isSelected.value = true;
      }
    }
  }

// Optional: Helper method to get the current value for text options
  String getOptionValue(int customizationId, String optionName) {
    final customization = orderedCustomizations.firstWhere(
      (c) => c.orderedCustomizationId == customizationId,
      orElse: () =>
          OrderedCustomization(orderedCustomizationId: -1, selectedOptions: []),
    );

    if (customization == null) return '';

    final option = customization.selectedOptions.firstWhere(
      (o) => o.name == optionName,
      orElse: () => OrderedOption(name: '', type: '', optionValues: []),
    );

    if (option == null) return '';

    final optionValue = option.optionValues.first;
    return optionValue.value;
  }

  bool isOptionSelected(int customizationId, String optionValue) {
    final customization = orderedCustomizations.firstWhere(
      (c) => c.orderedCustomizationId == customizationId,
      orElse: () =>
          OrderedCustomization(orderedCustomizationId: -1, selectedOptions: []),
    );

    if (customization == null)
      return false; // Return false if customization is not found

    // Check if any option value is selected
    return customization.selectedOptions.any((o) => o.optionValues
        .any((v) => v.value == optionValue && v.isSelected.value));
  }

  void navigateToCart() {
    Get.toNamed('/cart');
  }
}

class AddToCartBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Now you have access to MediaQuery and other context-based tools
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust font sizes and paddings based on screen size
    double fontSizeTitle = screenWidth * 0.05; // Adjust as needed
    double fontSizeButton = screenWidth * 0.045; // Adjust as needed

    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Product added to cart',
              style: TextStyle(
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/cart');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.1,
                ),
              ),
              child: Text(
                'Go to checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jost',
                  fontSize: fontSizeButton,
                ),
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
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.1,
                ),
              ),
              child: Text(
                'Continue shopping',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jost',
                  fontSize: fontSizeButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
