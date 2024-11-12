import 'package:fantasize/app/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class NotificationModel extends GetxController {
  int? notificationID;
  User? user;
  String? subject;
  bool? isRead;
  dynamic template; // Can be either Map<String, dynamic> or String

  NotificationModel({
    this.notificationID,
    this.user,
    this.template,
    this.subject,
    this.isRead,
  });

  // Factory method to create NotificationModel object from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationID: json['notificationID'] as int?,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : null,
      template: json['template'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['template'])
          : json['template'] as String?, // Handle String or Map
      subject: json['subject'] as String?,
      isRead: json['isRead'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationID': notificationID,
      'user': user?.toJson(),
      'template': template, // Can be either a String or a Map
      'subject': subject,
      'isRead': isRead,
    };
  }
}
