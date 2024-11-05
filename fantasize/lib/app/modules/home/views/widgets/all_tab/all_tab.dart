import 'package:fantasize/app/modules/home/views/widgets/all_tab/widgets/new_collection_subcategory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/home/views/widgets/all_tab/widgets/home_offers.dart';

class AllTab extends StatelessWidget {
  const AllTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0), // Optional: Adjust padding as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontally scrollable homeOffers section
          SizedBox(
            height: 400, // Set an appropriate height for homeOffers
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Number of homeOffers you want to display
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: homeOffers, // Your homeOffers widget
                );
              },
            ),
          ),

          // Spacer
          SizedBox(height: 20),

          // Non-scrollable newCollectionSubcategory section
          Column(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child:
                    newCollectionSubcategory, // Your newCollectionSubcategory widget
              );
            }),
          ),

          // Add more widgets as needed
        ],
      ),
    );
  }
}
