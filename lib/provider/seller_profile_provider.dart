import 'package:flutter/material.dart';
import 'package:thrift/model/ProductListSellerModel.dart';

import '../api_service/seller_profile_api.dart';

class SellerProfileProvider with ChangeNotifier{
  ProductListSellerModel? productListModel;
  String? myfilter_str = 'Newest to Oldest';
  bool myloader=true;
  String? get filter_str => myfilter_str;
  bool get loader=> myloader;


  getProduct(filter_str) async{
    myfilter_str=filter_str;
    productListModel=await SellerProfileApiService().fetchAlbum(filter_str);
    myloader=false;
    notifyListeners();
  }


  ProductListSellerModel? productListSellerModel;
  bool _loader_seller=true;
  bool get loader_seller=> _loader_seller;


  getSellerProductList() async{
    // _loader_seller=true;
    productListSellerModel=await SellerProfileApiService().fetchProductListSeller();
    _loader_seller=false;
    notifyListeners();
  }
}