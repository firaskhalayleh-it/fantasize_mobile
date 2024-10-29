// lib/app/modules/products/views/widgets/package_card.dart

import 'package:fantasize/app/global/widgets/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/data/models/package_model.dart';
import 'package:get/get.dart';

class PackageCard extends StatelessWidget {
  final Package package;

  const PackageCard({Key? key, required this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'package_${package.packageId}',
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package Image with 'Sold Out' badge if applicable
                Stack(
                  children: [
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          ImageHandler.getImageUrl(package.resources),
                          height: Get.height * 0.2,
                          width: Get.width * 0.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (package.status == 'out of stock')
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF4C5E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Sold Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Jost',
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        package.description.split(' ').take(5).join(' ') +
                            (package.description.split(' ').length > 10
                                ? '...'
                                : ''),
                        style: TextStyle(
                          color: Color(0xFF3A4053),
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${package.price.toString()}',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
