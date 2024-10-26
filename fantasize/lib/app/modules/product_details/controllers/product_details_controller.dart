import 'package:fantasize/app/data/models/customization_model.dart';
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
  var quantity = 1.obs; // To store the quantity of the product
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
    } else {
      Get.snackbar('Error', 'Error fetching product details');
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
      body: json.encode({
        'ProductID': productId,
        'Comment': comment,
        'Rating': rating,
      }),
    );

    if (response.statusCode == 201) {
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
      Product product, List<OrderedOption> orderedOptions, int quantity) async {
    try {
      String? token = await _secureStorage.read(key: 'jwt_token');
      var response = await http.post(
        Uri.parse('${Strings().apiUrl}/order'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
          'cookie': 'authToken=$token',
        },
        body: json.encode({
          "productId": product.productId,
          "quantity": quantity,
          "OrderedOptions":
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

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

 String calcTotalPrice() {
  double totalPrice = (double.parse(product.value!.price) * quantity.value);
  return totalPrice.toStringAsFixed(2); // Format to 2 decimal places
}

}
