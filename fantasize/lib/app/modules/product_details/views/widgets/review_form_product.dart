import 'package:fantasize/app/modules/product_details/controllers/product_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/data/models/reviews_model.dart';

class ReviewFormProduct extends GetView<ProductDetailsController> {
  final int productId;
  final bool isEditing;
  final Review? review;

  ReviewFormProduct({
    required this.productId,
    required this.isEditing,
    this.review,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    final RxInt selectedRating = RxInt(0);

    if (isEditing && review != null) {
      commentController.text = review!.comment!;
      selectedRating.value = review!.rating!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: commentController,
          decoration: InputDecoration(labelText: 'Comment'),
        ),
        SizedBox(height: 10),

        // Star rating selection
        Obx(() => Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    selectedRating.value = index + 1;
                    print('Selected rating: ${selectedRating.value}');
                  },
                  child: Icon(
                    index < selectedRating.value
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.yellow,
                  ),
                );
              }),
            )),
        SizedBox(height: 20),

        // Add or Update button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              controller.addOrUpdateReview(
                productId,
                commentController.text,
                selectedRating.value,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(vertical: Get.height * 0.015 , horizontal: Get.width * 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEditing ? 'Update Review' : 'Add Review',
              style: TextStyle(fontSize: 16, color: Colors.white,fontFamily: 'Jost'),
            ),
          ),
        ),
      ],
    );
  }
}
