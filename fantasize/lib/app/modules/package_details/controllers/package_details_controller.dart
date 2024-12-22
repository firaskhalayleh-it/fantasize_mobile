import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/ordered_customization.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/cart/controllers/cart_controller.dart';
import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
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
    int packageId;
    if (arguments is int) {
      packageId = arguments;
    } else if (arguments is List && arguments.isNotEmpty && arguments[0] is int) {
      packageId = arguments[0];
    } else {
      Get.snackbar('Error', 'Invalid package ID provided.');
      return;
    }
    fetchPackageDetails(packageId);
    checkIfLiked(packageId);
    fetchCurrentUser();
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
    final isCurrentlyLiked = isLiked.value;
    try {
      String? token = await storage.read(key: 'jwt_token');
      var url;
      if (!isCurrentlyLiked) {
        // Add package to favorites
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
        Get.snackbar('Success', 'Package added to favorites',
            overlayBlur: 3.0);
      } else {
        // Remove package from favorites
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

      // Reload the favorites after the package is added/removed from the list
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
      } if (response.statusCode == 401) {
        Get.snackbar(
            'Unauthorized', 'Your session has expired. Please log in again.');
      } 
      if (response.statusCode == 404) {
      }


    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch favorite packages: $e');
    }
  }

  Future<void> fetchCurrentUser() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      // Adjust according to your JWT structure
      String username = decodedToken['userName'] ?? decodedToken['payload']['userName'] ?? '';
      currentUsername.value = username;
    }
  }

  bool isReviewFromCurrentUser(Review review) {
    return review.user?.username == currentUsername.value;
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
      int packageId, String comment, int rating) async {
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
              'PackageId': packageId,
              'Rating': rating,
              'Comment': comment,
            }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Hide the form after successful submission
      isEditing(false);
      isReviewFormVisible(false);

      // Refresh the package details to reflect the added/updated review
      await fetchPackageDetails(packageId);

      Get.snackbar(
          'Success',
          isEditing.value ? 'Review updated!' : 'Review added!',
          overlayBlur: 2);
    } else {
      Get.snackbar('Error', 'Failed to add/update review');
    }
  }

  Future<void> deleteReview(int reviewId, int packageId) async {
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
      fetchPackageDetails(packageId); // Refresh package details after deletion
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

  void updateSelectedOption(
      int customizationId, String optionName, String selectedValue) {
    final customization = orderedCustomizations.firstWhere(
      (c) => c.orderedCustomizationId == customizationId,
      orElse: () =>
          OrderedCustomization(orderedCustomizationId: -1, selectedOptions: []),
    );

    if (customization.orderedCustomizationId == -1) return;

    final option = customization.selectedOptions.firstWhere(
      (o) => o.name == optionName,
      orElse: () => OrderedOption(name: '', type: '', optionValues: []),
    );

    if (option.name.isEmpty) return;

    if (option.type == 'attachMessage') {
      // For text input, update the value directly
      final optionValue = option.optionValues.first;
      optionValue.value = selectedValue;
    } else if (option.type == 'uploadPicture') {
      // For image upload, update the filePath
      final optionValue = option.optionValues.first;
      optionValue.filePath = selectedValue; // selectedValue is image path
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

      if (selectedOptionValue.value.isNotEmpty) {
        selectedOptionValue.isSelected.value = true;
      }
    }
  }

  String getOptionValue(int customizationId, String optionName) {
    final customization = orderedCustomizations.firstWhere(
      (c) => c.orderedCustomizationId == customizationId,
      orElse: () =>
          OrderedCustomization(orderedCustomizationId: -1, selectedOptions: []),
    );

    if (customization.orderedCustomizationId == -1) return '';

    final option = customization.selectedOptions.firstWhere(
      (o) => o.name == optionName,
      orElse: () => OrderedOption(name: '', type: '', optionValues: []),
    );

    if (option.name.isEmpty) return '';

    final optionValue = option.optionValues.first;
    return optionValue.value;
  }

  bool isOptionSelected(int customizationId, String optionValue) {
    final customization = orderedCustomizations.firstWhere(
      (c) => c.orderedCustomizationId == customizationId,
      orElse: () =>
          OrderedCustomization(orderedCustomizationId: -1, selectedOptions: []),
    );

    if (customization.orderedCustomizationId == -1)
      return false; // Return false if customization is not found

    // Check if the option value is selected
    return customization.selectedOptions.any((o) => o.optionValues
        .any((v) => v.value == optionValue && v.isSelected.value));
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

  void initializeOrderedCustomizations() {
    if (package.value == null || package.value!.customizations.isEmpty) return;

    // Use a Set to keep track of customization IDs we've already added
    final Set<int> seenCustomizationIds = {};

    orderedCustomizations = package.value!.customizations.where((customization) {
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

  // Function to handle adding a package to the cart
  Future<void> addToCart() async {
    try {
      String? token = await storage.read(key: 'jwt_token');

      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        return;
      }

      if (package.value?.packageId == null || quantity.value == null) {
        Get.snackbar('Error', 'Package ID or quantity is missing');
        return;
      }

      // Serialize orderedOptions correctly
      var orderedOptions = orderedCustomizations.map((customization) {
        return {
          'orderedCustomizationId': customization.orderedCustomizationId,
          'selectedOptions': customization.selectedOptions.map((option) {
            return {
              'name': option.name,
              'type': option.type,
              'optionValues': option.optionValues.map((v) => v.toJson()).toList(),
            };
          }).toList(),
        };
      }).toList();

      var requestBody = {
        "packageId": package.value!.packageId,
        "quantity": quantity.value,
        "orderedOptions": orderedOptions,
      };

      // Print request body for debugging
      print('Request Body: ${json.encode(requestBody)}');

      // Send the request
      var response = await http.post(
        Uri.parse('${Strings().apiUrl}/orderpackage'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
          'cookie': 'authToken=$token',
        },
        body: json.encode(requestBody),
      );

      print('Response Body: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Package added to cart');
        showAddToCartDialog();
        cartController.fetchCart();
      } else {
        var errorResponse = json.decode(response.body);
        Get.snackbar('Error',
            'Failed to add package to cart: ${errorResponse['message'] ?? 'Unknown error'}');
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
                isSelected: optionValue.isSelected.value,
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  void navigateToCart() {
    Get.toNamed('/cart');
  }

  // Updated showAddToCartDialog method with enhanced UI and animations
  void showAddToCartDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Check Mark with fixed animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                'Package added to cart',
                style: TextStyle(
                  fontSize: Get.width < 300 ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Jost',
                ),
              ),

              const SizedBox(height: 12),

              // Checkout Button with fixed padding
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => navigateToCart(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Go to checkout',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Jost',
                              fontSize: Get.width < 400 ? 16 : 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Continue Shopping Button with fixed padding
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(-30 * (1 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Colors.redAccent,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Continue shopping',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontFamily: 'Jost',
                              fontSize: Get.width < 400 ? 16 : 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    // Dispose of text controllers
    _textControllers.values.forEach((controller) => controller.dispose());
    super.onClose();
  }

  toggleReviewFormVisibility() {
    isReviewFormVisible.value = !isReviewFormVisible.value;
  }
}
