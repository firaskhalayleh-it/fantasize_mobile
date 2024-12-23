// lib/app/modules/package_details/views/widgets/package_media.dart

import 'package:fantasize/app/modules/package_details/views/widgets/video_player_widget_package.dart';
import 'package:flutter/material.dart';
import 'package:fantasize/app/data/models/resources_model.dart';
import 'package:fantasize/app/modules/product_details/views/widgets/video_player.dart';
import 'package:fantasize/app/global/strings.dart';

class PackageMedia extends StatelessWidget {
  final List<ResourcesModel> resources;

  PackageMedia({required this.resources});

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: resource.fileType == 'video/mp4'
                ? VideoPlayerWidgetPackage(
                    videoUrl: '${Strings().resourceUrl}/${resource.entityName}',
                  )
                : Image.network(
                    '${Strings().resourceUrl}/${resource.entityName}',
                    fit: BoxFit.cover,
                    width: 300,
                  ),
          );
        },
      ),
    );
  }
}
