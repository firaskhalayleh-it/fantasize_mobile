import 'package:fantasize/app/modules/home/controllers/new_arrival_controller.dart';
import 'package:fantasize/app/modules/home/views/widgets/recommended_for_you/widgets/recommended_for_you_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewArrivalView extends StatelessWidget {
  NewArrivalView({super.key});
  final NewArrivalController controller = Get.put(NewArrivalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.newArrivalsPackages.isEmpty &&
            controller.newArrivalsProducts.isEmpty) {
          return const Center(
              child: Text("No new arrivals available at the moment."));
        } else {
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: controller.newArrivalsProducts.length +
                controller.newArrivalsPackages.length,
            itemBuilder: (context, index) {
              if (index < controller.newArrivalsProducts.length) {
                final product = controller.newArrivalsProducts[index];
                return InkWell(
                  onTap: () {
                    Get.toNamed('/product-details',
                        arguments: [product.productId]);
                  },
                  child: RecommendedForYouCard(item: product),
                );
              } else {
                final packageIndex =
                    index - controller.newArrivalsProducts.length;
                final package = controller.newArrivalsPackages[packageIndex];
                return InkWell(
                  onTap: () {
                    Get.toNamed('/package-details',
                        arguments: package.packageId);
                  },
                  child: RecommendedForYouCard(item: package),
                );
              }
            },
          );
        }
      }),
    );
  }
}
