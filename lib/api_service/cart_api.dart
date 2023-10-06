import 'dart:convert';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:thrift/model/CartModel.dart';
import 'package:http/http.dart' ;
import 'package:thrift/model/OrderProductModel.dart';

class CartApiService{
  CartModel? cat_model;
  final List<OrderProductModel> itemsModel = [];
  OrderProductModel? itModel;
  Trace traceWoocart = FirebasePerformance.instance.newTrace('woocart');

  Future<CartModel?> fetchCart() async {
    await traceWoocart.start();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      // currency = prefs.getString('currency');
      // currency_pos = prefs.getString('currency_pos');
      //
      // total_amount = prefs.getString('total_amnt');
      // payment_method = prefs.getString('payment_method');
      //
      // payment_type = prefs.getString('payment_type');
      String? user_country = prefs.getString('user_selected_country');

      // print("myship"+shipping_charge!);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Response response = await get(
          Uri.parse(
              '${Url.BASE_URL}wp-json/wooapp/v3/woocart?country=$user_country'),
          headers: headers);

      print('NewConfirmScreen woocart Response status2: ${response.statusCode}');
      print('NewConfirmScreen woocart Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);

      cat_model = new CartModel.fromJson(jsonResponse);

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

        // itModel = OrderProductModel(
        //     pro_id: cat_model.cart[i].productId.toString(),
        //     quantity: cat_model.cart[i].quantity.toString());
        // itemsModel.add(itModel);
      }

//      print(cat_model.data);
      await traceWoocart.stop();
      return cat_model;
    }  catch (e) {
      await traceWoocart.stop();
      print('caught error $e');
    }
  }



}