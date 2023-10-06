import 'dart:convert';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/ProductDetailModel.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:http/http.dart' as http;

import '../model/EstPriceModel.dart';
import '../model/ProductSellerModel.dart';
import '../utils/ShExtension.dart';

class productDetailApiService {
  Trace customTraceEstPrice =
      FirebasePerformance.instance.newTrace('view_estimated_retail_price');
  Trace customTraceProDetail =
      FirebasePerformance.instance.newTrace('productsDetail');
  Trace customTraceProSeller =
  FirebasePerformance.instance.newTrace('get_product_seller');
  ProductDetailModel? pro_det_model;

  Future<ProductDetailModel?> fetchDetail() async {
    await customTraceProDetail.start();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pro_id = prefs.getString('pro_id');
      // toast(pro_id);
      print("${Url.BASE_URL}/wp-json/wc/v3/products/$pro_id");
      var response = await http
          .get(Uri.parse('${Url.BASE_URL}/wp-json/wc/v3/products/$pro_id'));
      final jsonResponse = json.decode(response.body);
      print(
          'ProductDetailScreen products Response status2: ${response.statusCode}');
      print('ProductDetailScreen products Response body2: ${response.body}');
      pro_det_model = new ProductDetailModel.fromJson(jsonResponse);
      await customTraceProDetail.stop();
      return pro_det_model;
    } catch (e) {
      await customTraceProDetail.stop();
      toast(e.toString());
      print('caught error $e');
    }
  }

  ProductSellerModel? productSellerModel;

  Future<ProductSellerModel?> fetchSeller() async {
    await customTraceProSeller.start();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pro_id = prefs.getString('pro_id');
      // toast(pro_id);
      print(
          "${Url.BASE_URL}wp-json/wooapp/v3/get_product_seller?product_id=$pro_id");
      var response = await http.get(Uri.parse(
          '${Url.BASE_URL}wp-json/wooapp/v3/get_product_seller?product_id=$pro_id'));
      final jsonResponse = json.decode(response.body);
      print(
          'ProductDetailScreen get_product_seller Response status2: ${response.statusCode}');
      print(
          'ProductDetailScreen get_product_seller Response body2: ${response.body}');
      productSellerModel = new ProductSellerModel.fromJson(jsonResponse);
      prefs.setString(
          "seller_pic", productSellerModel!.seller!.profile_picture!);
      await customTraceProSeller.stop();
      return productSellerModel;
    } catch (e) {
      await customTraceProSeller.stop();
      toast(e.toString());
      print('caught error $e');
    }
  }

  EstPriceModel? estPriceModel;

  Future<http.Response> fetchEstPrice() async {
    await customTraceEstPrice.start();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      String? pro_id = prefs.getString('pro_id');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(
          Uri.parse(
              '${Url.BASE_URL}wp-json/wooapp/v3/view_estimated_retail_price?product_id=$pro_id'),
          headers: headers);

      print('Response body view_estimated_retail_price: ${response.body}');
      await customTraceEstPrice.stop();
      return response;
    } catch (e) {
      await customTraceEstPrice.stop();
      print('Caught error $e');
      toast(e.toString());
      rethrow;
    }
  }
}
