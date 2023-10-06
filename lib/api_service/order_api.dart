import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:thrift/model/OrderDetailModel.dart';
import 'package:thrift/model/OrderListModel.dart';

class OrderApiService{
  OrderListModel? orderListModel;

  Future<OrderListModel?> fetchOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Response response = await get(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/view_user_order'),
          headers: headers);

      final jsonResponse = json.decode(response.body);
      print('OrderListScreen view_user_order Response status2: ${response.statusCode}');
      print('OrderListScreen view_user_order Response body2: ${response.body}');
      orderListModel = new OrderListModel.fromJson(jsonResponse);

      return orderListModel;
    }   on Exception catch (e) {

      print('caught error $e');
    }
  }


  OrderDetailModel? orderDetailModel;
  Future<OrderDetailModel?> fetchOrderDetail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      String? order_id = prefs.getString('order_id');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({"order_id": order_id});
      print(msg);

      Response response = await post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/get_order_detail'),
          headers: headers,
          body: msg);

      final jsonResponse = json.decode(response.body);
      print('OrderDetailScreen get_order_detail Response status2: ${response.statusCode}');
      print('OrderDetailScreen get_order_detail Response body2: ${response.body}');
      orderDetailModel = new OrderDetailModel.fromJson(jsonResponse);

      return orderDetailModel;
    } on Exception catch (e) {

      print('caught error $e');
    }
  }


  OrderListModel? vendorOrderListModel;
  Future<OrderListModel?> fetchVendorOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      print(token);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Response response = await get(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/view_vendor_order'),
          headers: headers);



      print('MySalesFragment view_vendor_order Response status2: ${response.statusCode}');
      print('MySalesFragment view_vendor_order Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      vendorOrderListModel = new OrderListModel.fromJson(jsonResponse);

      return vendorOrderListModel;
    } on Exception catch (e) {

      print('caught error $e');
    }
  }

  OrderDetailModel? vendorOrderDetailModel;
  String? vendor_country;
Future<OrderDetailModel?> fetchVendorOrderDetail() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String UserId = prefs.getString('UserId');
    String? token = prefs.getString('token');
    String? order_id = prefs.getString('order_id');
    vendor_country = prefs.getString('vendor_country');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final msg = jsonEncode({"order_id": order_id});
    print(msg);

    Response response = await post(
        Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/get_order_detail'),
        headers: headers,
        body: msg);

    final jsonResponse = json.decode(response.body);
    print('VendorOrderDetailScreen get_order_detail Response status2: ${response.statusCode}');
    print('VendorOrderDetailScreen get_order_detail Response body2: ${response.body}');
    vendorOrderDetailModel = new OrderDetailModel.fromJson(jsonResponse);

    return vendorOrderDetailModel;
  }  on Exception catch (e) {

    print('caught error $e');
  }
}
}