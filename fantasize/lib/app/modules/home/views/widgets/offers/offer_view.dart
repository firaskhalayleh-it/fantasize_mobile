import 'package:fantasize/app/modules/home/controllers/offers_controller.dart';
import 'package:fantasize/app/modules/products/views/widgets/package_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/products/views/widgets/product_card.dart';

class OfferView extends StatelessWidget {
  final OffersController controller = Get.put(OffersController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = Get.width;
    double screenHeight = Get.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Offers"),
      ),
      body: Obx(() {
        if (controller.isOfferLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
            return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount:
              controller.packageList.length + controller.productList.length,
            itemBuilder: (context, index) {
              if (index < controller.productList.length) {
              final product = controller.productList[index];
              return InkWell(
                onTap: () {
                Get.toNamed('/product-details',
                  arguments: product.productId);
                },
                child: ProductCard(product: product),
              );
              } else {
              final package = controller
                .packageList[index - controller.productList.length];
              return InkWell(
                onTap: () {
                Get.toNamed('/package-details',
                  arguments: package.packageId);
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
