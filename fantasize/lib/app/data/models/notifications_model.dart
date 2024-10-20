import 'package:fantasize/app/data/models/user_model.dart';
import 'package:get/get.dart';


class NotificationModel extends GetxController {
  int? notificationID;
  User? user;
  String? type; 
  Map<String, dynamic>? template; 
  String? subject;
  bool? isRead;

  // Constructor
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
      notificationID: json['notificationID'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      template: json['template'] != null
          ? Map<String, dynamic>.from(json['template'])
          : null,
      subject: json['subject'],
      isRead: json['isRead'],
      
    );
  }

  // Method to convert NotificationModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationID': notificationID,
      'user': user?.toJson(),
      'type': type,
      'subject': subject,
      'isRead': isRead,
      
    };
  }
}
