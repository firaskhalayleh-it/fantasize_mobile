// lib/app/modules/product_details/views/widgets/product_info_section.dart

import 'package:flutter/material.dart';
import 'package:fantasize/app/data/models/product_model.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  ProductInfoSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            product.name,
            style: TextStyle(
              fontSize: 28,
              fontFamily: 'Jost',
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < product.avgRating ? Icons.star : Icons.star_border,
                    color: Color(0xFFFFD33C),
                  );
                }),
              ),
              Text(
                '${product.avgRating} (${product.reviews?.length ?? 0} reviews)',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Price: \$${product.price}',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Jost',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            product.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
