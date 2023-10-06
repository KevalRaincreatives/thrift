import 'package:flutter/material.dart';
import 'package:thrift/model/OrderDetailModel.dart';
import 'package:thrift/model/OrderListModel.dart';
import 'package:thrift/api_service/order_api.dart';

class OrderProvider with ChangeNotifier{
  OrderListModel? orderListModel;
  bool _loader = true;

  bool get loader => _loader;
  getOrderList()async{
    orderListModel=await OrderApiService().fetchOrder();
    _loader = false;
    notifyListeners();
  }

  OrderDetailModel? orderDetailModel;
  bool _loader_det = true;

  bool get loader_det => _loader_det;
  getOrderDetails()async{
    _loader_det = true;
    orderDetailModel=await OrderApiService().fetchOrderDetail();
    _loader_det = false;
    notifyListeners();
  }


  OrderListModel? vendorOrderListModel;
  bool _loader_vendor = true;

  bool get loader_vendor => _loader_vendor;
  getVendorOrderList()async{
    vendorOrderListModel=await OrderApiService().fetchVendorOrder();
    _loader_vendor = false;
    notifyListeners();
  }

  OrderDetailModel? vendorOrderDetailModel;
  bool _loader_det_vendor = true;

  bool get loader_det_vendor => _loader_det_vendor;
  getVendorOrderDetails()async{
    _loader_det_vendor=true;
    vendorOrderDetailModel=await OrderApiService().fetchVendorOrderDetail();
    _loader_det_vendor = false;
    notifyListeners();
  }

}