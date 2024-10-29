import 'package:fantasize/app/data/models/package_model.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:fantasize/app/modules/products/views/widgets/product_card.dart';
import 'package:fantasize/app/modules/products/views/widgets/package_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesView extends StatelessWidget {
  final FavoritesController controller = Get.put(FavoritesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites List',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 30,
            color: Colors.redAccent,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // Combine both product and package lists for unified display
        final favoriteItems = [
          ...controller.favoriteProducts,
          ...controller.favoritePackages,
        ];

        if (favoriteItems.isEmpty) {
          return Center(child: Text('No favorite items available'));
        }

        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.6, // Adjust for better fit
          ),
          itemCount: favoriteItems.length,
          itemBuilder: (context, index) {
            final item = favoriteItems[index];
            return InkWell(
              onTap: () => controller.navigateToDetails(item),
              child: item is Product
                  ? ProductCard(product: item)
                  : PackageCard(package: item as Package),
            );
          },
        );
      }),
    );
  }
}
