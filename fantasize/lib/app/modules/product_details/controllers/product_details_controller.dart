import 'package:fantasize/app/data/models/customization_model.dart';
import 'package:fantasize/app/data/models/ordered_customization.dart';
import 'package:fantasize/app/data/models/ordered_option.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/cart/controllers/cart_controller.dart';
import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import jwt_decoder package

class ProductDetailsController extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  CartController cartController = Get.find<CartController>();
  RxDouble totalPrice = 0.0.obs;
  var product = Rxn<Product>(); // The product object including reviews
  var isLiked = RxBool(false); // To handle the like/unlike status
  var isEditing = false.obs; // Editing status for reviews
  var reviewBeingEdited = Rxn<Review>(); // The review that is being edited
  var currentUsername = ''.obs; // To store the username of the current user
  var isReviewFormVisible = false.obs; // To toggle the review form visibility
  var isSelectedColor = ''.obs; // To store the selected color
  var quantity = 1.obs;
  // To store the quantity of the product
  List<OrderedCustomization> orderedCustomizations = [];

  // List of ordered customizations
  final Map<String, TextEditingController> _textControllers =
      {}; // Define the _textControllers map
  final Map<String, RxString> _uploadedImages =
      {}; // Define the _uploadedImages map
  final Map<String, RxBool> _attachMessageVisibility =
      {}; // Define the _attachMessageVisibility map
  var productInitialPrice = 0.0; // Initial price of the product
  @override
  void onInit() {
    super.onInit();
    var arguments = Get.arguments;
    int productId = arguments[0] as int;
    fetchCurrentUser(); // Fetch the current user from the token
    fetchProductDetails(productId);
    checkIfLiked(productId); // Check if the product is liked
  }

  Future<void> fetchCurrentUser() async {
    String? token = await _secureStorage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String username = decodedToken['payload']['userName'];
      currentUsername.value = username;
    }
  }

  Future<void> fetchProductDetails(int productId) async {
    String? token = await _secureStorage.read(key: 'jwt_token');
    var url = Uri.parse('${Strings().apiUrl}/getProduct/$productId');
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

      var fetchedProduct = Product.fromJson(jsonData);

      // Sort to make sure the video is displayed first
      fetchedProduct.resources
          .sort((a, b) => a.fileType == 'video/mp4' ? -1 : 1);

      product.value = fetchedProduct; // Assign fetched product
      productInitialPrice = double.tryParse(fetchedProduct.price) ?? 0.0;
      // **Add this line**
      initializeOrderedCustomizations(); // Initialize ordered customizations
    } else {
      Get.snackbar('Error', 'Error fetching product details');
    }
  }

  void initializeOrderedCustomizations() {
    orderedCustomizations.clear();
    if (product.value != null && product.value!.customizations.isNotEmpty) {
      for (var customization in product.value!.customizations) {
        var orderedCustomization = OrderedCustomization(
          orderedCustomizationId: customization.customizationId,
          selectedOptions: customization.options.map((option) {
            return OrderedOption(
              name: option.name,
              type: option.type,
              optionValues: option.optionValues.map((optionValue) {
                return OrderedOptionValue(
                  name: optionValue.name,
                  value: optionValue.value,
                  isSelected: false, // Initially not selected
                  fileName: '',
                );
              }).toList(),
            );
          }).toList(),
        );
        orderedCustomizations.add(orderedCustomization);
      }
    }
  }

  // Method to check if the review belongs to the current user
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
      int productId, String comment, int rating) async {
    String? token = await _secureStorage.read(key: 'jwt_token');
    var url;
    var method;
    var reviewId = reviewBeingEdited.value?.reviewId;

    // If we are editing an existing review
    if (isEditing.value && reviewId != null) {
      url = Uri.parse('${Strings().apiUrl}/reviews/$reviewId');
      method = http.put;
    } else {
      // New review
      url = Uri.parse('${Strings().apiUrl}/reviews/product');
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
              'Comment': comment,
              'Rating': rating,
            })
          : json.encode({
              'ProductID': productId,
              'Rating': rating,
              'Comment': comment,
            }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Hide the form after successful submission
      isEditing(false);
      isReviewFormVisible(false);

      // Refresh the product details to reflect the added/updated review
      await fetchProductDetails(productId);

      Get.snackbar(
          'Success', isEditing.value ? 'Review updated!' : 'Review added!',
          overlayBlur: 2);
    } else {
      Get.snackbar('Error', 'Failed to add/update review');
    }
  }

  Future<void> checkIfLiked(int productId) async {
    try {
      String? token = await _secureStorage.read(key: 'jwt_token');
      var url = Uri.parse('${Strings().apiUrl}/favorites');
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
        var favoriteProducts = jsonData as List<dynamic>;

        isLiked.value = favoriteProducts.any((favorite) {
          var favoriteProduct = favorite['Product'];
          return favoriteProduct != null &&
              favoriteProduct['ProductID'] == productId;
        });
      } else {
        Get.snackbar('Error', 'Failed to fetch favorite products');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch favorite products: $e');
    }
  }

  toggleLike() async {
    final isCurrentlyLiked = isLiked.value ?? false;
    try {
      String? token = await _secureStorage.read(key: 'jwt_token');
      var url;
      if (!isCurrentlyLiked) {
        // Add product to favorites
        url = Uri.parse(
            '${Strings().apiUrl}/product/${product.value!.productId}/favorites');
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
            'Accept': 'application/json',
            'cookie': 'authToken=$token',
          },
        );
        isLiked.value = true;
        Get.snackbar('Success', 'Product added to favorites', overlayBlur: 3.0);
      } else {
        // Remove product from favorites
        url = Uri.parse(
            '${Strings().apiUrl}/favorites/${product.value!.productId}');
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
        Get.snackbar('Success', 'Product removed from favorites');
      }

      // Reload the favorites after the product is added/removed from the list
      final FavoritesController favoritesController =
          Get.find<FavoritesController>();
      favoritesController.reloadFavorites();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorites: $e');
    }
  }

  Future<void> deleteReview(int reviewId, int productId) async {
    String? token = await _secureStorage.read(key: 'jwt_token');
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
      fetchProductDetails(productId); // Refresh product details after deletion
    } else {
      Get.snackbar('Error', 'Failed to delete review');
    }
  }

  void toggleReviewFormVisibility() {
    isReviewFormVisible.value = !isReviewFormVisible.value;
  }

 void showAddToCartDialog() {
  final double buttonPadding = Get.width * 0.15; // Reduced padding

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      width: Get.width,
      height: Get.height * 0.28,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Check Mark with fixed animation
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: AnimationController(
                        vsync: navigator!,
                        duration: const Duration(milliseconds: 400),
                      )..forward(),
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    'Product added to cart',
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
                              onPressed: () => Get.toNamed('/cart'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
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
                                Get.until((route) => route.settings.name == '/products');
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
                                padding: EdgeInsets.symmetric(
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
          );
        },
      ),
    ),
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
  );
}

  Future<void> addToCart() async {
    try {
      String? token = await _secureStorage.read(key: 'jwt_token');

      if (token == null) {
        Get.snackbar('Error', 'User is not authenticated');
        return;
      }

      if (product.value?.productId == null || quantity.value == null) {
        Get.snackbar('Error', 'Product ID or quantity is missing');
        return;
      }

      // Serialize orderedOptions correctly
      var orderedOptions = orderedCustomizations.map((customization) {
        // Assuming customization.selectedOptions is a list with one element
        var selectedOption = customization.selectedOptions[0];
        return {
          'name': selectedOption.name,
          'type': selectedOption.type,
          'optionValues':
              selectedOption.optionValues.map((v) => v.toJson()).toList(),
        };
      }).toList();

      var requestBody = {
        "productId": product.value!.productId,
        "quantity": quantity.value,
        "orderedOptions": orderedOptions,
      };

      // Print request body for debugging
      print('Request Body: ${json.encode(requestBody)}');

      // Send the request
      var response = await http.post(
        Uri.parse('${Strings().apiUrl}/order'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
          'cookie': 'authToken=$token',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response Body: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 201) {
        Get.snackbar('Success', 'Product added to cart');
        showAddToCartDialog();
        cartController.fetchCart();
      } else {
        var errorResponse = json.decode(response.body);
        Get.snackbar('Error',
            'Failed to add product to cart: ${errorResponse['message']}');
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

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void updateSelectedOption(
      int customizationId, String optionName, String selectedValue) {
    var orderedCustomization = orderedCustomizations.firstWhere(
      (c) => c.orderedCustomizationId == customizationId,
      orElse: () =>
          OrderedCustomization(orderedCustomizationId: 0, selectedOptions: []),
    );

    if (orderedCustomization != null) {
      var selectedOption = orderedCustomization.selectedOptions.firstWhere(
        (o) => o.name == optionName,
        orElse: () => OrderedOption(name: '', type: '', optionValues: []),
      );

      if (selectedOption != null) {
        if (selectedOption.type == 'button' ||
            selectedOption.type == 'color' ||
            selectedOption.type == 'image') {
          // For single selection options
          for (var optionValue in selectedOption.optionValues) {
            optionValue.isSelected.value = optionValue.value == selectedValue;
          }
        } else if (selectedOption.type == 'attachMessage') {
          // For text input
          var optionValue = selectedOption.optionValues.first;
          optionValue.value = selectedValue;
        } else if (selectedOption.type == 'uploadPicture') {
          // For image upload
          var optionValue = selectedOption.optionValues.first;
          optionValue.fileName = selectedValue;
        }
      }
    }
  }

  bool isOptionSelected(int customizationId, String selectedValue) {
    var orderedCustomization = orderedCustomizations.firstWhere(
      (c) => c.orderedCustomizationId == customizationId,
      orElse: () =>
          OrderedCustomization(orderedCustomizationId: 0, selectedOptions: []),
    );

    if (orderedCustomization != null) {
      for (var selectedOption in orderedCustomization.selectedOptions) {
        for (var optionValue in selectedOption.optionValues) {
          if (optionValue.value == selectedValue &&
              optionValue.isSelected.value) {
            return true;
          }
        }
      }
    }

    return false;
  }

  TextEditingController getTextController(
      int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController();
      _textControllers[key]!.addListener(() {
        updateSelectedOption(
            customizationId, optionName, _textControllers[key]!.text);
      });
    }
    return _textControllers[key]!;
  }

  RxBool getAttachMessageVisibility(int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    if (!_attachMessageVisibility.containsKey(key)) {
      _attachMessageVisibility[key] = false.obs;
    }
    return _attachMessageVisibility[key]!;
  }

  void toggleAttachMessageVisibility(int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    getAttachMessageVisibility(customizationId, optionName).toggle();
  }

  RxString getUploadedImagePath(int customizationId, String optionName) {
    final key = '$customizationId-$optionName';
    if (!_uploadedImages.containsKey(key)) {
      _uploadedImages[key] = ''.obs;
    }
    return _uploadedImages[key]!;
  }

  void updateUploadedImage(
      int customizationId, String optionName, String imagePath) {
    final key = '$customizationId-$optionName';
    getUploadedImagePath(customizationId, optionName).value = imagePath;
    updateSelectedOption(customizationId, optionName, imagePath);
  }

  String calcTotalPrice() {
    // Parse the base price from the product and calculate total price based on quantity
    double basePrice = double.tryParse(product.value!.price) ?? 0.0;
    basePrice *= quantity.value;

    double discount = 0.0;

    // Check if the product has a valid active offer
    if (product.value!.offer != null &&
        product.value!.offer!.isActive &&
        product.value!.offer!.discount.isNotEmpty) {
      var offer = product.value!.offer!;
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
    // Parse the base price from the product
    double basePrice = (productInitialPrice);

    double discount = 0.0;

    // Check if the product has a valid active offer
    if (product.value!.offer != null &&
        product.value!.offer!.isActive &&
        product.value!.offer!.discount.isNotEmpty) {
      var offer = product.value!.offer!;
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

  @override
  void onClose() {
    // Dispose of text controllers
    _textControllers.values.forEach((controller) => controller.dispose());
    super.onClose();
  }
}
