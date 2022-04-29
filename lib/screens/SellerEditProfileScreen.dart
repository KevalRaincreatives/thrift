import 'dart:convert';

import 'package:thrift/model/ViewProModel.dart';
import 'package:thrift/utils/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/ProductDetailModel.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:thrift/model/ProductListSellerModel.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:thrift/model/ReviewModel.dart';
import 'package:thrift/screens/CartScreen2.dart';
import 'package:thrift/screens/ProductDetailScreen.dart';
import 'package:thrift/screens/ProductUpdateScreen.dart';
import 'package:thrift/screens/ProfileScreen.dart';
import 'package:thrift/screens/SellerReviewScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:badges/badges.dart';

class ItemModel {
  String title;

  ItemModel(this.title);
}

class SellerEditProfileScreen extends StatefulWidget {
  static String tag='/SellerEditProfileScreen';
  const SellerEditProfileScreen({Key? key}) : super(key: key);

  @override
  _SellerEditProfileScreenState createState() => _SellerEditProfileScreenState();
}

class _SellerEditProfileScreenState extends State<SellerEditProfileScreen> {
  late List<ItemModel> menuItems;
  CustomPopupMenuController _controller = CustomPopupMenuController();

  final double runSpacing = 4;
  final double spacing = 4;
  final columns = 2;
  // List<ProductListModel> productListModel = [];
  ProductListSellerModel? productListModel;
  ProfileModel? profileModel;
  String? seller_name,seller_id,profile_name;
  String? filter_str = 'Newest to Oldest';
  ReviewModel? reviewModel;
  String fnl_img = 'https://secure.gravatar.com/avatar/598b1f668254d0f7097133846aa32daf?s=96&d=mm&r=g';
  ViewProModel? viewProModel;

  int? cart_count;
  Future<String?> fetchtotal() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(prefs.getInt('cart_count')!=null){
        cart_count = prefs.getInt('cart_count');
      }else{
        cart_count = 0;
      }

      return '';
    } catch (e) {
      print('caught error $e');
    }
  }



  Future<ReviewModel?> fetchREview() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? seller_id = prefs.getString('UserId');
      // toast(cat_id);
print("https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/seller_reviews?seller_id=$seller_id");
      var response;
      response = await http.get(Uri.parse(
          "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/seller_reviews?seller_id=$seller_id"));
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      // for (Map i in jsonResponse) {
      //
      //     // reviewModel.add(ReviewModel.fromJson(i));
      reviewModel = new ReviewModel.fromJson(jsonResponse);
