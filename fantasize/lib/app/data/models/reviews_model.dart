import 'package:fantasize/app/data/models/user_model.dart';

class Review {
  final int? reviewId;
  final int? rating;
  final String? comment;
  final User? user; // Make user optional

  Review({
    required this.reviewId,
    required this.rating,
    required this.comment,
    this.user, // Allow user to be null
  });

  // Factory constructor to create a Review object from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['ReviewID'],
      rating: json['Rating'],
      comment: json['Comment'],
      user: json['User'] != null ? User.fromJson(json['User']) : null, // Handle null case for User
    );
  }

  // Method to convert Review object to JSON (useful if you need to send data)
  Map<String, dynamic> toJson() {
    return {
      'ReviewID': reviewId,
      'Rating': rating,
      'Comment': comment,
      'User': user?.toJson(), // Convert user to JSON if it exists
    };
  }
}
