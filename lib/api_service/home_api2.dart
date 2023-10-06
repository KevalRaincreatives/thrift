import 'dart:convert';

import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/api_service/Url.dart';

import '../model/CategoryModel.dart';
import '../model/CountryParishModel.dart';
import '../model/NewCategoryModel.dart';
class HomeApiService2{
  Future<List<ProductListModel>?> fetchAlbum(filter_str) async {
    List<ProductListModel> productListModel = [];

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

      return productListModel;
    } on Exception catch (e) {

      print('caught error $e');
    }
  }
  CountryParishModel? countryNewModel;
  Future<CountryParishModel?> fetchcountry() async {
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};

      var response = await http
          .get(Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/countries'));

      print('SettingFragment countries Response status2: ${response.statusCode}');
      print('SettingFragment countries Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      countryNewModel = new CountryParishModel.fromJson(jsonResponse);
      print('Caught error ');

      return countryNewModel;
    } catch (e) {
      print('Caught error $e');
    }
  }

  CategoryModel? categoryModel;

  Future<CategoryModel?> fetchCategory() async {
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

      return categoryModel;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }
}