///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class EstPriceModel {
/*
{
  "success": true,
  "estimated_retail_price": "70"
}
*/

  bool? success;
  String? estimatedRetailPrice;

  EstPriceModel({
    this.success,
    this.estimatedRetailPrice,
  });
  EstPriceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    estimatedRetailPrice = json['estimated_retail_price']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    data['estimated_retail_price'] = estimatedRetailPrice;
    return data;
  }
}
