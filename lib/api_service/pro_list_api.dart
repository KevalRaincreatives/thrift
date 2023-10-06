import 'dart:convert';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:http/http.dart'as http;

class ProductListApiService {
  Trace customTraceProductList = FirebasePerformance.instance.newTrace('ProductsList');
  List<ProductListModel> productListModel = [];
  Future<List<ProductListModel>?> fetchAlbum() async {
    await customTraceProductList.start();
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? user_country = prefs.getString('user_selected_country');
      // toast(cat_id);

      var response = await http.get(
          Uri.parse("${Url.BASE_URL}wp-json/wc/v3/products/?stock_status=instock&status=publish&orderby=date&order=desc&per_page=100&category=$cat_id"));

      print('ProductListScreen products Response status2: ${response.statusCode}');
      print('ProductListScreen products Response body2: ${response.body}');
      productListModel.clear();
      final jsonResponse = json.decode(response.body);
      for (Map i in jsonResponse) {
        if (i["product_country"] == user_country) {
          productListModel.add(ProductListModel.fromJson(i));
        }
      }
      await customTraceProductList.stop();
      return productListModel;
    }   catch (e) {
      await customTraceProductList.stop();
      print('caught error $e');
    }
  }

}