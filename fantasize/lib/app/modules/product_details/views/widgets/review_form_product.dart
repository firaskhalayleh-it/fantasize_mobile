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

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit Your Review' : 'Write a Review',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Jost',
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          // Rating Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rating',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Obx(() => Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => selectedRating.value = index + 1,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            index < selectedRating.value
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: index < selectedRating.value
                                ? Colors.amber
                                : Colors.grey[400],
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  )),
            ],
          ),
          SizedBox(height: 16),
          // Comment Section
          TextField(
            controller: commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this product...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.redAccent,
                  width: 1,
                ),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
          ),
          SizedBox(height: 20),
          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (selectedRating.value == 0) {
                  Get.snackbar(
                    'Rating Required',
                    'Please select a rating before submitting',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    margin: EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                  return;
                }
                if (commentController.text.trim().isEmpty) {
                  Get.snackbar(
                    'Review Required',
                    'Please write a review before submitting',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    margin: EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                  return;
                }
                controller.addOrUpdateReview(
                  productId,
                  commentController.text,
                  selectedRating.value,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Update Review' : 'Submit Review',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}