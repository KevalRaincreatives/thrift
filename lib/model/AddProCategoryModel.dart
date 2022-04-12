class AddProCategoryModel {
  int? id;


  AddProCategoryModel(
      {this.id});

  factory AddProCategoryModel.fromJson(Map<String, dynamic> json) {
    return AddProCategoryModel(
        id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id
    };
  }
}