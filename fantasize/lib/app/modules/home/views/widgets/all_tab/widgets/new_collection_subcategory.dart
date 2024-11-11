import 'package:fantasize/app/data/models/resources_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewCollectionSubcategoryWidget extends StatelessWidget {
  final dynamic item; // Accepts either Product or Package

  const NewCollectionSubcategoryWidget({Key? key, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
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
                  // Display the image with error handling
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    child: Image.network(
                      ImageHandler.getImageUrl(item.resources),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Display a local placeholder if the image fails to load
                        return Image.asset(
                          'assets/images/placeholder.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      },
                    ),
                  ),
                  // "New Collection" label
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
                  // Display item name
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 45),
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: 'Abel',
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  // "Shop Now" button
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
                              item.description,
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
                              // Handle navigation to item details
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
