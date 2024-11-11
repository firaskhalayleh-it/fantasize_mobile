import 'package:fantasize/app/modules/home/controllers/home_controller.dart';
import 'package:fantasize/app/modules/home/views/widgets/all_tab/widgets/new_collection_subcategory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/home/views/widgets/all_tab/widgets/home_offers.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0), // Optional: Adjust padding as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontally scrollable homeOffers section
          SizedBox(
            height: 400, // Set an appropriate height for homeOffers
            child: Obx(() {
              if (controller.offers.isEmpty) {
                // Show a loader or placeholder while data is loading
                return Center(child: CircularProgressIndicator());
              } else {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.offers.length,
                  itemBuilder: (context, index) {
                    final offer = controller.offers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: HomeOffersWidget(
                          offer: offer), // Pass the offer to the widget
                    );
                  },
                );
              }
            }),
          ),

          // Spacer
          SizedBox(height: 20),

          Obx(() {
            if (controller.newCollectionProducts.isEmpty) {
              // Show a loader or placeholder while data is loading
              return Center(child: CircularProgressIndicator());
            } else {
              return Column(
                children: controller.newCollectionProducts.map((product) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: NewCollectionSubcategoryWidget(product: product),
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
