import 'dart:convert';

class ResourcesModel {
  final int resourceId;
  final String entityName;
  final String fileType;
  final String filePath;

  ResourcesModel({
    required this.resourceId,
    required this.entityName,
    required this.fileType,
    required this.filePath,
  });

  factory ResourcesModel.fromJson(Map<String, dynamic> json) {
    return ResourcesModel(
      resourceId: json['ResourceID'],
      entityName: json['entityName'],
      fileType: json['fileType'],
      filePath: json['filePath'],
    );
  }
}
