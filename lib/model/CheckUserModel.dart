class CheckUserModel {
  bool? success;
  int? is_store_owner;

  CheckUserModel({this.success, this.is_store_owner});

  CheckUserModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    is_store_owner = json['is_store_owner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['is_store_owner'] = this.is_store_owner;
    return data;
  }
}