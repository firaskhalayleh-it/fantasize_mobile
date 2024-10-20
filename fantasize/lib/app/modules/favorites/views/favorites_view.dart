import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:fantasize/app/modules/products/views/widgets/product_card.dart';
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
            fontFamily: 'Poppines',
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

        return controller.favoritesList.length > 0
            ? GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6, // Adjust for better fit
                ),
                itemCount: controller.favoritesList.length,
                itemBuilder: (context, index) {
                  var product = controller.favoritesList[index];
                  return InkWell(
                    onTap: () => controller.NavigateToProductDetails(index),
                    child: ProductCard(
                      product: product,
                    ),
                  );
                },
              )
            : Text('No products available');
      }),
    );
  }
}
