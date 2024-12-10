import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/product_details/views/widgets/review_form_product.dart';
import 'package:fantasize/app/modules/product_details/views/widgets/video_player.dart';
import 'package:fantasize/app/modules/product_details/views/widgets/customization_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/product_details/controllers/product_details_controller.dart';
import 'widgets/floating_price_button.dart';

class ProductDetailsView extends StatelessWidget {
  final ProductDetailsController controller = Get.put(ProductDetailsController());

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
        if (controller.product.value != null) {
          return FloatingPriceButton(
            price: controller.product.value!.price,
            onAddToCart: () => controller.addToCart(),
          );
        }
        return SizedBox.shrink();
      }),
      body: Obx(() {
        if (controller.product.value == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          );
        }

        final product = controller.product.value!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Gallery
              _buildMediaGallery(product),

              // Product Information
              Container(
                transform: Matrix4.translationValues(0, -20, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Header
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
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
                                    index < product.avgRating
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
                        product.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Quantity Selector
                    Padding(
                      padding: EdgeInsets.all(20),
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

                    // Customization Section
                    if (product.customizations.isNotEmpty)
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
                            ...product.customizations
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
                                            CustomizationWidgets(
                                              customizations: [customization],
                                            ),
                                            SizedBox(height: 16),
                                          ],
                                        )))
                                .toList(),
                          ],
                        ),
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
                          _buildReviewsList(product, context),
                          Obx(() {
                            if (controller.isReviewFormVisible.value) {
                              return Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: controller.isEditing.value
                                    ? ReviewFormProduct(
                                        productId: product.productId,
                                        isEditing: true,
                                        review:
                                            controller.reviewBeingEdited.value!,
                                      )
                                    : ReviewFormProduct(
                                        productId: product.productId,
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

  Widget _buildMediaGallery(product) {
    return Container(
      height: 400,
      child: Stack(
        children: [
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: product.resources.length,
            itemBuilder: (context, index) {
              final resource = product.resources[index];
              return Container(
                width: Get.width,
                child: resource.fileType == 'video/mp4'
                    ? VideoPlayerWidgetProduct(
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
                product.resources.length,
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

  Widget _buildReviewsList(product, BuildContext context) {
    if (product.reviews == null || product.reviews!.isEmpty) {
      return Center(
        child: Text('No reviews yet'),
      );
    }

    return Column(
      children: product.reviews!.map<Widget>((review) {
        return Dismissible(
          key: Key(review.reviewId.toString()),
          background: _buildDismissBackground(Colors.red, Icons.delete),
          secondaryBackground: _buildDismissBackground(Colors.blue, Icons.edit),
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
                                index < review.rating!
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

  Widget _buildDismissBackground(Color color, IconData icon) {
    return Container(
      color: color,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
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
                controller.product.value!.productId,
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
}