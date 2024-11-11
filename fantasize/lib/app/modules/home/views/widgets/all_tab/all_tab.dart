// lib/app/modules/home/views/widgets/all_tab/all_tab.dart

import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:fantasize/app/modules/home/views/widgets/all_tab/widgets/home_offers.dart';
import 'package:fantasize/app/modules/home/views/widgets/all_tab/widgets/new_collection_subcategory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontally scrollable offers section for products and packages
          SizedBox(
            height: 400, // Set an appropriate height for offers
            child: Obx(() {
              if (controller.offersItems.isEmpty) {
                // Show a loader while data is loading
                return Center(child: CircularProgressIndicator());
              } else {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.offersItems.length,
                  itemBuilder: (context, index) {
                    final offerItem = controller.offersItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: HomeOffersWidget(
                        item: offerItem, // Pass either Product or Package
                      ),
                    );
                  },
                );
              }
            }),
          ),

          // Spacer
          SizedBox(height: 20),

          // Display new collection products
          Obx(() {
            if (controller.newCollectionItems.isEmpty) {
              // Show a loader while data is loading
              return Center(child: CircularProgressIndicator());
            } else {
              return Column(
                children: controller.newCollectionItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: NewCollectionSubcategoryWidget(item: item),
                  );
                }).toList(),
              );
            }
          }),
          // Add more widgets as needed
        ],
      ),
    );
  }
}
