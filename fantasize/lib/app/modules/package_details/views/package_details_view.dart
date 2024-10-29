// lib/app/modules/package_details/views/package_details_view.dart

import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/global/strings.dart';
import 'package:fantasize/app/modules/package_details/views/widgets/floating_price_button.dart';
import 'package:fantasize/app/modules/package_details/views/widgets/review_form.dart';
import 'package:fantasize/app/modules/package_details/views/widgets/video_player_widget_package.dart';
import 'package:fantasize/app/modules/product_details/views/widgets/floating_price_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/modules/package_details/controllers/package_details_controller.dart';

import 'widgets/customization_widget.dart';

class PackageDetailsView extends GetView<PackageDetailsController> {
  const PackageDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FloatingPriceButtonPackage(
          price: controller.package.value?.price?.toString() ?? '',
          onAddToCart: () {
            controller.addToCart(
                controller.package.value!,
                controller.convertCustomizationsToOrderedOptions(
                    controller.package.value!.customizations),
                controller.quantity.value);
          }),
      appBar: AppBar(
        foregroundColor: Colors.white,
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
            if (controller.package.value == null) {
              return Icon(Icons.favorite_border);
            } else {
              return IconButton(
                icon: Image(
                  image: Svg(
                    controller.isLiked.value
                        ? 'assets/icons/like.svg'
                        : 'assets/icons/like-outlined.svg',
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
        if (controller.package.value == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          final package = controller.package.value!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (package.resources.isNotEmpty)
                  Container(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: package.resources.length,
                      itemBuilder: (context, index) {
                        final resource = package.resources[index];
                        if (resource.fileType == 'video/mp4') {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: VideoPlayerWidgetPackage(
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
                      // package Name and Rating
                      Text(
                        package.name,
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
                                index < package.avgRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Color(0xFFFFD33C),
                              );
                            }),
                          ),
                          Text(
                            '${package.avgRating} (${package.reviews.length} reviews)',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Price (should be reactive)
                      Text(
                        'Price: \$${package.price}',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // package Description
                      Text(
                        package.description,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),

                      // Customization Section
                      Obx(() => Row(
                            children: [
                              IconButton(
                                  icon: Icon(Icons.remove),
                                  color: Colors.white,
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.redAccent)),
                                  onPressed: () {
                                    controller.decrementQuantity();
                                  }),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                controller.quantity.value.toString(),
                                style:
                                    TextStyle(fontFamily: 'Jost', fontSize: 18),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                color: Colors.white,
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Colors.redAccent)),
                                onPressed: () {
                                  controller.incrementQuantity();
                                },
                              ),
                            ],
                          )),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          controller.package.value!.customizations.isNotEmpty
                              ? Divider()
                              : Container(),
                          ...controller.package.value!.customizations
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
                                          PackageCustomizationWidget(
                                            customizations: controller
                                                .package.value!.customizations,
                                          )
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
                      ...?package.reviews?.map((review) {
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
                              Get.find<PackageDetailsController>()
                                  .startEditingReview(review);
                              Get.find<PackageDetailsController>()
                                  .isReviewFormVisible
                                  .value = true; // Show the form
                              return false; // Don't dismiss, just trigger edit
                            }
                            return false;
                          },
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(review
                                            .user!.userProfilePicture !=
                                        null
                                    ? '${Strings().resourceUrl}/${review.user!.userProfilePicture!.entityName}'
                                    : '${Strings().resourceUrl}/profile.jpg'),
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
                              ? ReviewFormPackage(
                                  packageId: package.packageId,
                                  isEditing: true,
                                  review: controller.reviewBeingEdited.value!,
                                )
                              : ReviewFormPackage(
                                  packageId: package.packageId,
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
}

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
              Get.find<PackageDetailsController>().deleteReview(
                  review.reviewId!,
                  Get.find<PackageDetailsController>()
                      .package
                      .value!
                      .packageId);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
