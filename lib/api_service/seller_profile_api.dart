import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:thrift/model/ProductListSellerModel.dart';
import 'package:http/http.dart' as http;

class SellerProfileApiService {
  ProductListSellerModel? productListModel;
  Future<ProductListSellerModel?> fetchAlbum(filter_str) async {
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? user_country = prefs.getString('user_selected_country');
      String? seller_id = prefs.getString('seller_id');
      String? UserId= prefs.getString('UserId');
      // toast(cat_id);

      var response;
      if (filter_str == 'Newest to Oldest') {
        response = await http.get(Uri.parse(
            "${Url.BASE_URL}wp-json/wooapp/v3/seller_products?orderby=date&order=desc&per_page=100&country=$user_country&seller_id=$UserId"));

        print("${Url.BASE_URL}wp-json/wooapp/v3/seller_products?orderby=date&order=desc&per_page=100&country=$user_country&seller_id=$UserId");
      } else if (filter_str == 'Oldest to Newest') {
        response = await http.get(Uri.parse(
            "${Url.BASE_URL}wp-json/wooapp/v3/seller_products?orderby=date&order=asc&per_page=100&country=$user_country&seller_id=$UserId"));
        print("${Url.BASE_URL}wp-json/wooapp/v3/seller_products?orderby=date&order=asc&per_page=100&country=$user_country&seller_id=$UserId");
      } else if (filter_str == 'Price High to Low') {
        response = await http.get(Uri.parse(
            "${Url.BASE_URL}wp-json/wooapp/v3/seller_products?orderby=price&order=desc&per_page=100&country=$user_country&seller_id=$UserId"));
        print("${Url.BASE_URL}wp-json/wooapp/v3/seller_products?orderby=price&order=desc&per_page=100&country=$user_country&seller_id=$UserId");
      } else if (filter_str == 'Price Low to High') {
        response = await http.get(Uri.parse(
            "${Url.BASE_URL}wp-json/wooapp/v3/seller_products?orderby=price&order=asc&per_page=100&country=$user_country&seller_id=$UserId"));
        print("${Url.BASE_URL}wp-json/wooapp/v3/seller_products?orderby=price&order=asc&per_page=100&country=$user_country&seller_id=$UserId");
      }
      print('SellerEditProfileScreen seller_products Response status2: ${response.statusCode}');
      print('SellerEditProfileScreen seller_products Response body2: ${response.body}');

      // productListModel!.products!.clear();
      final jsonResponse = json.decode(response.body);
      productListModel = new ProductListSellerModel.fromJson(jsonResponse);

      return productListModel;
    } on Exception catch (e) {

      print('caught error $e');
    }
  }

  ProductListSellerModel? productListSellerModel;
  Future<ProductListSellerModel?> fetchProductListSeller() async {
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? seller_id = prefs.getString('seller_id');
      // toast(seller_id);

      var response = await http.get(
          Uri.parse("${Url.BASE_URL}wp-json/wooapp/v3/seller_products_customers?seller_id=$seller_id"));

      print('SellerProfileScreen seller_products_customers Response status2: ${response.statusCode}');
      print('SellerProfileScreen seller_products_customers Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      productListSellerModel = new ProductListSellerModel.fromJson(jsonResponse);

      return productListSellerModel;
    } on Exception catch (e) {

      print('caught error $e');
    }
  }

}