class StaticCategoryModel {
  int? id;
  String? name;


  StaticCategoryModel(
      {this.id,
        this.name});

  factory StaticCategoryModel.fromJson(Map<String, dynamic> json) {
    return StaticCategoryModel(
        id: json['id'],
        name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}