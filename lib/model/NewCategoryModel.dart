class NewCategoryModel {
  int? catid;
  String? name;
  bool? selected;


  NewCategoryModel(
      {this.catid,
        this.name,this.selected});

  factory NewCategoryModel.fromJson(Map<String, dynamic> json) {
    return NewCategoryModel(
        catid: json['catid'],
        name: json['name'],

        selected: json['selected']);
  }

  Map<String, dynamic> toJson() {
    return {
      'catid': catid,
      'name': name,
      'selected': selected,
    };
  }
}