class SubCategory {
  int? subCategoryId;
  String? name;
  bool? isActive;

  SubCategory({this.subCategoryId, this.name, this.isActive});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subCategoryId: json['SubCategoryID'],
      name: json['Name'],
      isActive: json['IsActive'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'SubCategoryID': subCategoryId,
      'Name': name,
      'IsActive': isActive,
    };
  }
}
