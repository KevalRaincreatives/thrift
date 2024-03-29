///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class BlockProductModel {
/*
{
  "success": true,
  "error": "Vendor Block Successfully."
}
*/

  bool? success;
  String? error;

  BlockProductModel({
    this.success,
    this.error,
  });
  BlockProductModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    data['error'] = error;
    return data;
  }
}