//       }


      return reviewModel;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }



  Future<ProductListSellerModel?> fetchAlbum() async {
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? user_country = prefs.getString('user_selected_country');
      seller_id = prefs.getString('seller_id');
      String? UserId= prefs.getString('UserId');
      // toast(cat_id);

      var response;
      if (filter_str == 'Newest to Oldest') {
        response = await http.get(Uri.parse(
            "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/seller_products?stock_status=instock&status=publish&orderby=date&order=desc&per_page=100&country=$user_country&seller_id=$UserId"));
      } else if (filter_str == 'Oldest to Newest') {
        response = await http.get(Uri.parse(
            "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/seller_products?stock_status=instock&status=publish&orderby=date&order=asc&per_page=100&country=$user_country&seller_id=$UserId"));
      } else if (filter_str == 'Price High to Low') {
        response = await http.get(Uri.parse(
            "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/seller_products?stock_status=instock&status=publish&orderby=price&order=desc&per_page=100&country=$user_country&seller_id=$UserId"));
      } else if (filter_str == 'Price Low to High') {
        response = await http.get(Uri.parse(
            "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/seller_products?stock_status=instock&status=publish&orderby=price&order=asc&per_page=100&country=$user_country&seller_id=$UserId"));
      }
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');

      // productListModel!.products!.clear();
      final jsonResponse = json.decode(response.body);
//       for (Map i in jsonResponse) {
//         productListModel.add(ProductListModel.fromJson(i));
      productListModel = new ProductListSellerModel.fromJson(jsonResponse);
//       }

      // if (productListModel.length > 0) {
      //   prefs.setString(
      //       "fnl_currency", productListModel[0].currency.toString());
      // }


      return productListModel;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }

  Future<ProfileModel?> fetchProfile() async {
//    Dialogs.showLoadingDialog(context, _keyLoader);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');


      // final msg = jsonEncode({"ID": UserId});

      // Response response = await post(
      //     'http://zoo.webstylze.com/wp-json/v3/viewprofile',
      //     headers: headers,
      //     body: msg);

      print('Token : ${token}');
      // final response = await http.get("https://encros.rcstaging.co.in/wp-json/wooapp/v3/profile",
      //   // headers: {HttpHeaders.authorizationHeader: "Basic $token"},
      //     headers: {
      //   'Content-Type': 'application/json',
      //   'Accept': 'application/json',
      //   'Authorization': 'Bearer $token',
      // }
      // );

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Response response = await get(
      //   'https://encros.rcstaging.co.in/wp-json/wooapp/v3/profile',
      //   headers: headers
      // );

      var response =await http.get(Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/profile"),
          headers: headers);


      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');

      profileModel = new ProfileModel.fromJson(jsonResponse);


      print('sucess');

      return profileModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<String?> ChangeReserve(String reserver,String pro_id) async {
    EasyLoading.show(status: 'Please wait...');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
//      print

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({"product_id": pro_id});
      print(msg);
      Response response;
      if(reserver=="Reserved") {
        response = await post(
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/mark_as_reserved'),
            headers: headers,
            body: msg);
      }else{
        response = await post(
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/mark_as_unreserved'),
            headers: headers,
            body: msg);
      }
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      setState(() {

      });

      // couponModel = new CouponModel.fromJson(jsonResponse);

      EasyLoading.dismiss();

      // } else {
      //   couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
      //   toast(couponErrorModel.error);
      // }
      return "couponModel";
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<String?> ChangeSold(String pro_id) async {
    EasyLoading.show(status: 'Please wait...');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
//      print

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({"product_id": pro_id});
      print(msg);
      Response response = await post(
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/mark_as_sold'),
            headers: headers,
            body: msg);

      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      EasyLoading.dismiss();
      setState(() {

      });

      // couponModel = new CouponModel.fromJson(jsonResponse);



      // } else {
      //   couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
      //   toast(couponErrorModel.error);
      // }
      return "couponModel";
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  Future<String?> fetchDelete(String pro_id) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? pro_id = prefs.getString('pro_id');
      toast(pro_id);
      print(
          "https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/$pro_id");
      var response = await http.delete(Uri.parse(
          'https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/$pro_id'));
      final jsonResponse = json.decode(response.body);
      print('not json prpr$jsonResponse');
      // pro_det_model = new ProductDetailModel.fromJson(jsonResponse);
      EasyLoading.dismiss();
      setState(() {

      });

      // if(pro_det_model.type=='variable'){
      //   fetchVariant();
      // }
      return "pro_det_model";
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  @override
  void initState() {
    menuItems = [
      ItemModel('Newest to Oldest'),
      ItemModel('Oldest to Newest'),
      ItemModel('Price High to Low'),
      ItemModel('Price Low to High'),
    ];
    super.initState();
  }

  Future<String?> fetchadd() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      seller_name = prefs.getString('seller_name');
      seller_id = prefs.getString('seller_id');
      profile_name=prefs.getString("profile_name");
      return '';
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<ViewProModel?> ViewProfilePic() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };


      final msg = jsonEncode({
        "customer_id": UserId,
      });
      print(msg);

      Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/v3/view_profile_picture'),
          headers: headers,
          body: msg);
      print('Response body: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      viewProModel = new ViewProModel.fromJson(jsonResponse);

      fnl_img = viewProModel!.profile_picture!;
      print(fnl_img);



      return viewProModel;
    } catch (e) {
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    BadgeCount(){
      if(cart_count==0){
        return Image.asset(
          sh_new_cart,
          height: 50,
          width: 50,
          fit: BoxFit.fill,
          color: sh_white,
        );
      }else{
        return Badge(
          position: BadgePosition.topEnd(top: 4, end: 6),
          badgeContent: Text(cart_count.toString(),style: TextStyle(color: sh_white),),
          child: Image.asset(
            sh_new_cart,
            height: 50,
            width: 50,
            fit: BoxFit.fill,
            color: sh_white,
          ),
        );
      }
    }

    Imagevw4(int index) {
      if (productListModel!.products![index]!.data!.images!.length < 1) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                sh_no_img,
                fit: BoxFit.cover,
                height: width * 0.28,


              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async{
                    SharedPreferences prefs =
                    await SharedPreferences
                        .getInstance();
                    prefs.setString(
                        'seller_pro_id',
                        productListModel!.products![index]!.data!.id
                            .toString());
                    // launchScreen(context, ProductUpdateScreen.tag);
                    Navigator.pushNamed(context, ProductUpdateScreen.tag).then((_) => setState(() {}));
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: boxDecoration(
                        bgColor: Colors.black.withOpacity(0.4), radius: 4, showShadow: true),
                    child: text("EDIT",
                        textColor: sh_white,
                        fontSize: 12.0,
                        isCentered: true,
                        fontFamily: 'Bold'),
                  ),
                ),
              ),
            )
          ],

        );
      } else {
        return
        Stack(
          children: [
            ClipRRect(
              borderRadius:
              BorderRadius.all(Radius.circular(spacing_middle)),
              child: Image.network(
                productListModel!.products![index]!.data!.images![0]!.src!,
                fit: BoxFit.fill,
                height: width * 0.28,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async{
                    SharedPreferences prefs =
                        await SharedPreferences
                        .getInstance();
                    prefs.setString(
                        'seller_pro_id',
                        productListModel!.products![index]!.data!.id
                            .toString());
                    // launchScreen(context, ProductUpdateScreen.tag);
                    Navigator.pushNamed(context, ProductUpdateScreen.tag).then((_) => setState(() {}));
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: boxDecoration(
                        bgColor: Colors.black.withOpacity(0.4), radius: 4, showShadow: true),
                    child: text("EDIT",
                        textColor: sh_white,
                        fontSize: 12.0,
                        isCentered: true,
                        fontFamily: 'Bold'),
                  ),
                ),
              ),
            )
          ],

        );
      }
    }

    NewImagevw(int index) {
      return Imagevw4(index);
    }

    MyPrice(int index){
      var myprice2,myprice;
      if(productListModel!.products![index]!.data!.price==''){
        myprice='0.00';
      }else {
        myprice2 = double.parse(productListModel!.products![index]!.data!.price!);
        myprice = myprice2.toStringAsFixed(2);
      }
      return Row(
        children: [
          Text(
            "\$" + myprice,
            style: TextStyle(
                color: sh_black,
                fontFamily: fontBold,
                fontSize: textSizeSMedium),
          ),

        ],
      );
    }


    void _openCustomDialogReserve(String reserver,String prod_id) {
      showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Center(child: Text('Mark this listing as $reserver?',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16,),
                      InkWell(
                        onTap: () async {
                          // BecameSeller();
                          Navigator.of(context, rootNavigator: true).pop();
                          ChangeReserve(reserver,prod_id);
                          // _openCustomDialog2();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*.7,
                          padding: EdgeInsets.only(
                              top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2, radius: 10, showShadow: true),
                          child: text("Confirm",
                              fontSize: 16.0,
                              textColor: sh_white,
                              isCentered: true,
                              fontFamily: 'Bold'),
                        ),
                      ),
                      SizedBox(height: 10,),
                      InkWell(
                        onTap: () async {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*.7,
                          padding: EdgeInsets.only(
                              top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_btn_color, radius: 10, showShadow: true),
                          child: text("Cancel",
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
            );
          },
          transitionDuration: Duration(milliseconds: 200),
          barrierDismissible: true,
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Container();
          });
    }

    void _openCustomDialogSold(String prod_id) {
      showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Center(child: Text('Mark this listing as sold?',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16,),
                      InkWell(
                        onTap: () async {
                          // BecameSeller();
                          Navigator.of(context, rootNavigator: true).pop();
                          ChangeSold(prod_id);
                          // _openCustomDialog2();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*.7,
                          padding: EdgeInsets.only(
                              top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2, radius: 10, showShadow: true),
                          child: text("Confirm",
                              fontSize: 16.0,
                              textColor: sh_white,
                              isCentered: true,
                              fontFamily: 'Bold'),
                        ),
                      ),
                      SizedBox(height: 10,),
                      InkWell(
                        onTap: () async {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*.7,
                          padding: EdgeInsets.only(
                              top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_btn_color, radius: 10, showShadow: true),
                          child: text("Cancel",
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
            );
          },
          transitionDuration: Duration(milliseconds: 200),
          barrierDismissible: true,
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Container();
          });
    }

    void _openCustomDialogDelete(String prod_id) {
      showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Center(child: Text('Do you want to delete this listing?',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16,),
                      InkWell(
                        onTap: () async {
                          // BecameSeller();
                          Navigator.of(context, rootNavigator: true).pop();
                          fetchDelete(prod_id);
                          // _openCustomDialog2();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*.7,
                          padding: EdgeInsets.only(
                              top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2, radius: 10, showShadow: true),
                          child: text("Confirm",
                              fontSize: 16.0,
                              textColor: sh_white,
                              isCentered: true,
                              fontFamily: 'Bold'),
                        ),
                      ),
                      SizedBox(height: 10,),
                      InkWell(
                        onTap: () async {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*.7,
                          padding: EdgeInsets.only(
                              top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_btn_color, radius: 10, showShadow: true),
                          child: text("Cancel",
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
            );
          },
          transitionDuration: Duration(milliseconds: 200),
          barrierDismissible: true,
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Container();
          });
    }

    CheckReserve(int index){
      if(productListModel!.products![index]!.data!.status=="publish"){
        return InkWell(
          onTap: () async {
            // BecameSeller();
            _openCustomDialogReserve("Reserved",productListModel!.products![index]!.data!.id.toString());
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: boxDecoration(
                bgColor: sh_btn_color, radius: 6, showShadow: true),
            child: text("Reserve",
                fontSize: 12.0,
                textColor: sh_colorPrimary2,
                isCentered: true,
                fontFamily: 'Bold'),
          ),
        );
      }else{
        return InkWell(
          onTap: () async {
            // BecameSeller();
            _openCustomDialogReserve("Unreserved",productListModel!.products![index]!.data!.id.toString());
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: boxDecoration(
                bgColor: sh_btn_color, radius: 6, showShadow: true),
            child: text("Unreserve",
                fontSize: 12.0,
                textColor: sh_colorPrimary2,
                isCentered: true,
                fontFamily: 'Bold'),
          ),
        );
      }
    }

    CheckSold(int index){
      if(productListModel!.products![index]!.data!.stockStatus=="instock"){
        return InkWell(
          onTap: () async {
            // BecameSeller();
            _openCustomDialogSold(productListModel!.products![index]!.data!.id.toString());
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: boxDecoration(
                bgColor: sh_btn_color, radius: 6, showShadow: true),
            child: text("Sold",
                fontSize: 12.0,
                textColor: sh_colorPrimary2,
                isCentered: true,
                fontFamily: 'Bold'),
          ),
        );
      }else{
        return InkWell(
          onTap: () async {
            // BecameSeller();
            // _openCustomDialogSold(productListModel[index].id.toString());
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: boxDecoration(
                bgColor: sh_colorPrimary2, radius: 6, showShadow: true),
            child: text("Sold",
                fontSize: 12.0,
                textColor: sh_white,
                isCentered: true,
                fontFamily: 'Bold'),
          ),
        );
      }
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "TheBuyerman2022",
          style:
          TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          GestureDetector(
            onTap: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt("shiping_index", -2);
              prefs.setInt("payment_index", -2);
              launchScreen(context, CartScreen.tag);
            },
            child: Image.asset(
              sh_new_cart,
              height: 50,
              width: 50,
              color: sh_white,
            ),
          ),
          SizedBox(
            width: 22,
          ),
        ],
      );
      double app_height = appBar.preferredSize.height;
      return Stack(children: <Widget>[
        // Background with gradient
        Container(
            height: 120,
            width: width,
            child: Image.asset(sh_upper2, fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Container(
          height: height,
          width: width,
          color: sh_white,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          child: Container(
            height: height,
            width: width,
            margin: EdgeInsets.fromLTRB(16,0,16,0),
            child: Column(
              children: [
                FutureBuilder<ViewProModel?>(
                  future: ViewProfilePic(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(spacing_standard_new),
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: spacing_standard,
                              margin: EdgeInsets.all(spacing_control),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // getImage();
                                  // _showPicker(context);
                                },
                                child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: fnl_img == null
                                        ? CircleAvatar(
                                      // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
                                        backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),

                                      radius: 55,
                                    )
                                        : CircleAvatar(
                                      backgroundImage: NetworkImage(fnl_img),
                                      radius: 55,
                                    )),
                              ),
                            ),
                          ),


                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(spacing_standard_new),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: spacing_standard,
                        margin: EdgeInsets.all(spacing_control),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircleAvatar(
                              // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
                              backgroundImage: NetworkImage(
                                  fnl_img),
                              radius: 55,
                            )),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                FutureBuilder<ProfileModel?>(
                    future: fetchProfile(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return     InkWell(
                          onTap: () {
                            launchScreen(context, ProfileScreen.tag);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profileModel!.data!.firstName!+" "+profileModel!.data!.lastName!,
                                style: TextStyle(
                                    color: sh_colorPrimary2,
                                    fontSize: 16,
                                    fontFamily: "Bold"),
                              ),
                              SizedBox(width: 8,),
                              Icon(Icons.edit,color: sh_colorPrimary2,size: 15,)
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
//                    return Text("${snapshot.error}");
                        return Center(
                            child: Container());
                      }
                      // By default, show a loading spinner.
                      return Center(child: CircularProgressIndicator());
                    }),

                SizedBox(
                  height: 16,
                ),
                FutureBuilder<ReviewModel?>(
                  future: fetchREview(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return InkWell(
onTap: () {
  launchScreen(context, SellerReviewScreen.tag);
},
                        child: Column(
                          children: [
                            Text(
                              "User Rating",
                              style: TextStyle(
                                  color: sh_colorPrimary2,
                                  fontSize: 14,
                                  fontFamily: "Bold"),
                            ),
                            RatingBar.builder(
                              initialRating: double.parse(reviewModel!.average.toString()),
                              minRating: 1,
                              itemSize: 18,
                              ignoreGestures: true,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              unratedColor: sh_rating_unrated,
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: sh_rating,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),


                SizedBox(
                  height: 26,
                ),
                Container(height: .5,color: sh_colorPrimary2,),
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Listing",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: "Bold"),),
                  ],
                ),
                SizedBox(height: 16,),
                CustomPopupMenu(
                  child: Row(
                    children: [
                      Container(

                        child: SvgPicture.asset(sh_menu_filter,color: sh_colorPrimary2,),
                        height :40,
                        width: 40,),
                      Text(filter_str!,style: TextStyle(color: sh_colorPrimary2,fontSize: 14),)
                    ],
                  ),
                  menuBuilder: () => ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      color: sh_btn_color,
                      child: IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: menuItems
                              .map(
                                (item) => GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                print("onTap");
                                _controller.hideMenu();
                                setState(() {
                                  toast("Please wait..");
                                  filter_str=item.title;
                                });
                              },
                              child: Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: <Widget>[

                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 10),
                                        padding:
                                        EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            color: sh_colorPrimary2,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  pressType: PressType.singleClick,
                  verticalMargin: -10,
                  controller: _controller,
                ),
                SizedBox(height: 16,),
                FutureBuilder<ProductListSellerModel?>(
                  future: fetchAlbum(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(

                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                              top: spacing_standard_new, bottom: spacing_standard_new),
                          itemBuilder: (item, index) {
                            return Container(
                              color: sh_white,
                              child: Column(
                                children: [
                                  SizedBox(height: 8,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(width: 8,),
                                      Expanded(
                                        flex: 3,
                                        child: NewImagevw(index),
                                      ),
                                      SizedBox(
                                        width: spacing_standard_new,
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              productListModel!.products![index]!.data!.name!,
                                              style: TextStyle(
                                                  color: sh_colorPrimary2,
                                                  fontSize: 16,
                                                  fontFamily: 'Bold'),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            MyPrice(index),
                                            // text(currency! + cat_model!.cart![positions]!.productPrice!,
                                            //     textColor: sh_app_black, fontFamily: 'Bold'),
                                            SizedBox(
                                              height: 9,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CheckReserve(index),

                                                CheckSold(index),
                                                InkWell(
                                                  onTap: () async {
                                                    // BecameSeller();
                                                    _openCustomDialogDelete(productListModel!.products![index]!.data!.id.toString());
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(4.0),
                                                    decoration: boxDecoration(
                                                        bgColor: sh_btn_color, radius: 6, showShadow: true),
                                                    child: text("Delete",
                                                        fontSize: 12.0,
                                                        textColor: sh_colorPrimary2,
                                                        isCentered: true,
                                                        fontFamily: 'Bold'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Container(height: 1,color: sh_view_color,)
                                ],
                              ),
                            );
                          },
                          shrinkWrap: true,
                          itemCount: productListModel!.products!.length,
                        ),
                      );



                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ),
        // Positioned to take only AppBar size
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0,spacing_middle4,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6.0,2,6,2),
                      child: IconButton(onPressed: () {
                        Navigator.pop(context);
                      }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 36,)),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: FutureBuilder<String?>(
                        future: fetchadd(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(profile_name!,style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Regular'));
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          // By default, show a loading spinner.
                          return CircularProgressIndicator(

                          );
                        },
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setInt("shiping_index", -2);
                        prefs.setInt("payment_index", -2);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CartScreen()),).then((value) {   setState(() {
                          // refresh state
                        });});
                      },
                      child: FutureBuilder<String?>(
                        future: fetchtotal(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return BadgeCount();
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          // By default, show a loading spinner.
                          return CircularProgressIndicator();
                        },
                      ),

                    ),
                    SizedBox(width: 16,)
                  ],
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: setUserForm(),
      ),
    );

  }
}
