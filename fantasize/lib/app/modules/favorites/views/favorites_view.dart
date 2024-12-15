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
          'Favorites',
          style: TextStyle(
            color: Colors.redAccent,
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      
        
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.redAccent.withOpacity(0.05),
              Colors.white.withOpacity(0.95),
            ],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),
            );
          }

          final favoriteItems = [
            ...controller.favoriteProducts,
            ...controller.favoritePackages,
          ];

          if (favoriteItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: Colors.redAccent.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No favorites yet",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Items you favorite will appear here",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
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
      ),
    );
  }
}
