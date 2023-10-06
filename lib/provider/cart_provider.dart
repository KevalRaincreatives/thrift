import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:thrift/model/CartModel.dart';
import 'package:thrift/model/OrderProductModel.dart';
import 'package:http/http.dart' ;
import 'package:thrift/api_service/cart_api.dart';

class CartProvider with ChangeNotifier{
  CartModel? cat_model;
  final List<OrderProductModel> itemsModel = [];
  OrderProductModel? itModel;
  String? firstname, lastname, address1, city, postcode, country_id, state;
  String? shipping_charge,
      total_amount,
      payment_method,
      shipment_method,
      shipment_title,
      payment_type;
  bool? isVisible;
  String? currency, currency_pos;
  String? final_token;

  bool _loader = true;

  bool get loader => _loader;

  getCartOrder() async{
    _loader = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final_token = prefs.getString('token');
    currency = prefs.getString('currency');
    currency_pos = prefs.getString('currency_pos');
    if (final_token == null) {
      final_token = '';
    }
    firstname = prefs.getString('firstname');
    lastname = prefs.getString('lastname');
    address1 = prefs.getString('address1');
    city = prefs.getString('city');
    postcode = prefs.getString('postcode');
    country_id = prefs.getString('country_id');
    state = prefs.getString('zone_id');
    total_amount = prefs.getString('total_amnt');
      payment_method = prefs.getString('payment_method');
      payment_type = prefs.getString('payment_type');
    if (prefs.getString('delivery_status') == 'yes') {
      isVisible = true;

      shipping_charge = prefs.getString('shipping_charge');
      shipment_method = prefs.getString('shipment_method');
      shipment_title = prefs.getString('shipment_title');
    } else {
      isVisible = false;
      shipping_charge = "0";
      shipment_method = "";
      shipment_title = "";
    }
    cat_model=await CartApiService().fetchCart();
    itemsModel.clear();

    prefs.setString(
        'order_proname', cat_model!.cart![0]!.productName.toString());
    prefs.setString(
        'order_proprice', cat_model!.cart![0]!.productPrice.toString());
    prefs.setString(
        'order_proimage', cat_model!.cart![0]!.productImage.toString());

    for (int i = 0; i < cat_model!.cart!.length; i++) {
      if (cat_model!.cart![i]!.variationId.runtimeType == int) {
        itModel = OrderProductModel(
            pro_id: cat_model!.cart![i]!.productId.toString(),
            variation_id: '',
            quantity: cat_model!.cart![i]!.quantity.toString());
        itemsModel.add(itModel!);
      } else if (cat_model!.cart![i]!.variationId.runtimeType == String) {
        if (cat_model!.cart![i]!.variationId != '') {
          itModel = OrderProductModel(
              pro_id: cat_model!.cart![i]!.productId.toString(),
              variation_id: cat_model!.cart![i]!.variationId.toString(),
              quantity: cat_model!.cart![i]!.quantity.toString());
          itemsModel.add(itModel!);
        } else {
          itModel = OrderProductModel(
              pro_id: cat_model!.cart![i]!.productId.toString(),
              variation_id: '',
              quantity: cat_model!.cart![i]!.quantity.toString());
          itemsModel.add(itModel!);
        }
      }

    }
    _loader = false;
    notifyListeners();
  }

}