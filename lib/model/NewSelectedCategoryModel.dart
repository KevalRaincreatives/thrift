class NewSelectedCategoryModel {
  int? selcatid;


  NewSelectedCategoryModel(
      {this.selcatid});

  factory NewSelectedCategoryModel.fromJson(Map<String, dynamic> json) {
    return NewSelectedCategoryModel(
        selcatid: json['selcatid']);
  }

  Map<String, dynamic> toJson() {
    return {
      'selcatid': selcatid
    };
  }
}