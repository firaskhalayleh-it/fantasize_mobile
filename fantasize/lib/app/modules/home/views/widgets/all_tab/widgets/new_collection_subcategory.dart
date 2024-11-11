// new_collection_subcategory_widget.dart
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/data/models/product_model.dart';

class NewCollectionSubcategoryWidget extends StatelessWidget {
  final Product product;

  const NewCollectionSubcategoryWidget({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine which image to display
    String imageUrl = '';
    if (product.resources.isNotEmpty) {
      imageUrl = product.resources.first.filePath;
    } else {
      imageUrl = 'assets/images/placeholder.jpg'; // Fallback image
    }

    var resourceUrl = Strings().resourceUrl;

    // Construct the full URL for the image
    final fullImageUrl = '$resourceUrl/$imageUrl';

    return SizedBox(
      height: 300, // Set a fixed height for the overall widget
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 40,
            right: 40,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.redAccent[100],
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 30,
            right: 30,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.redAccent[200],
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          Positioned(
            top: 25,
            left: 20,
            right: 20,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Stack(
                children: [
                  // Background image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    child: Image.network(
                      ImageHandler.getImageUrl(product.resources),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Handle image loading errors
                        return Image.asset(
                          'assets/images/placeholder.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      },
                    ),
                  ),
                  // Center "New Collection" text
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'New Collection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Abel',
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Center product name
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 45), // Adjust the distance as needed
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontFamily: 'Abel',
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  // Bottom "Shop Now" button
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.description,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: 'Abel',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shadowColor: Colors.white,
                              elevation: 0,
                            ),
                            onPressed: () {
                              // Handle navigation to product details
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Shop Now',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontFamily: 'Abel',
                                  ),
                                ),
                                SizedBox(width: 7),
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.redAccent,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
