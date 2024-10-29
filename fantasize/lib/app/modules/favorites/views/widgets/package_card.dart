// lib/app/modules/products/views/widgets/package_card.dart

import 'package:fantasize/app/global/strings.dart';
import 'package:flutter/material.dart';
import 'package:fantasize/app/data/models/package_model.dart';

class PackageCard extends StatelessWidget {
  final Package package;

  const PackageCard({Key? key, required this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Image.network(
            '${Strings().resourceUrl}/${package.resources.first.entityName}',
            height: 150,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "\$${package.price}",
                  style: TextStyle(color: Colors.green, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  package.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
