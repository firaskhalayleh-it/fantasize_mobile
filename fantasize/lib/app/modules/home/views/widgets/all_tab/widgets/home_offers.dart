import 'package:fantasize/app/data/models/offer_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeOffersWidget extends GetView<HomeController> {
  final dynamic item; // Can be either Product or Package
  const HomeOffersWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if item is a Product or Package
    bool isProduct = item is Product;

    // Retrieve the correct resource URL, selecting the first image if available
    String imageUrl = item.resources.isNotEmpty
        ? '${Strings().resourceUrl}/${item.resources.first.entityName}'
        : '${Strings().resourceUrl}/placeholder.jpg';

    // Retrieve the discount and name based on item type
    String name = item.name;
    int discount = int.tryParse(item.offer?.discount?.toString() ?? '0') ?? 0;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: Get.height * 0.4,
              width: Get.width * 0.7,
              errorBuilder: (context, error, stackTrace) {
                // Display a placeholder image if the network image fails to load
                return Image.asset(
                  'assets/images/placeholder.jpg', // Local placeholder image
                  fit: BoxFit.cover,
                  height: Get.height * 0.4,
                  width: Get.width * 0.7,
                );
              },
            ),
          ),
        ),
        Positioned(
          top: Get.height * 0.4 - 200,
          left: Get.width * 0.4 - 120,
          child: Container(
            padding: EdgeInsets.all(5),
            child: Text(
              '$discount% OFF',
              style: TextStyle(
                fontFamily: 'Abel',
                color: Colors.black,
                fontSize: 48,
              ),
            ),
          ),
        ),
        Positioned(
          top: Get.height * 0.4 - 150,
          left: Get.width * 0.4 - 140,
          child: Container(
            padding: EdgeInsets.all(5),
            child: Text(
              name,
              style: TextStyle(
                fontFamily: 'Abel',
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
        Positioned(
          top: Get.height * 0.4 - 60,
          left: Get.width * 0.4 - 140,
          child: Container(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Handle button press, navigate to item details
              },
              child: Text('See Offer',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Abel', fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}
