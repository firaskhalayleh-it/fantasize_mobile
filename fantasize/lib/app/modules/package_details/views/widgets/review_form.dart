import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fantasize/app/data/models/reviews_model.dart';
import 'package:fantasize/app/modules/package_details/controllers/package_details_controller.dart';

class ReviewFormPackage extends GetView<PackageDetailsController> {
  final int packageId;
  final bool isEditing;
  final Review? review;

  ReviewFormPackage({
    required this.packageId,
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
                selectedRating.value = index + 1; // Set the selected rating
                print('Selected rating: ${selectedRating.value}');
              },
              child: Icon(
                index < selectedRating.value ? Icons.star : Icons.star_border,
                color: Colors.yellow,
              ),
            );
          }),
        )),
        
        SizedBox(height: 10),
        
        // Add or Update Review button with styling
        ElevatedButton(
          onPressed: () {
            controller.addOrUpdateReview(
              packageId,
              commentController.text,
              selectedRating.value,
            );
          },
          child: Text(isEditing ? 'Update Review' : 'Add Review', style: TextStyle(fontSize: 16,color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
