import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/product_details/views/widgets/video_player.dart';
import 'package:fantasize/app/modules/product_details/views/widgets/customization_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/product_details/controllers/product_details_controller.dart';

class ProductDetailsView extends StatelessWidget {
  final ProductDetailsController controller =
      Get.put(ProductDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Image(
            image: Svg('assets/icons/back_button.svg'),
          ),
        ),
        title: Image.asset('assets/icons/fantasize.png', width: 50, height: 50),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.product.value == null) {
              return Icon(Icons.favorite_border);
            } else {
              return IconButton(
                icon: Image(
                  image: Svg(
                    controller.isLiked.value
                        ? 'assets/icons/like.svg' // Filled heart icon for liked products
                        : 'assets/icons/like-outlined.svg', // Outlined heart for unliked products
                  ),
                ),
                onPressed: () {
                  controller.toggleLike();
                },
              );
            }
          }),
        ],
      ),
      body: Obx(() {
        if (controller.product.value == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          final product = controller.product.value!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.resources.isNotEmpty)
                  Container(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.resources.length,
                      itemBuilder: (context, index) {
                        final resource = product.resources[index];
                        if (resource.fileType == 'video/mp4') {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: VideoPlayerWidgetProduct(
                                videoUrl:
                                    '${Strings().resourceUrl}/${resource.entityName}'),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              '${Strings().resourceUrl}/${resource.entityName}',
                              fit: BoxFit.cover,
                              width: 300,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Product Name and Rating
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.avgRating} (${product.reviews?.length ?? 0} reviews)',
                            style: TextStyle(color: Colors.blue),
                          ),
                          SizedBox(width: 8),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < product.avgRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Color(0xFFFFD33C),
                              );
                            }),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Price (should be reactive)
                      Text(
                        'Price: \$${product.price}',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Product Description
                      Text(
                        product.description,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),

                      // Customization Section

                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          controller.product.value!.customizations.isNotEmpty
                              ? Divider()
                              : Container(),
                          ...controller.product.value!.customizations
                              .expand((customization) =>
                                  customization.options.map((option) => Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 8.0, bottom: 8.0),
                                            child: Text(
                                              option.name,
                                              style: TextStyle(
                                                  fontFamily: 'Jost',
                                                  fontSize: 14,
                                                  color: Color(0xFF65635F),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          CustomizationWidget(option: option)
                                        ],
                                      )))
                              .toList(),
                        ],
                      ),

                      // Reviews Section
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews',
                            style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              controller.toggleReviewFormVisibility();
                            },
                            icon: Icon(
                              controller.isReviewFormVisible.value
                                  ? Icons.remove
                                  : Icons.add,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

// Reviews List with Dismissible
                      ...?product.reviews?.map((review) {
                        return Dismissible(
                          key: Key(review.reviewId
                              .toString()), // Unique key for Dismissible
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Confirm delete
                              return await _confirmDelete(context, review);
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              // Trigger edit: Set form visible and load review for editing
                              Get.find<ProductDetailsController>()
                                  .startEditingReview(review);
                              Get.find<ProductDetailsController>()
                                  .isReviewFormVisible
                                  .value = true; // Show the form
                              return false; // Don't dismiss, just trigger edit
                            }
                            return false;
                          },
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    '${Strings().resourceUrl}/${review.user!.userProfilePicture!.entityName}'),
                              ),
                              title: Text(review.user!.username),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(review.comment!),
                                  Row(
                                    children: List.generate(5, (ratingIndex) {
                                      return Icon(
                                        ratingIndex < review.rating!
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.yellow,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 10),

                      // Review Form
                      Obx(() {
                        if (controller.isReviewFormVisible.value) {
                          return controller.isEditing.value
                              ? ReviewForm(
                                  productId: product.productId,
                                  isEditing: true,
                                  review: controller.reviewBeingEdited.value!,
                                )
                              : ReviewForm(
                                  productId: product.productId,
                                  isEditing: false,
                                );
                        } else {
                          return Container();
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  // Confirm delete dialog
  Future<bool?> _confirmDelete(BuildContext context, Review review) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Review'),
          content: Text('Are you sure you want to delete this review?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.find<ProductDetailsController>().deleteReview(
                    review.reviewId!,
                    Get.find<ProductDetailsController>()
                        .product
                        .value!
                        .productId);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// Review Form widget (used for both adding and editing reviews)
class ReviewForm extends StatefulWidget {
  final int productId;
  final bool isEditing;
  final Review? review; // If editing, we pass the review

  ReviewForm({required this.productId, required this.isEditing, this.review});

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final TextEditingController commentController = TextEditingController();
  int selectedRating = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.review != null) {
      commentController.text = widget.review!.comment!;
      selectedRating = widget.review!.rating!;
    } else {
      commentController.clear();
      selectedRating = 0; // Default to no stars selected for new reviews
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: commentController,
          decoration: InputDecoration(labelText: 'Comment'),
        ),
        SizedBox(height: 10),
        // Star rating selection
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedRating =
                      index + 1; // Update the rating based on the tapped star
                });
              },
              child: Icon(
                index < selectedRating ? Icons.star : Icons.star_border,
                color: Colors.yellow,
              ),
            );
          }),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (widget.isEditing) {
              // Update existing review
              Get.find<ProductDetailsController>().isReviewFormVisible.value =
                  true;
              Get.find<ProductDetailsController>().addOrUpdateReview(
                widget.productId,
                commentController.text,
                selectedRating,
              );
            } else {
              // Add new review
              Get.find<ProductDetailsController>().addOrUpdateReview(
                widget.productId,
                commentController.text,
                selectedRating,
              );
            }
          },
          child: Text(widget.isEditing ? 'Update Review' : 'Add Review'),
        ),
      ],
    );
  }
}
