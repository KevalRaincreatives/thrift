class SignUpErrorNewModel {
  String? msg;
  String? status;


  SignUpErrorNewModel({this.msg,this.status});

  SignUpErrorNewModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    status = json['status'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    data['status'] = this.status;
    return data;
  }
}