import 'package:fantasize/app/data/models/resources_model.dart';
import 'package:fantasize/app/modules/product_details/views/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:fantasize/app/global/strings.dart';

class ProductMedia extends StatelessWidget {
  final List<ResourcesModel> resources;

  ProductMedia({required this.resources});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // Increased height for better visibility
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Media (${resources.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Media List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final resource = resources[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                    top: 4,
                    bottom: 4,
                  ),
                  child: resource.fileType == 'video/mp4'
                      ? VideoPlayerWidgetProduct(
                          videoUrl:
                              '${Strings().resourceUrl}/${resource.entityName}',
                        )
                      : Container(
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              children: [
                                // Image
                                Image.network(
                                  '${Strings().resourceUrl}/${resource.entityName}',
                                  fit: BoxFit.cover,
                                  width: 300,
                                  height: double.infinity,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.black.withOpacity(0.05),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.black.withOpacity(0.05),
                                      child: Center(
                                        child: Icon(
                                          Icons.error_outline,
                                          color: Colors.redAccent,
                                          size: 32,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Media Type Indicator
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Image',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
