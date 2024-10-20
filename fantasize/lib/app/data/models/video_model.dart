import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model for storing video details
class VideoModel {
  final int videoId;
  final String videoPath;
  final int? productId;
  final int? packageId;

  VideoModel({
    required this.videoId,
    required this.videoPath,
    this.productId,
    this.packageId,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: json['videoId'],
      videoPath: json['videoPath'],
      productId: json['productId'],
      packageId: json['packageId'],
    );
  }
}
