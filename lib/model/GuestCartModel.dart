
class GuestCartModel {
  String? product_id;
  String? variation_id;
  String? variation;
  String? quantity;
  String? line_subtotal;
  String? line_total;

  GuestCartModel({this.product_id,this.variation_id,this.variation,
    this.quantity,this.line_subtotal,this.line_total});

  factory GuestCartModel.fromJson(Map<String, dynamic> json) {
    return GuestCartModel(
        product_id: json['product_id'],
        variation_id: json['variation_id'],
        variation: json['variation'],
        quantity: json['quantity'],
        line_subtotal: json['line_subtotal'],
        line_total: json['line_total']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': product_id,
      'variation_id': variation_id,
      'variation': variation,
      'quantity': quantity,
      'line_subtotal':line_subtotal,
      'line_total':line_total
    };
  }
}
class Variation3 {
  String? attributeColor;

  Variation3({this.attributeColor});

  Variation3.fromJson(Map<String, dynamic> json) {
    attributeColor = json['attribute_color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attribute_color'] = this.attributeColor;
    return data;
  }
}