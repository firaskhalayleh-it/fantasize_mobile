import 'package:fantasize/app/modules/home/controllers/offers_controller.dart';
import 'package:fantasize/app/modules/products/views/widgets/package_card.dart';
import 'package:fantasize/app/modules/products/views/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfferView extends StatelessWidget {
  OfferView({Key? key}) : super(key: key);

  final OffersController controller = Get.put(OffersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offers"),
      ),
      body: Obx(() {
        if (controller.isOfferLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.productList.isEmpty && controller.packageList.isEmpty) {
          return const Center(child: Text("No offers available at the moment."));
        } else {
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: controller.packageList.length + controller.productList.length,
            itemBuilder: (context, index) {
              if (index < controller.productList.length) {
                final product = controller.productList[index];
                return InkWell(
                  onTap: () {
                    Get.toNamed('/product-details', arguments: [product.productId]);
                  },
                  child: ProductCard(product: product),
                );
              } else {
                final package = controller.packageList[index - controller.productList.length];
                return InkWell(
                  onTap: () {
                    Get.toNamed('/package-details', arguments: package.packageId);
                  },
                  child: PackageCard(package: package),
                );
              }
            },
          );
        }
      }),
    );
  }
}
