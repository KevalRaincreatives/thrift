///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class OrderSuccessModel {
/*
{
  "success": true,
  "msg": "Order Created Successfully!"
}
*/

  bool? success;
  String? msg;
  int? order_id;

  OrderSuccessModel({
    this.success,
    this.msg,
    this.order_id
  });
  OrderSuccessModel.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    msg = json["msg"]?.toString();
    order_id=json["order_id"].toInt();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["success"] = success;
    data["msg"] = msg;
    data["order_id"]=order_id;
    return data;
  }
}