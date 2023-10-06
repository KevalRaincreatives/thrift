import 'package:flutter/material.dart';

import '../api_service/pro_list_api.dart';
import '../model/ProductListModel.dart';
import '../utils/ShColors.dart';

class ProductListProvider with ChangeNotifier {
  List<ProductListModel> productListModel = [];
  bool _loader_prolist = true;

  bool get loader_prolist => _loader_prolist;

  getProductList() async {
    _loader_prolist = true;
    productListModel = (await ProductListApiService().fetchAlbum())!;
    _loader_prolist = false;
    notifyListeners();
  }

}
