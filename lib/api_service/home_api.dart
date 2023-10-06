import 'dart:convert';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/api_service/Url.dart';

import '../model/AttributeModel.dart';
import '../model/CategoryModel.dart';
import '../model/CheckUserModel.dart';
import '../model/CountryParishModel.dart';
import '../model/NewCategoryModel.dart';
class HomeApiService{
  Trace customTrace = FirebasePerformance.instance.newTrace('products');
  Trace customTraceHomeProduct = FirebasePerformance.instance.newTrace('fetchCountry');
  Trace customTraceCategory = FirebasePerformance.instance.newTrace('woo_product_categories');
  Future<List<ProductListModel>?> fetchAlbum(filter_str) async {
    List<ProductListModel> productListModel = [];
    await customTraceHomeProduct.start();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? user_country = prefs.getString('user_selected_country');

      // String? user_country = "Barbados";
      // toast(cat_id);

      var response;
      if (filter_str == 'Newest to Oldest') {
        response = await http.get(Uri.parse(
            "${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=date&order=desc&per_page=100"));
      } else if (filter_str == 'Oldest to Newest') {
        response = await http.get(Uri.parse(
            "${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=date&order=asc&per_page=100"));
      } else if (filter_str == 'Price High to Low') {
        response = await http.get(Uri.parse(
            "${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=price&order=desc&per_page=100"));
      } else if (filter_str == 'Price Low to High') {
        response = await http.get(Uri.parse(
            "${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=price&order=asc&per_page=100"));
      }
      print('HomeFragment products Response status2: ${response.statusCode}');
      print('HomeFragment products Response body2: ${response.body}');

      productListModel.clear();
      final jsonResponse = json.decode(response.body);
      for (Map i in jsonResponse) {
        if (i["product_country"] == user_country) {
          productListModel.add(ProductListModel.fromJson(i));
        }
      }
      if (productListModel.length > 0) {
        prefs.setString("fnl_currency", "USD");
      }
      await customTraceHomeProduct.stop();
      return productListModel;
    } catch (e) {
      await customTraceHomeProduct.stop();
      print('caught error $e');
    }
  }
  CountryParishModel? countryNewModel;
  Future<CountryParishModel?> fetchcountry() async {

    await customTrace.start();
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};

      var response = await http
          .get(Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/countries'));

      print('SettingFragment countries Response status2: ${response.statusCode}');
      print('SettingFragment countries Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      countryNewModel = new CountryParishModel.fromJson(jsonResponse);
      print('Caught error ');
      await customTrace.stop();
      return countryNewModel;
    } catch (e) {
      await customTrace.stop();
      print('Caught error $e');
    }
  }

  CategoryModel? categoryModel;

  Future<CategoryModel?> fetchCategory() async {
    await customTraceCategory.start();
    try {
        final client = RetryClient(http.Client());
        var response;
        try {
          response = await client.get(Uri.parse(
              "${Url.BASE_URL}wp-json/wooapp/v3/woo_product_categories"));
        } finally {
          client.close();
        }

        print('Response status2: ${response.statusCode}');
        print('Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        categoryModel = new CategoryModel.fromJson(jsonResponse);
        await customTraceCategory.stop();
      return categoryModel;
    } catch (e) {
      await customTraceCategory.stop();
//      return orderListModel;
      print('caught error $e');
    }
  }

  AttributeModel? attributeModel;
  Future<AttributeModel?> fetchAttribute() async {
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
//       var response = await http.get(
//           Uri.parse("https://encros.rcstaging.co.in/wp-json/wc/v3/products/categories"));
        final client = RetryClient(http.Client());
        var response;
        try {
          response = await client.get(Uri.parse(
              "${Url.BASE_URL}wp-json/wooapp/v3/attributes"));
        } finally {
          client.close();
        }
        attributeModel = null;

        print('CreateProductScreen attributes Response status2: ${response.statusCode}');
        print('CreateProductScreen attributes Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        attributeModel = new AttributeModel.fromJson(jsonResponse);

      return attributeModel;
    }catch (e) {

      print('caught error $e');
    }
  }

  CheckUserModel? checkUserModel;
  Future<CheckUserModel?> fetchUserSellerStatus() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

        print(
            "${Url.BASE_URL}wp-json/wooapp/v3/check_seller_status?user_id=$UserId");
        var response = await http.get(
            Uri.parse(
              "${Url.BASE_URL}wp-json/wooapp/v3/check_seller_status?user_id=$UserId",
            ),
            headers: headers);


        print(
            'HomeFragment check_seller_status Response status2: ${response.statusCode}');
        print(
            'HomeFragment check_seller_status Response body2: ${response.body}');

        final jsonResponse = json.decode(response.body);
        checkUserModel = new CheckUserModel.fromJson(jsonResponse);
        prefs.setString(
            'is_store_owner', checkUserModel!.is_store_owner.toString());
        EasyLoading.dismiss();





      return checkUserModel;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

}