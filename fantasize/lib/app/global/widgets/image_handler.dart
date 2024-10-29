// lib/app/utils/image_handler.dart

import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/data/models/resources_model.dart';
import 'package:collection/collection.dart';

class ImageHandler {
  static String getImageUrl(List<ResourcesModel> resources) {
    final imageResource = resources.firstWhereOrNull(
      (resource) => resource.fileType.startsWith('image/'),
    );

    return imageResource != null
        ? '${Strings().resourceUrl}/${imageResource.entityName}'
        : 'assets/images/placeholder.png';
  }
}
