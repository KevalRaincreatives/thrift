import 'package:flutter/material.dart';

import '../api_service/search_api.dart';
import '../model/ProductListModel.dart';

class SearchProvider with ChangeNotifier{
  bool _isSearch = true;
  bool _isFirst = true;
  bool get isSearch => _isSearch;
  bool get isFirst => _isFirst;
  String? myfilter_str = 'Newest to Oldest';
  String? get filter_str => myfilter_str;
  List<ProductListModel> productListModel = [];
  String? _selectsize;

  String? get selectsize => _selectsize;

  String? _selectcondition;

  String? get selectcondition => _selectcondition;

  bool _isVisible = false;
  bool get isVisible => _isVisible;

  fetchSearch(String searchText,String filter_str,String shoptext,String colortext, sizetext, conditiontext) async{
    // productListModel.clear();
    myfilter_str=filter_str;
    productListModel=(await SearchApiService().SearchData(searchText,filter_str,shoptext,colortext,sizetext,conditiontext))!;
    print("my lengh"+productListModel.length.toString());
    _isSearch=false;
    _isFirst=false;
    _isVisible=true;
    notifyListeners();
  }

  getDropVal()async{
    _selectsize='Select Color';
    _selectcondition='Select Condition';
    notifyListeners();
  }
  changeDropDownVal(newVal) async{
    _selectsize=newVal;
    notifyListeners();
  }

  changeConditionDropDownVal(newVal) async{
    _selectcondition=newVal;
    notifyListeners();
  }

  reverseSearch() async{
    _isSearch=true;
    _isFirst=false;
    notifyListeners();
  }

  fetchstart() async{
    _isSearch=true;
    _isFirst=true;
    myfilter_str="Newest to Oldest";
    notifyListeners();
  }



}