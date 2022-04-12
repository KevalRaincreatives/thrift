
class OrderProductModel {
  String? pro_id;
  String? variation_id;
  String? quantity;

  OrderProductModel({this.pro_id,this.variation_id,
    this.quantity});

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
        pro_id: json['pro_id'],
        variation_id: json['variation_id'],
        quantity: json['quantity']);
  }

  Map<String, dynamic> toJson() {
    return {
      'pro_id': pro_id,
      'variation_id': variation_id,
      'quantity': quantity
    };
  }
}