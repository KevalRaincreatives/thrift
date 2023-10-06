import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/AdvModel.dart';
import 'package:thrift/model/CountryParishModel.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:thrift/api_service/home_api.dart';

import '../database/CartPro.dart';
import '../database/database_hepler.dart';
import '../model/AttributeModel.dart';
import '../model/CategoryModel.dart';
import '../model/CheckUserModel.dart';
import '../screens/BecameSellerScreen.dart';
import '../screens/CreateProductScreen.dart';
import '../utils/ShColors.dart';
import '../utils/ShExtension.dart';

class HomeProductListProvider with ChangeNotifier{

  List<ProductListModel> productListModel = [];
  String? myfilter_str = 'Newest to Oldest';
  bool myloader=true;
  bool _isLoading=true;

  String? get filter_str => myfilter_str;
  bool get loader=> myloader;

  bool get isLoading=> _isLoading;


  getHomeProduct(filter_str,loaders) async{
    myloader=loaders;
    _isLoading=true;
    myfilter_str=filter_str;
    productListModel=(await HomeApiService().fetchAlbum(filter_str))!;
    myloader=false;
    _isLoading=false;
    notifyListeners();
  }

  CountryParishModel? countryNewModel;
  getCountry()
  async{

    countryNewModel=await HomeApiService().fetchcountry();
    notifyListeners();
  }
  // AdvModel? advModel;
  // getAdv() async{
  //   advModel=await HomeApiService().fetchAdv();
  //   notifyListeners();
  // }

  bool _isLoadingCategory=true;


  bool get isLoadingCategory=> _isLoadingCategory;
 CategoryModel? categoryModel ;
  fetchCategory() async{
    categoryModel=(await HomeApiService().fetchCategory())!;
    _isLoadingCategory=false;
    notifyListeners();
  }

  AttributeModel? attributeModel;
  fetchAttribute() async{
    attributeModel=await HomeApiService().fetchAttribute();
    notifyListeners();
  }

  int _localCart=0;
  int get localCart=> _localCart;

  setLocalCart(int value){
    _localCart=value;
    notifyListeners();
  }

  getLocalCart() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<CartPro> cartPro = [];
    final dbHelper = DatabaseHelper.instance;
    final allRows = await dbHelper.queryAllRows();
    allRows.forEach((row) => cartPro.add(CartPro.fromJson(row)));
    if (cartPro.length == 0) {
      prefs.setInt("cart_count", 0);
      setLocalCart(0);
    }else{
      prefs.setInt("cart_count", cartPro.length);
      setLocalCart(prefs.getInt('cart_count')!);
    }

  }


  bool _isSellerLoading=true;

  bool get isSellerLoading=> _isSellerLoading;

  CheckUserModel? checkUserModel;

  void openCustomDialog2(BuildContext context, String title, bool close) {
    if (close) {
      Navigator.of(context).pop(true);
      // Navigator.pop(context);
      // Navigator.of(context, rootNavigator: true).pop();
    }else {
      showGeneralDialog(
          barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Visibility(
                        visible: !close,
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Circular progress indicator',
                          color: sh_colorPrimary2,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: sh_colorPrimary2,
                              fontSize: 18,
                              fontFamily: 'Bold')),
                      SizedBox(
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 200),
          barrierDismissible: false,
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Container();
          });
    }
  }

  void openCustomDialog3(BuildContext context, String title) {

    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: sh_colorPrimary2,
                              wordSpacing: 1.2,
                              fontSize: 20,
                              fontFamily: 'Bold')),
                      SizedBox(
                        height: 24,
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.of(context).pop(true);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.only(top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_btn_color,
                              radius: 10,
                              showShadow: true),
                          child: text("Home",
                              fontSize: 16.0,
                              textColor: sh_colorPrimary2,
                              isCentered: true,
                              fontFamily: 'Bold'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  void openCustomDialog4(BuildContext context, String title) {

    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: sh_colorPrimary2,
                              wordSpacing: 1.2,
                              fontSize: 18,
                              fontFamily: 'Bold')),
                      SizedBox(
                        height: 24,
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.of(context).pop(true);
                          // Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.only(top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_btn_color,
                              radius: 10,
                              showShadow: true),
                          child: text("Close",
                              fontSize: 16.0,
                              textColor: sh_colorPrimary2,
                              isCentered: true,
                              fontFamily: 'Bold'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

}