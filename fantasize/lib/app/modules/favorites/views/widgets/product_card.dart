import 'package:fantasize/app/modules/favorites/controllers/favorites_controller.dart';
import 'package:fantasize/app/modules/products/controllers/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:fantasize/app/data/models/product_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:get/get.dart';

class FavoriteProductCard extends StatelessWidget {
  final Product product;

  FavoriteProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            '${Strings().resourceUrl}/${product.resources.first.entityName}',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(product.name, style: TextStyle(fontSize: 16)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('\$${product.price}', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
