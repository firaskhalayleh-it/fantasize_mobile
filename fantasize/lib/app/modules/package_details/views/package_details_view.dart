// lib/app/modules/package_details/views/package_details_view.dart

import 'package:fantasize/app/data/models/material_package.dart';
import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/login/views/widgets/devider.dart';
import 'package:fantasize/app/modules/package_details/views/widgets/customization_widget.dart';
import 'package:fantasize/app/modules/package_details/views/widgets/review_form.dart';

import 'package:fantasize/app/modules/package_details/views/widgets/video_player_widget_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/package_details/controllers/package_details_controller.dart';
import 'widgets/floating_price_button.dart'; // Ensure this is a generic widget or create FloatingPriceButtonPackage if needed

class PackageDetailsView extends StatelessWidget {
  final PackageDetailsController controller =
      Get.put(PackageDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Image(image: Svg('assets/icons/back_button.svg')),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Obx(() => IconButton(
                    icon: Image(
                      image: Svg(
                        controller.isLiked.value
                            ? 'assets/icons/like.svg'
                            : 'assets/icons/like-outlined.svg',
                      ),
                    ),
                    onPressed: () => controller.toggleLike(),
                  )),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (controller.package.value != null) {
          return FloatingPriceButtonPackage(
            price: controller.package.value!.price.toString(),
            onAddToCart: () => controller.addToCart(),
          );
        }
        return SizedBox.shrink();
      }),
      body: Obx(() {
        if (controller.package.value == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          );
        }

        final package = controller.package.value!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Gallery
              _buildMediaGallery(package),

              // Package Information
              Container(
                transform: Matrix4.translationValues(0, -20, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Package Header
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < package.avgRating.round()
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: Color(0xFFFFD700),
                                    size: 20,
                                  );
                                }),
                              ),
                              Text(
                                '\$${controller.getThePrice()}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Description
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        package.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Quantity Selector
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          _buildQuantityControl(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: _buildMaterialChip(package.materialPackages ?? []),
                    ),
                    // Customization Section
                    if (package.customizations.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customize',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            ...package.customizations
                                .expand((customization) => customization.options
                                    .map((option) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              option.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            PackageCustomizationWidget(
                                              customizations: [customization],
                                            ),
                                            SizedBox(height: 16),
                                          ],
                                        )))
                                .toList(),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:20),
                      child: Divider(),
                    ),
                    // Reviews Section
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reviews',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    controller.isReviewFormVisible.value
                                        ? Icons.remove
                                        : Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                onPressed: () =>
                                    controller.toggleReviewFormVisibility(),
                              ),
                            ],
                          ),
                          _buildReviewsList(package, context),
                          Obx(() {
                            if (controller.isReviewFormVisible.value) {
                              return Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: controller.isEditing.value
                                    ? ReviewFormPackage(
                                        packageId: package.packageId,
                                        isEditing: true,
                                        review:
                                            controller.reviewBeingEdited.value!,
                                      )
                                    : ReviewFormPackage(
                                        packageId: package.packageId,
                                        isEditing: false,
                                      ),
                              );
                            }
                            return SizedBox.shrink();
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMediaGallery(package) {
    return Container(
      height: 400,
      child: Stack(
        children: [
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: package.resources.length,
            itemBuilder: (context, index) {
              final resource = package.resources[index];
              return Container(
                width: Get.width,
                child: resource.fileType == 'video/mp4'
                    ? VideoPlayerWidgetPackage(
                        videoUrl:
                            '${Strings().resourceUrl}/${resource.entityName}')
                    : Image.network(
                        '${Strings().resourceUrl}/${resource.entityName}',
                        fit: BoxFit.cover,
                      ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                package.resources.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: () => controller.decrementQuantity(),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Obx(() => Text(
                  controller.quantity.value.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => controller.incrementQuantity(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildReviewsList(package, BuildContext context) {
    if (package.reviews == null || package.reviews.isEmpty) {
      return Center(
        child: Text('No reviews yet'),
      );
    }

    return Column(
      children: package.reviews.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final review = entry.value;
        return Dismissible(
          key: Key(review.reviewId.toString()),
          background: _buildDismissBackground(Colors.red, Icons.delete, index),
          secondaryBackground: _buildDismissBackground(Colors.blue, Icons.edit, index),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              return await _showDeleteConfirmation(context, review);
            } else {
              controller.startEditingReview(review);
              controller.isReviewFormVisible.value = true;
              return false;
            }
          },
          child: Card(
            elevation: 0,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          review.user!.userProfilePicture != null
                              ? '${Strings().resourceUrl}/${review.user!.userProfilePicture!.entityName}'
                              : '${Strings().resourceUrl}/profile.jpg',
                        ),
                        radius: 20,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.user!.username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: Color(0xFFFFD700),
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    review.comment!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDismissBackground(Color color, IconData icon, int index) {
    return controller.package.value?.reviews[index].user?.username ==
            controller.currentUsername.value
        ? Container(
            color: color,
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          )
        : SizedBox.shrink();
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Review review) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('Delete Review'),
        content: Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteReview(
                review.reviewId!,
                controller.package.value!.packageId,
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialChip(List<MaterialPackageModel> material) {
    return material.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Materials',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: material
                    .map((material) => Chip(
                          label: Text(
                              '${material.material.name} (${material.percentage}%)'),
                          backgroundColor: Colors.white,
                        ))
                    .toList(),
              ),
            ],
          )
        : SizedBox.shrink();
  }
}
