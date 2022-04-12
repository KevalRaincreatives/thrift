


import 'package:thrift/database/database_hepler.dart';

class CartPro {
  int? id;
  String? product_id;
  String? product_name;
  String? product_img;
  String? variation_id;
  String? variation_name;
  String? variation_value;
  String? quantity;
  String? line_subtotal;
  String? line_total;

  CartPro(
      this.id,
      this.product_id,
        this.product_name,
        this.product_img,
        this.variation_id,
        this.variation_name,
        this.variation_value,
        this.quantity,
        this.line_subtotal,
        this.line_total);

  CartPro.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toInt();
    product_id = json['product_id']?.toString();
    product_name= json['product_name']?.toString();
    product_img= json['product_img']?.toString();
    variation_id = json['variation_id']?.toString();
    variation_name = json['variation_name']?.toString();
    variation_value = json['variation_value']?.toString();
    quantity = json['quantity']?.toString();
    line_subtotal = json['line_subtotal']?.toString();
    line_total = json['line_total']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnProductId: product_id,
      DatabaseHelper.columnProductName: product_name,
      DatabaseHelper.columnProductImage: product_img,
      DatabaseHelper.columnVariationId: variation_id,
      DatabaseHelper.columnVariationName: variation_name,
      DatabaseHelper.columnVariationValue: variation_value,
      DatabaseHelper.columnQuantity: quantity,
      DatabaseHelper.columnLine_subtotal: line_subtotal,
      DatabaseHelper.columnLine_total: line_total,
    };
  }

}