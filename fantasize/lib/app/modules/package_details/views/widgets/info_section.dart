// lib/app/modules/package_details/views/widgets/package_info_section.dart

import 'package:flutter/material.dart';
import 'package:fantasize/app/data/models/package_model.dart';

class PackageInfoSection extends StatelessWidget {
  final Package package;

  PackageInfoSection({required this.package});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            package.name,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "\$${package.price}",
            style: TextStyle(fontSize: 20, color: Colors.green),
          ),
          SizedBox(height: 8),
          Text(package.description, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
