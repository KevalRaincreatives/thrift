import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/api_service/Url.dart';

import '../model/ProductListModel.dart';
import 'package:http/http.dart'as http;
class AtrModel {
  String key;
  String value;

  AtrModel(this.key,this.value);
}

class SearchApiService{

  List<ProductListModel> productListModel = [];
  List<ProductListModel> productListModel2 = [];
  Future<List<ProductListModel>?> SearchData(searchText,filter_str,shoptext,colortext,sizetext,conditiontext) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? user_country = "India";
      // toast(cat_id);

      print("${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&country=$user_country&search=$searchText");
      var response;
      if (filter_str == 'Newest to Oldest') {
        response = await http.get(
            Uri.parse("${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=date&order=desc&country=$user_country&search=$searchText"));

      } else if (filter_str == 'Oldest to Newest') {
        response = await http.get(
            Uri.parse("${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=date&order=asc&country=$user_country&search=$searchText"));
      } else if (filter_str == 'Price High to Low') {
        response = await http.get(
            Uri.parse("${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=price&order=desc&country=$user_country&search=$searchText"));
      } else if (filter_str == 'Price Low to High') {

        response = await http.get(
            Uri.parse("${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=price&order=asc&country=$user_country&search=$searchText"));
      }
      // response = await http.get(
      //     Uri.parse("${Url.BASE_URL}wp-json/wc/v3/products?stock_status=instock&status=publish&country=$user_country&search=$searchText"));

      print('SearchScreen products Response status2: ${response.statusCode}');
      print('SearchScreen products Response body2: ${response.body}');
      productListModel.clear();
      Map<String, dynamic> input = {
        "key":"Size",
        "value":"s"
      };

      final jsonResponse = json.decode(response.body);
      EasyLoading.dismiss();
      for (Map i in jsonResponse) {
        bool allCondition=true;

        if(sizetext!=null||colortext!=''||conditiontext!=null ){
        for (var meta in i['meta_data']) {
          if (meta['key'] == 'attrs_val') {
            List<dynamic> attrsVal = meta['value'];
            print("myvhc" + attrsVal.length.toString());
            for (var j = 0; j < attrsVal.length; j++) {
         if(sizetext!=null&&colortext!=''&&conditiontext!=null){
           if (attrsVal[j]['key'] == 'Size') {
             if (attrsVal[j]['value'] != sizetext) {
               allCondition=false;
               break;
             }
           }

           if (attrsVal[j]['key'] == 'Color') {
             if (!(attrsVal[j]['value'].toLowerCase().contains(colortext.toLowerCase()))) {
               allCondition=false;
               break;
             }
           }
           if (attrsVal[j]['key'] == 'Condition') {
             if (attrsVal[j]['value'] != conditiontext) {
               allCondition=false;
               break;
             }
           }


         }else {
           allCondition=false;
           if(sizetext!=null){
           if (attrsVal[j]['key'] == 'Size') {
             if (attrsVal[j]['value'] == sizetext) {
               if(shoptext!=''){
                 if (i["store"]["vendor_shop_name"]!=null &&i["store"]["vendor_shop_name"].toLowerCase().contains(shoptext.toLowerCase())) {
                   productListModel.add(ProductListModel.fromJson(i));
                   break;
                 }
               }else{
                 productListModel.add(ProductListModel.fromJson(i));
                 break;
               }
             }
           }

         }else if(conditiontext!=null){
             if (attrsVal[j]['key'] == 'Condition') {
               if (attrsVal[j]['value'] == conditiontext) {
                 if(shoptext!=''){
                   if (i["store"]["vendor_shop_name"]!=null &&i["store"]["vendor_shop_name"].toLowerCase().contains(shoptext.toLowerCase())) {
                     productListModel.add(ProductListModel.fromJson(i));
                     break;
                   }
                 }else{
                   productListModel.add(ProductListModel.fromJson(i));
                   break;
                 }
               }
             }

           }else{
             allCondition=false;
           if(colortext!='') {
             if (attrsVal[j]['key'] == 'Color') {
               if (attrsVal[j]['value'].toLowerCase().contains(colortext.toLowerCase())) {
                 if (shoptext != '') {
                   if (i["store"]["vendor_shop_name"]!=null &&i["store"]["vendor_shop_name"].toLowerCase().contains(shoptext.toLowerCase())) {
                     productListModel.add(ProductListModel.fromJson(i));
                     break;
                   }
                 } else {
                   productListModel.add(ProductListModel.fromJson(i));
                   break;
                 }
               }
             }
           }
           }
         }

            }
            if(allCondition){
              if(shoptext!=''){
                if (i["store"]["vendor_shop_name"]!=null &&i["store"]["vendor_shop_name"].toLowerCase().contains(shoptext.toLowerCase())) {
                  productListModel.add(ProductListModel.fromJson(i));
                }
              }else{
                productListModel.add(ProductListModel.fromJson(i));
              }
            }
          }
        }
        }else if(shoptext!='') {

            if (i["store"]["vendor_shop_name"]!=null && i["store"]["vendor_shop_name"].toLowerCase().contains(shoptext.toLowerCase())) {
              productListModel.add(ProductListModel.fromJson(i));
          }
        }else{
          productListModel.add(ProductListModel.fromJson(i));
        }
        // if (i["store"]["vendor_shop_name"] == 'xlxnis') {
        //
        //
        //   productListModel.add(ProductListModel.fromJson(i));
        // }
      }


      // searchController.text=='widget.serchdata';
      //
      // setState(() {
      //   isEmpty = productListModel.isEmpty;
      // });

      return productListModel;
    } on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }
}