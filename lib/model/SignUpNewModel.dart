class SignUpNewModel {
  String? status;
  String? key;
  String? secret;

  SignUpNewModel({this.status, this.key, this.secret});

  SignUpNewModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    key = json['key'];
    secret = json['secret'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['key'] = this.key;
    data['secret'] = this.secret;
    return data;
  }
}