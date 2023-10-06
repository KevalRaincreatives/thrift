import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/api_service/pro_det_api.dart';
import 'package:thrift/model/ProductDetailModel.dart';
import 'package:thrift/model/ProductSellerModel.dart';

import '../model/EstPriceModel.dart';

class ProductDetailProvider with ChangeNotifier {
  ProductDetailModel? pro_det_model;
  bool _ct_changel = true;
  bool _loader = true;
  bool _isVisible = true;
  bool _isVisible_success = false;

  bool get loader => _loader;

  bool get ct_changel => _ct_changel;


  bool get isVisible => _isVisible;

  bool get isVisible_success => _isVisible_success;

  getProductDetail() async {
    _loader = true;
    _ct_changel = true;
    _isVisible = true;
    _isVisible_success = false;
    pro_det_model = await productDetailApiService().fetchDetail();
    _loader = false;
    _ct_changel = false;
    notifyListeners();
  }

   bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  setLoggedInStatus(bool value){
    _isLoggedIn=value;
    notifyListeners();
  }

  getUserLoggedInStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? final_token = prefs.getString('token');
    if (final_token != null && final_token != '') {
      setLoggedInStatus(true);
      // _isLoggedIn=true;
    }else{
      // _isLoggedIn=false;
      setLoggedInStatus(false);
    }


  }



  incrementCounter(bool ct_changel2) {
    // if (ct_changel2) {
      // setState(() {
        _ct_changel = false;
        _isVisible = false;
        _isVisible_success = true;
        notifyListeners();
        // cart_count = cart_count! + 1;
      // });
    // }
  }


  ProductSellerModel? productSellerModel;
  bool _loader_seller_det=true;
  bool get loader_seller_det=> _loader_seller_det;


  getSellerDetail() async{
    // _loader_seller=true;
    productSellerModel=await productDetailApiService().fetchSeller();
    _loader_seller_det=false;
    notifyListeners();
  }

  EstPriceModel? estPriceModel;
  bool _loader_est_price=true;
  bool get loader_est_price=> _loader_est_price;


  getEstmatePrice() async{
    var response=await productDetailApiService().fetchEstPrice();

    _loader_est_price=false;
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      estPriceModel = EstPriceModel.fromJson(jsonResponse);
    }else{
      estPriceModel=null;
    }
    notifyListeners();
  }
}
