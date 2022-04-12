class ViewProModel {
  String? profile_picture;

  ViewProModel({this.profile_picture});

  ViewProModel.fromJson(Map<String, dynamic> json) {
    profile_picture = json['profile_picture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profile_picture'] = this.profile_picture;
    return data;
  }
}