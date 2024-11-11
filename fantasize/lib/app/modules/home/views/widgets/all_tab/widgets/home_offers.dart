import 'package:fantasize/app/data/models/offer_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeOffersWidget extends GetView<HomeController> {
  final Offer offer;
  const HomeOffersWidget({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = '';
    if (offer.products.isNotEmpty &&
        offer.products.first.resources.isNotEmpty) {
      imageUrl =
          '${Strings().resourceUrl}/${offer.products.first.resources.first.entityName}';
    } else if (offer.packages.isNotEmpty &&
        offer.packages.first.resources.isNotEmpty) {
      imageUrl =
          '${Strings().resourceUrl}/${offer.packages.first.resources.first.entityName}';
    } else {
      imageUrl = '${Strings().resourceUrl}/placeholder.jpg'; // Fallback image
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              scale: 4 / 2,
              height: Get.height * 0.4,
              width: Get.width * 0.7,
            ),
          ),
        ),
        Positioned(
          top: Get.height * 0.4 - 200,
          left: Get.width * 0.4 - 120,
          child: Container(
            padding: EdgeInsets.all(5),
            child: Text(
              '${offer.discount}% OFF',
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
              'Have a grate discount on Gifts For Her',
              style: TextStyle(
                fontFamily: 'Abel',
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Positioned(
          top: Get.height * 0.4 - 185,
          left: Get.width * 0.4 - 140,
          child: Container(
            padding: EdgeInsets.all(5),
            child: Text(
              'UP\nTO',
              style: TextStyle(
                fontFamily: 'Abel',
                color: Colors.black,
                fontSize: 12,
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
                // Handle button press, perhaps navigate to offer details
              },
              child: Text('See Offers',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Abel', fontSize: 18)),
            ),
          ),
        ),
      ],
    );
    ;
  }
}
