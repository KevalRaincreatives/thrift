import 'dart:async';
import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/database/CartPro.dart';
import 'package:thrift/database/database_hepler.dart';
import 'package:thrift/model/CartModel.dart';
import 'package:thrift/model/CouponErrorModel.dart';
import 'package:thrift/model/CouponModel.dart';
import 'package:http/http.dart';
import 'package:thrift/screens/DefaultAddressScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/OfferListScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';

class CartScreen extends StatefulWidget {
  static String tag='/CartScreen';
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin{
  CartModel? cat_model;
  var result = "CABF";
  String? currency, currency_pos;
  TextEditingController _couponController = TextEditingController();
  CouponModel? couponModel;
  CouponErrorModel? couponErrorModel;
  final dbHelper = DatabaseHelper.instance;
  List<CartPro> cartPro = [];
  String? final_token;
  double fl_total = 50.0;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  bool _resized = false;
  double _height = 0.02;
  double _width = 28;
  String user_total='';
  double posx = 100.0;
  double posy = 100.0;

  Future<List<CartPro>> _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    cartPro.clear();
    allRows.forEach((row) => cartPro.add(CartPro.fromJson(row)));
    // _showMessageInScaffold('Query done.');
    print(cartPro.length.toString());

    fl_total = 0.0;
    for (var i = 0; i < cartPro.length; i++) {
      double fnlamnt = double.parse(cartPro[i].line_subtotal!) *
          double.parse(cartPro[i].quantity!);
      fl_total += fnlamnt;
    }

    return cartPro;
  }

  Future<String?> fetchToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      final_token = prefs.getString('token');
      currency = prefs.getString('currency');
      currency_pos = prefs.getString('currency_pos');
      if (final_token == null) {
        final_token = '';
      }

      return final_token;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<CartModel?> fetchAlbum() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      currency = prefs.getString('currency');
      currency_pos = prefs.getString('currency_pos');
      print(token);
      if (token != null && token != '') {
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

        Response response = await get(
            Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/woocart'),
            headers: headers);

        print('Response status2: ${response.statusCode}');
        print('Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        print('not json $jsonResponse');
        cat_model = new CartModel.fromJson(jsonResponse);

        user_total=cat_model!.total.toString();

        if (cat_model!.couponDiscountTotals!.length == 0) {
          prefs.setString("coupon_code", "");
          prefs.setString("coupon_amount", "");
        } else {
          prefs.setString("coupon_code", cat_model!.appliedCoupons![0]);
          prefs.setString("coupon_amount",
              cat_model!.couponDiscountTotals!.toString());
        }
      } else {
        _queryAll();
      }

//      print(cat_model.data);
      return cat_model;
    } catch (e) {
      print('caught error $e');
      // return cat_model;
    }
  }

  Future<CartModel?> RemoveCart(String pro_id, String var_id) async {
    // EasyLoading.show(status: 'Please wait...');
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

      final msg = jsonEncode({"product_id": pro_id, "variation_id": var_id});
      print(msg);

      Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/remove_cart_item'),
          headers: headers,
          body: msg);
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      setState(() {});
      // EasyLoading.dismiss();

//      print(cat_model.data);
      return cat_model;
    } catch (e) {
      print('caught error $e');
      // return cat_model;
    }
  }

  Future<CartModel?> UpdateCart(
      String pro_id, String qty, String st_status, String var_id) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
//      print
      int? quantity;
      if (st_status == 'ADD') {
        quantity = int.parse(qty) + 1;
      } else if (st_status == 'REMOVE') {
        quantity = int.parse(qty) - 1;
      }
      String? quantitys = quantity.toString();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // final msg = jsonEncode({"product_id": pro_id, "quantity": pro_id});
      // print(msg);
      Response response;
      if (quantity == 0) {
        final msg = jsonEncode({"product_id": pro_id, "variation_id": var_id});
        print(msg);

        response = await post(
            Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/remove_cart_item'),
            headers: headers,
            body: msg);
      } else {
        final msg = jsonEncode({
          "product_id": pro_id,
          "quantity": quantitys,
          "variation_id": var_id
        });
        print(msg);
        response = await post(
            Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/update_cart'),
            headers: headers,
            body: msg);
      }
      EasyLoading.dismiss();
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      setState(() {});
      EasyLoading.dismiss();

//      print(cat_model.data);
      return cat_model;
    } catch (e) {
      print('caught error $e');
      // return cat_model;
    }
  }

  Future<CouponModel?> getCoupon() async {
    EasyLoading.show(status: 'Please wait...');

    try {
      String username = _couponController.text;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
//      print

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({"coupon_code": username});
      print(msg);

      Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/apply_coupon'),
          headers: headers,
          body: msg);
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json coupon$jsonResponse');

      couponModel = new CouponModel.fromJson(jsonResponse);
      if (couponModel!.success!) {
        setState(() {});
      } else {
        couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
        toast(couponErrorModel!.error);
      }
      EasyLoading.dismiss();

      return couponModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<CouponModel?> removeCoupon() async {
    EasyLoading.show(status: 'Please wait...');

    try {
      String username = cat_model!.appliedCoupons![0];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
//      print

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({"coupon_code": username});
      print(msg);

      Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/remove_coupon'),
          headers: headers,
          body: msg);
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');

      // couponModel = new CouponModel.fromJson(jsonResponse);
      // if (couponModel.success) {
      setState(() {
        _couponController.text = '';
      });
      EasyLoading.dismiss();

      // } else {
      //   couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
      //   toast(couponErrorModel.error);
      // }
      return couponModel;
    } catch (e) {
      print('caught error $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    void _delete(id) async {
      // Assuming that the number of rows is the id for the last row.
      final rowsDeleted = await dbHelper.delete(id);
      setState(() {});
      // _showMessageInScaffold('deleted $rowsDeleted row(s): row $id');
    }

    void _update(id, pro_id, pro_name, product_img, variation_id, variation_name, variation_value,
        qty, line_subtotal, line_total, st_status) async {
      // row to update
      int? quantity;
      if (st_status == 'ADD') {
        quantity = int.parse(qty) + 1;
      } else if (st_status == 'REMOVE') {
        quantity = int.parse(qty) - 1;
      }
      String quantitys = quantity.toString();

      if (quantity == 0) {
        _delete(id);
      } else {
        double fnlamnt = double.parse(line_subtotal) * double.parse(qty);

        CartPro car = CartPro(id, pro_id, pro_name, product_img, variation_id,
            variation_name,variation_value, quantitys, line_subtotal, fnlamnt.toString());
        final rowsAffected = await dbHelper.update(car);
        setState(() {});
        // _showMessageInScaffold('updated $rowsAffected row(s)');
      }
    }

    Applycoupon() {
      if (cat_model!.couponDiscountTotals!.length == 0) {
        // do sth
        return Container(
          color: sh_white,
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text("Apply Coupons",
                  fontFamily: fontBold,
                  fontSize: textSizeSMedium,
                  textColor: sh_textColorPrimary),
              SizedBox(
                height: spacing_standard,
              ),
              Container(
                decoration: boxDecoration(
                    showShadow: true,
                    radius: 0,
                    bgColor: sh_light_gray),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(14.0),
                          isDense: true,
                          hintText: "Enter apply code",
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(2.0),
                              borderSide: BorderSide(
                                  color: sh_textColorSecondary,
                                  width: 0.4)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(2.0),topRight: Radius.circular(0.0),bottomLeft: Radius.circular(2.0),bottomRight: Radius.circular(0.0)),
                              borderSide: BorderSide(
                                  color: sh_textColorSecondary,
                                  width: 0.2)),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () async{
                            getCoupon();
                          },
                          child: Container(
                            padding:
                            EdgeInsets.fromLTRB(0, 10, 0, 10),
                            decoration: gradientBoxDecoration(
                                radius: 1,
                                gradientColor1: sh_colorPrimary,
                                gradientColor2: sh_colorPrimary),
                            child: Center(
                                child: text("Apply",
                                    fontFamily: fontBold,
                                    fontSize: textSizeSMedium,
                                    textColor: sh_white)),
                          ),
                        ))
                  ],
                ),
              ),
            ],
          ),
        );

      } else {
        return Container(
          margin: EdgeInsets.fromLTRB(spacing_control, spacing_standard_new,
              spacing_control, spacing_standard_new),
          child: DottedBorder(
            color: food_colorAccent,
            strokeWidth: 1,
            radius: Radius.circular(spacing_standard_new),
            child: ClipRRect(
              child: Container(
                  width: width,
                  padding: EdgeInsets.all(spacing_control),
                  color: Color(0xFFF6F7FB),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: text(
                          '${cat_model!.appliedCoupons![0]} - Applied Successfully',
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: ()async{
                              removeCoupon();
                            },
                            child: text(sh_lbl_remove,
                                textColor: food_colorAccent, isCentered: true),
                          ))
                    ],
                  )),
            ),
          ),
        );
      }
    }

    VariationName(int pos) {
      if (cat_model!.cart![pos]!.variationId.runtimeType == int) {
        return Container();
      } else if (cat_model!.cart![pos]!.variationId.runtimeType == String) {
        if (cat_model!.cart![pos]!.variationId != '') {
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: cat_model!.cart![pos]!.variations!.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                // onTap: () async{
                // SharedPreferences prefs = await SharedPreferences.getInstance();
                // prefs.setString('pro_id', latestModel.data[index].id);
                // launchScreen(context, ProductDetailScreen.tag);
                // },
                child: Container(
                  decoration: BoxDecoration(
                      color: pro_back,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          topLeft: Radius.circular(0))),
                  child: Wrap(
                    children: [Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          cat_model!.cart![pos]!.variations![index]!.attributeName!,
                          style: TextStyle(
                              color: sh_textColorPrimary, fontSize: 14, fontFamily: 'Medium'),
                        ),
                        Text(" : "),
                        Text(
                          cat_model!.cart![pos]!.variations![index]!.attributeValue!,
                          style: TextStyle(
                              color: sh_textColorPrimary, fontSize: 14, fontFamily: 'Medium'),
                        ),
                      ],
                    )],
                  ),
                ),
              );
            },
          );


        } else {
          return Container();
        }
      }
    }

    VariationNameGuest(int pos) {
      if (cartPro[pos].variation_name == '') {
        return Container();
      } else {
        final split_name = cartPro[pos].variation_name!.split(',');
        final Map<int, String> var_name = {
          for (int i = 0; i < split_name.length; i++)
            i: split_name[i]
        };

        final split_value = cartPro[pos].variation_value!.split(',');
        final Map<int, String> var_value = {
          for (int i = 0; i < split_value.length; i++)
            i: split_value[i]
        };
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: split_value.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              // onTap: () async{
              // SharedPreferences prefs = await SharedPreferences.getInstance();
              // prefs.setString('pro_id', latestModel.data[index].id);
              // launchScreen(context, ProductDetailScreen.tag);
              // },
              child: Container(
                decoration: BoxDecoration(
                    color: pro_back,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        topLeft: Radius.circular(0))),
                child: Wrap(
                  children: [Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        var_name[index]!,
                        style: TextStyle(
                            color: sh_textColorPrimary, fontSize: 14, fontFamily: 'Medium'),
                      ),
                      Text(" : "),
                      Text(
                        var_value[index]!,
                        style: TextStyle(
                            color: sh_textColorPrimary, fontSize: 14, fontFamily: 'Medium'),
                      ),
                    ],
                  )],
                ),
              ),
            );
          },
        );
      }
    }

    CartPrice(int pos) {
      var myprice2 =double.parse(cat_model!.cart![pos]!.productPrice!);
      var myprice = myprice2.toStringAsFixed(2);

      return text(currency! + myprice,
          textColor: sh_app_black, fontFamily: 'Bold');
    }


    Cart(CartModel models, int positions, animation, bool rsize) {
      // toast(positions.toString());
      if (rsize) {
        return Container(
          color: sh_white,
          // margin: EdgeInsets.only(bottom: spacing_standard_new),
          child: Column(
            children: [
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(width: 8,),
                  Expanded(
                    flex: 3,
                    child: AnimatedSize(
                      curve: Curves.bounceInOut,
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.all(Radius.circular(spacing_middle)),
                        child: Image.network(
                          cat_model!.cart![positions]!.productImage!,
                          fit: BoxFit.fill,
                          height: width * _height,
                        ),
                      ),
                      vsync: this,
                      duration: new Duration(seconds: 3),
                    ),
                  ),
                  SizedBox(
                    width: spacing_standard_new,
                  ),
                  Expanded(
                    flex: 6,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset(0, 0),
                      ).animate(animation),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            cat_model!.cart![positions]!.productName!,
                            style: TextStyle(
                                color: sh_black,
                                fontSize: 16,
                                fontFamily: 'Medium'),
                          ),
                          Container(child: VariationName(positions)),
                          SizedBox(
                            height: 4,
                          ),
                          CartPrice(positions),

                          SizedBox(
                            height: 9,
                          ),
                          Container(
                            height: width * 0.08,
                            alignment: Alignment.center,
                            width: width * 0.30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: width * 0.1,
                                  height: width * 0.09,
                                  decoration: BoxDecoration(
                                      color: pro_back,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0),
                                          topLeft: Radius.circular(0))),
                                  child: IconButton(
                                    icon: Icon(Icons.remove,
                                        color: sh_black, size: 16),
                                    onPressed: () async {
                                      setState(() {
                                        user_total='';
                                      });


                                      UpdateCart(
                                          cat_model!.cart![positions]!.productId!,
                                          cat_model!.cart![positions]!.quantity
                                              .toString(),
                                          "REMOVE",
                                          cat_model!.cart![positions]!.variationId!);
                                      if (cat_model!.cart![positions]!.quantity == 1) {
                                        if (positions > 0) {
                                          if (positions ==
                                              cat_model!.cart!.length - 1) {
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => Cart(cat_model!,
                                                    positions, animation, true),
                                                duration: const Duration(
                                                    milliseconds: 500));
                                          } else {
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => Cart(cat_model!,
                                                    positions, animation, true),
                                                duration: const Duration(
                                                    milliseconds: 500));
                                            cat_model!.cart!.removeAt(positions);
                                          }
                                        } else {
                                          cat_model!.cart!.removeAt(positions);

                                          listKey.currentState!.removeItem(
                                              positions,
                                                  (_, animation) => Cart(cat_model!,
                                                  positions, animation, true),
                                              duration: const Duration(
                                                  milliseconds: 500));
                                        }
                                      } else {
                                        UpdateCart(
                                            cat_model!.cart![positions]!.productId!,
                                            cat_model!.cart![positions]!.quantity
                                                .toString(),
                                            "REMOVE",
                                            cat_model!.cart![positions]!.variationId!);
                                      }
                                    },
                                  ),
                                ),
                                // text("$count"),
                                text(cat_model!.cart![positions]!.quantity.toString()),
                                Container(
                                  width: width * 0.1,
                                  height: width * 0.09,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: pro_back,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(0),
                                          topRight: Radius.circular(0))),
                                  child: IconButton(
                                    icon:
                                    Icon(Icons.add, color: sh_black, size: 16),
                                    onPressed: () async {
                                      //
                                      // listKey.currentState.removeItem(
                                      //     positions, (_, animation) => Cart(cat_model, positions, animation),
                                      //     duration: const Duration(milliseconds: 500));
                                      // cat_model.cart.removeAt(positions);

                                      UpdateCart(
                                          cat_model!.cart![positions]!.productId!,
                                          cat_model!.cart![positions]!.quantity
                                              .toString(),
                                          "ADD",
                                          cat_model!.cart![positions]!.variationId!);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(height: 1,color: sh_view_color,)
            ],
          ),
        );
      }
      else {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset(0, 0),
          ).animate(animation),
          child: Container(
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
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.all(Radius.circular(spacing_middle)),
                        child: Image.network(
                          cat_model!.cart![positions]!.productImage!,
                          fit: BoxFit.fill,
                          height: width * 0.28,
                        ),
                      ),
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
                            cat_model!.cart![positions]!.productName!,
                            style: TextStyle(
                                color: sh_black,
                                fontSize: 16,
                                fontFamily: 'Medium'),
                          ),
                          Container(child: VariationName(positions)),
                          SizedBox(
                            height: 4,
                          ),
                          CartPrice(positions),
                          // text(currency! + cat_model!.cart![positions]!.productPrice!,
                          //     textColor: sh_app_black, fontFamily: 'Bold'),
                          SizedBox(
                            height: 9,
                          ),
                          Container(
                            height: width * 0.08,
                            alignment: Alignment.center,
                            width: width * 0.30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: width * 0.1,
                                  height: width * 0.09,
                                  decoration: BoxDecoration(
                                      color: pro_back,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0),
                                          topLeft: Radius.circular(0))),
                                  child: IconButton(
                                    icon: Icon(Icons.remove,
                                        color: sh_black, size: 16),
                                    onPressed: () async {

                                      if (cat_model!.cart![positions]!.quantity == 1) {
                                        int pos=positions;
                                        UpdateCart(
                                            cat_model!.cart![pos]!.productId!,
                                            cat_model!.cart![pos]!.quantity
                                                .toString(),
                                            "REMOVE",
                                            cat_model!.cart![pos]!.variationId!);
                                        if (positions > 0) {
                                          if (positions ==
                                              cat_model!.cart!.length - 1) {
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => Cart(cat_model!,
                                                    positions, animation, true),
                                                duration: const Duration(
                                                    milliseconds: 100));
                                          } else {
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => Cart(cat_model!,
                                                    positions, animation, true),
                                                duration: const Duration(
                                                    milliseconds: 100));
                                            cat_model!.cart!.removeAt(positions);
                                          }
                                        } else {
                                          // cat_model.cart.removeAt(positions);
                                          if (cat_model!.cart!.length == 2) {
                                            cat_model!.cart!.removeAt(positions);
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) =>
                                                    Cart(cat_model!,
                                                        positions, animation, true),
                                                duration: const Duration(
                                                    milliseconds: 100));
                                          }else{
                                            cat_model!.cart!.removeAt(positions);
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) =>
                                                    Cart(cat_model!,
                                                        positions, animation, true),
                                                duration: const Duration(
                                                    milliseconds: 100));
                                          }
                                        }


                                      } else {
                                        UpdateCart(
                                            cat_model!.cart![positions]!.productId!,
                                            cat_model!.cart![positions]!.quantity
                                                .toString(),
                                            "REMOVE",
                                            cat_model!.cart![positions]!.variationId!);
                                      }
                                    },
                                  ),
                                ),
                                // text("$count"),
                                text(cat_model!.cart![positions]!.quantity.toString()),
                                Container(
                                  width: width * 0.1,
                                  height: width * 0.09,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: pro_back,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(0),
                                          topRight: Radius.circular(0))),
                                  child: IconButton(
                                    icon:
                                    Icon(Icons.add, color: sh_black, size: 16),
                                    onPressed: () async {
                                      //
                                      // listKey.currentState.removeItem(
                                      //     positions, (_, animation) => Cart(cat_model, positions, animation),
                                      //     duration: const Duration(milliseconds: 500));
                                      // cat_model.cart.removeAt(positions);

                                      UpdateCart(
                                          cat_model!.cart![positions]!.productId!,
                                          cat_model!.cart![positions]!.quantity
                                              .toString(),
                                          "ADD",
                                          cat_model!.cart![positions]!.variationId!);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Container(height: 1,color: sh_view_color,)
              ],
            ),
          ),
        );
      }
    }

    SubCPrice(int positions){
      var myprice2 =double.parse(cartPro[positions].line_subtotal!);
      var myprice = myprice2.toStringAsFixed(2);

      return text(currency! + myprice,
          textColor: sh_app_black, fontFamily: 'Bold');}

    CartGuest(CartPro models, int positions, animation, bool rsize) {
      if (rsize) {
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
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.all(Radius.circular(spacing_middle)),
                      child: Image.network(
                        cartPro[positions].product_img!,
                        fit: BoxFit.fill,
                        height: width * _height,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: spacing_standard_new,
                  ),
                  Expanded(
                    flex: 6,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset(0, 0),
                      ).animate(animation),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            cartPro[positions].product_name!,
                            style: TextStyle(
                                color: sh_black,
                                fontSize: 16,
                                fontFamily: 'Medium'),
                          ),
                          VariationNameGuest(positions),
                          SizedBox(
                            height: 4,
                          ),
                          SubCPrice(positions),

                          SizedBox(
                            height: 9,
                          ),
                          Container(
                            height: width * 0.08,
                            alignment: Alignment.center,
                            width: width * 0.30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: width * 0.1,
                                  height: width * 0.09,
                                  decoration: BoxDecoration(
                                      color: pro_back,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0),
                                          topLeft: Radius.circular(0))),
                                  child: IconButton(
                                    icon: Icon(Icons.remove,
                                        color: sh_black, size: 16),
                                    onPressed: () async {
                                      if (cartPro[positions].quantity == '1') {
                                        if (positions > 0) {
                                          if (positions ==
                                              cartPro.length - 1) {
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => CartGuest(
                                                    cartPro[positions],
                                                    positions,
                                                    animation,
                                                    true),
                                                duration: const Duration(
                                                    milliseconds: 300));
                                          } else {
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => CartGuest(
                                                    cartPro[positions],
                                                    positions,
                                                    animation,
                                                    true),
                                                duration: const Duration(
                                                    milliseconds: 300));
                                            cartPro.removeAt(positions);
                                          }
                                        } else {
                                          // cartPro.removeAt(positions);

                                          if(cartPro.length==2){

                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => CartGuest(
                                                    cartPro[positions],
                                                    positions,
                                                    animation,
                                                    true),
                                                duration: const Duration(
                                                    milliseconds: 300));

                                          }else{
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => CartGuest(
                                                    cartPro[positions],
                                                    positions,
                                                    animation,
                                                    true),
                                                duration: const Duration(
                                                    milliseconds: 300));
                                          }

                                        }





                                      } else {
                                        _update(
                                            cartPro[positions].id,
                                            cartPro[positions].product_id,
                                            cartPro[positions].product_name,
                                            cartPro[positions].product_img,
                                            cartPro[positions].variation_id,
                                            cartPro[positions].variation_name,
                                            cartPro[positions].variation_value,
                                            cartPro[positions].quantity,
                                            cartPro[positions].line_subtotal,
                                            cartPro[positions].line_total,
                                            "REMOVE");
                                      }
                                    },
                                  ),
                                ),
                                // text("$count"),
                                text(cartPro[positions].quantity.toString()),
                                Container(
                                  width: width * 0.1,
                                  height: width * 0.09,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: pro_back,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(0),
                                          topRight: Radius.circular(0))),
                                  child: IconButton(
                                    icon:
                                    Icon(Icons.add, color: sh_black, size: 16),
                                    onPressed: () async {
                                      _update(
                                          cartPro[positions].id,
                                          cartPro[positions].product_id,
                                          cartPro[positions].product_name,
                                          cartPro[positions].product_img,
                                          cartPro[positions].variation_id,
                                          cartPro[positions].variation_name,
                                          cartPro[positions].variation_value,
                                          cartPro[positions].quantity,
                                          cartPro[positions].line_subtotal,
                                          cartPro[positions].line_total,
                                          "ADD");
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(height: 1,color: sh_view_color,)
            ],
          ),
        );
      } else {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset(0, 0),
          ).animate(animation),
          child: Container(
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
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.all(Radius.circular(spacing_middle)),
                        child: Image.network(
                          cartPro[positions].product_img!,
                          fit: BoxFit.fill,
                          height: width * 0.28,
                        ),
                      ),
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
                            cartPro[positions].product_name!,
                            style: TextStyle(
                                color: sh_black,
                                fontSize: 16,
                                fontFamily: 'Medium'),
                          ),
                          VariationNameGuest(positions),
                          SizedBox(
                            height: 4,
                          ),
                          SubCPrice(positions),
                          // text(currency! + cartPro[positions].line_subtotal!,
                          //     textColor: sh_app_black, fontFamily: 'Bold'),
                          SizedBox(
                            height: 9,
                          ),
                          Container(
                            height: width * 0.08,
                            alignment: Alignment.center,
                            width: width * 0.30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: width * 0.1,
                                  height: width * 0.09,
                                  decoration: BoxDecoration(
                                      color: pro_back,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0),
                                          topLeft: Radius.circular(0))),
                                  child: IconButton(
                                    icon: Icon(Icons.remove,
                                        color: sh_black, size: 16),
                                    onPressed: () async {
                                      if (cartPro[positions].quantity == '1') {
                                        int pos=positions;


                                        if (positions > 0) {
                                          if (positions ==
                                              cartPro.length - 1) {
                                            // cartPro.removeAt(positions);
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => CartGuest(
                                                    cartPro[positions],
                                                    positions,
                                                    animation,
                                                    true),
                                                duration: const Duration(
                                                    milliseconds: 100));
                                          } else {
                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => CartGuest(
                                                    cartPro[positions],
                                                    positions,
                                                    animation,
                                                    true),
                                                duration: const Duration(
                                                    milliseconds: 100));
                                            // cartPro.removeAt(positions);
                                          }
                                        } else {

                                          if(cartPro.length==2){
                                            // cartPro.removeAt(positions);
                                            // final item = cartPro.removeAt(positions);
                                            // cartPro.removeAt(positions);

                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => CartGuest(
                                                    cartPro[positions],
                                                    positions,
                                                    animation,
                                                    true),
                                                duration: const Duration(
                                                    milliseconds: 100));

                                          }else{

                                            listKey.currentState!.removeItem(
                                                positions,
                                                    (_, animation) => CartGuest(
                                                    cartPro[positions],
                                                    positions,
                                                    animation,
                                                    true),
                                                duration: const Duration(
                                                    milliseconds: 200));
                                          }
                                        }





                                        Timer(
                                            Duration(milliseconds: 100),
                                                () =>
                                                _update(
                                                    cartPro[pos].id,
                                                    cartPro[pos].product_id,
                                                    cartPro[pos].product_name,
                                                    cartPro[pos].product_img,
                                                    cartPro[pos].variation_id,
                                                    cartPro[pos].variation_name,
                                                    cartPro[pos].variation_value,
                                                    cartPro[pos].quantity,
                                                    cartPro[pos].line_subtotal,
                                                    cartPro[pos].line_total,
                                                    "REMOVE"));


                                      } else {
                                        _update(
                                            cartPro[positions].id,
                                            cartPro[positions].product_id,
                                            cartPro[positions].product_name,
                                            cartPro[positions].product_img,
                                            cartPro[positions].variation_id,
                                            cartPro[positions].variation_name,
                                            cartPro[positions].variation_value,
                                            cartPro[positions].quantity,
                                            cartPro[positions].line_subtotal,
                                            cartPro[positions].line_total,
                                            "REMOVE");
                                      }
                                    },
                                  ),
                                ),
                                // text("$count"),
                                text(cartPro[positions].quantity.toString()),
                                Container(
                                  width: width * 0.1,
                                  height: width * 0.09,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: pro_back,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(0),
                                          topRight: Radius.circular(0))),
                                  child: IconButton(
                                    icon:
                                    Icon(Icons.add, color: sh_black, size: 16),
                                    onPressed: () async {
                                      _update(
                                          cartPro[positions].id,
                                          cartPro[positions].product_id,
                                          cartPro[positions].product_name,
                                          cartPro[positions].product_img,
                                          cartPro[positions].variation_id,
                                          cartPro[positions].variation_name,
                                          cartPro[positions].variation_value,
                                          cartPro[positions].quantity,
                                          cartPro[positions].line_subtotal,
                                          cartPro[positions].line_total,
                                          "ADD");
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Container(height: 1,color: sh_view_color,)
              ],
            ),
          ),
        );
      }
    }

    CouponDiscount() {
      if (cat_model!.couponDiscountTotals!.length == 0) {
        // do sth
        return                                     Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            text(sh_coupon_desc,
                fontSize: textSizeSMedium,
                fontFamily: fontBold,
                textColor: sh_textColorPrimary),
            text("Not Applied!",
                fontSize: textSizeSMedium,
                fontFamily: fontBold,
                textColor: sh_textColorPrimary),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            text(sh_coupon_desc,
                fontSize: textSizeSMedium,
                fontFamily: fontBold,
                textColor: sh_textColorPrimary),
            text(currency! +
                cat_model!.couponDiscountTotals![0]!.coupon_price.toString(),
                fontSize: textSizeSMedium,
                fontFamily: fontBold,
                textColor: sh_textColorPrimary),
          ],
        );
      }
    }

    CheckoutStatus(context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? final_token = prefs.getString('token');
      // SendAppData();



      if (final_token != null && final_token != '') {
        var myprice2 =double.parse(cat_model!.total.toString());
        var myprice = myprice2.toStringAsFixed(2);
        prefs.setString("total_amnt", myprice);

        launchScreen(context, DefaultAddressScreen.tag);
        // launchScreen(context, DefaultNewAddressScreen.tag);
      } else {
        launchScreen(context, LoginScreen.tag);
      }
    }

    SubPrice(){
      var myprice2 =double.parse(cat_model!.subTotal.toString());
      var myprice = myprice2.toStringAsFixed(2);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          text(sh_lbl_sub_total,
              fontSize: textSizeSMedium,
              fontFamily: fontBold,
              textColor: sh_textColorPrimary),
          text(currency! + myprice,
              fontSize: textSizeSMedium,
              fontFamily: fontBold,
              textColor: sh_textColorPrimary),
        ],
      );}

    TotalPrice(){
      var myprice2 =double.parse(cat_model!.total.toString());
      var myprice = myprice2.toStringAsFixed(2);
      return                                     Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          text("Total Payable",
              fontSize: textSizeMedium,
              fontFamily: fontBold,
              textColor: sh_black),
          text(currency! + myprice,
              fontSize: textSizeMedium,
              fontFamily: fontBold,
              textColor: sh_black),
        ],
      );
    }


    ListValidation() {
      if (cat_model!.cart== null) {
        return Container(
          alignment: Alignment.center,
          child: Text(
            'Cart is Empty',
            style: TextStyle(
                fontSize: 16, color: sh_textColorPrimary, fontWeight: FontWeight.bold),
          ),
        );
      }else if (cat_model!.cart!.length == 0) {
        return Container(
          alignment: Alignment.center,
          child: Text(
            'Cart is Empty',
            style: TextStyle(
                fontSize: 16, color: sh_textColorPrimary, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        return Container(
          height: height,
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 70.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              left: spacing_standard_new,
                              right: spacing_standard_new,
                              top: spacing_control),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              SizedBox(
                                height: 8,
                              ),
                              // ListView.builder(
                              //     scrollDirection: Axis.vertical,
                              //     itemCount: cat_model.cart.length,
                              //     shrinkWrap: true,
                              //     physics:
                              //     NeverScrollableScrollPhysics(),
                              //     itemBuilder: (context, index) {
                              //       return Cart(cat_model, index);
                              //     }),
                              AnimatedList(
                                key: listKey,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                initialItemCount: cat_model!.cart!.length,
                                itemBuilder: (context, index, animation) {
                                  return Cart(cat_model!, index, animation,
                                      false); // Refer step 3
                                },
                              ),
                              // ListView.builder(
                              //     scrollDirection: Axis.vertical,
                              //     itemCount: mList2.length,
                              //     shrinkWrap: true,
                              //     physics: NeverScrollableScrollPhysics(),
                              //     itemBuilder: (context, index) {
                              //       return Cart(mList2[index], index);
                              //     }),
                              Container(
                                height: 0.5,
                                color: sh_view_color,
                                width: width,
                                margin: EdgeInsets.only(
                                    bottom: spacing_standard_new),
                              ),
                              Applycoupon(),

                              Center(
                                child: InkWell(
                                  onTap: () async{
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           OfferListScreen()),
                                    // );
                                    var myprice2 =double.parse(cat_model!.total.toString());
                                    var myprice = myprice2.toStringAsFixed(2);
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString('my_tot', myprice);

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OfferListScreen(
                                              cat_title: 0,
                                            ))).then((value) {
                                      setState(() {

                                      });
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "View Offers  >",
                                      style: TextStyle(
                                          color: sh_colorPrimary,
                                          fontFamily: fontBold,
                                          fontSize: textSizeLargeMedium),
                                    ),
                                  ),
                                ),
                              ),
                              // NewDotted(),
                              SizedBox(
                                height: spacing_standard,
                              ),
                              SizedBox(
                                height: spacing_standard,
                              ),
                              Container(
                                color: sh_white,
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Price Details",
                                      style: TextStyle(
                                          color: sh_textColorPrimary,
                                          fontFamily: fontBold,
                                          fontSize: textSizeLargeMedium),
                                    ),
                                    SizedBox(
                                      height: spacing_control,
                                    ),
                                    SubPrice(),

                                    SizedBox(
                                      height: spacing_control,
                                    ),
                                    CouponDiscount(),
                                    SizedBox(
                                      height: spacing_control,
                                    ),
                                    TotalPrice(),

                                  ],
                                ),
                              ),

                              SizedBox(
                                height: spacing_middle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                    color: sh_white,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: sh_shadow_color,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 3))
                      ], color: sh_white),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          Expanded(
                            child: Center(
                                child: CartFinalTotal()


                            ),
                          ),

                          Expanded(
                            child: InkWell(
                              onTap: () async{
                                CheckoutStatus(context);
                              },
                              child: Container(
                                child: text(sh_lbl_continue,
                                    textColor: sh_white,
                                    fontSize: textSizeLargeMedium,
                                    fontFamily: fontMedium),
                                color: sh_colorPrimary,
                                alignment: Alignment.center,
                                height: double.infinity,
                              ),
                            ),
                          )
                        ],
                      ),
                    )

                  // mBottom(
                  //     context,
                  //     food_color_blue_gradient1,
                  //     food_color_blue_gradient2,
                  //     sh_lbl_checkout,
                  //     currency + cat_model.total.toString(),
                  //     DashboardScreen.tag),
                ),
              )
            ],
          ),
        );
      }
    }

    SubCartPrice(){
      var myprice2 =double.parse(fl_total.toString());
      var myprice = myprice2.toStringAsFixed(2);

      return     Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          text(sh_lbl_sub_total,
              fontSize: textSizeSMedium,
              fontFamily: fontBold,
              textColor: sh_textColorSecondary),
          text(currency! + myprice,
              fontSize: textSizeSMedium,
              fontFamily: fontBold,
              textColor: sh_textColorSecondary),
        ],
      );}

    TotalCartPrice(){
      var myprice2 =double.parse(fl_total.toString());
      var myprice = myprice2.toStringAsFixed(2);
      return                                                                         Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          text("Total Payable",
              fontSize: textSizeMedium,
              fontFamily: fontBold,
              textColor: sh_textColorSecondary),
          text(currency! + myprice,
              fontSize: textSizeMedium,
              fontFamily: fontBold,
              textColor: sh_textColorSecondary),
        ],
      );
    }

    ListValidationGuest() {


      if (cartPro.length == 0) {
        return Container(
          alignment: Alignment.center,
          child: Text(
            'Cart is Empty',
            style: TextStyle(
                fontSize: 16, color: sh_textColorPrimary, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        return Container(
          height: height,
          child: Column(
            children: [
              Expanded(
                flex: 14,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 70.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              left: spacing_standard_new,
                              right: spacing_standard_new,
                              top: spacing_control),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              SizedBox(
                                height: 10,
                              ),
                              AnimatedList(
                                key: listKey,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                initialItemCount: cartPro.length,
                                itemBuilder: (context, index, animation) {
                                  return CartGuest(cartPro[index], index,
                                      animation, false); // Refer step 3
                                },
                              ),
                              // ListView.builder(
                              //     scrollDirection: Axis.vertical,
                              //     itemCount: cartPro.length,
                              //     shrinkWrap: true,
                              //     physics:
                              //     NeverScrollableScrollPhysics(),
                              //     itemBuilder: (context, index) {
                              //       return CartGuest(cartPro[index], index);
                              //     }),
                              Container(
                                height: 0.5,
                                color: sh_view_color,
                                width: width,
                                margin: EdgeInsets.only(
                                    bottom: spacing_standard_new),
                              ),
                              // Applycoupon(),
                              // // NewDotted(),
                              // SizedBox(
                              //   height: spacing_standard,
                              // ),
                              Container(
                                color: sh_white,
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Price Details",
                                      style: TextStyle(
                                          color: sh_textColorSecondary,
                                          fontFamily: fontBold,
                                          fontSize: textSizeLargeMedium),
                                    ),
                                    SizedBox(
                                      height: spacing_control,
                                    ),
                                    SubCartPrice(),

                                    SizedBox(
                                      height: spacing_control,
                                    ),

                                    TotalCartPrice(),

                                  ],
                                ),
                              ),

                              SizedBox(
                                height: spacing_middle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                    color: sh_white,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: sh_shadow_color,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 3))
                      ], color: sh_white),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Center(
                                child: FinalTotal()
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async{
                                CheckoutStatus(context);
                              },
                              child: Container(
                                child: text(sh_lbl_continue,
                                    textColor: sh_white,
                                    fontSize: textSizeLargeMedium,
                                    fontFamily: fontMedium),
                                color: sh_colorPrimary,
                                alignment: Alignment.center,
                                height: double.infinity,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  // mBottom(
                  //     context,
                  //     food_color_blue_gradient1,
                  //     food_color_blue_gradient2,
                  //     sh_lbl_checkout,
                  //     currency + fl_total.toString(),
                  //     DashboardScreen.tag),
                ),
              )
            ],
          ),
        );
      }
    }

    CheckToken() {
      if (final_token != null && final_token != '') {
        return FutureBuilder<CartModel?>(
            future: fetchAlbum(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListValidation();
              } else if (snapshot.hasError) {
//                    return Text("${snapshot.error}");
                return Center(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Cart is empty!',
                        style: TextStyle(
                            fontSize: 16,
                            color: sh_textColorPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                    ));
              }
              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            });
      } else {
        return FutureBuilder<List<CartPro>>(
            future: _queryAll(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListValidationGuest();
              } else if (snapshot.hasError) {
//                    return Text("${snapshot.error}");
                return Center(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Cart is empty!',
                        style: TextStyle(
                            fontSize: 16,
                            color: sh_textColorPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                    ));
              }
              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            });
      }
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "My Cart",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),

      );
      double app_height = appBar.preferredSize.height;
      return Stack(children: <Widget>[
        // Background with gradient
        Container(
            height: 120,
            width: width,
            child: Image.asset(sh_upper2,fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Container(
          height: height,
          width: width,
          color: sh_white,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          child:   Container(
              width: width,
              height: height,
              child: FutureBuilder<String?>(
                  future: fetchToken(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Stack(
                        alignment: Alignment.bottomLeft,
                        children: <Widget>[CheckToken()],
                      );
                    }
                    // By default, show a loading spinner.
                    return Center(child: CircularProgressIndicator());
                  })),
        ),
        // Positioned to take only AppBar size
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: appBar,
        ),

      ]);
    }

return Scaffold(
  resizeToAvoidBottomInset: false,

  body: SafeArea(child: setUserForm()),
);
  }
  @override
  void screenUpdate() {
    setState(() {});
  }

  FinalTotal(){
    var myprice2 =double.parse(fl_total.toString());
    var myprice = myprice2.toStringAsFixed(2);

    return text("Total: "+currency! + myprice,
        textColor: sh_app_black,
        fontFamily: 'Bold',
        fontSize: textSizeLargeMedium);
  }

  CartFinalTotal() {
    var myprice2 =double.parse(cat_model!.total.toString());
    var myprice = myprice2.toStringAsFixed(2);
    return text("Total: "+currency! + myprice,
        textColor: sh_app_black,
        fontFamily: 'Bold',
        fontSize: textSizeLargeMedium);
  }
}

BoxDecoration gradientBoxDecoration(
    {double radius = spacing_middle,
      Color color = Colors.transparent,
      Color gradientColor2 = sh_white,
      Color gradientColor1 = sh_white,
      var showShadow = false}) {
  return BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [gradientColor1, gradientColor2]),
    boxShadow: showShadow
        ? [BoxShadow(color: sh_shadow_color, blurRadius: 10, spreadRadius: 2)]
        : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

class groceryButton extends StatefulWidget {
  static String tag = '/dpButton';
  var textContent;
  VoidCallback? onPressed;
  var isStroked = false;
  var height = 50.0;
  var radius = 5.0;
  var bgColors = sh_colorPrimary;

  groceryButton(
      {@required this.textContent,
        @required this.onPressed,
        this.isStroked = false,
        this.height = 50.0,
        this.radius = 5.0,
        this.bgColors = sh_colorPrimary});

  @override
  groceryButtonState createState() => groceryButtonState();
}

class groceryButtonState extends State<groceryButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
        alignment: Alignment.center,
        child: text(widget.textContent,
            textColor: widget.isStroked ? sh_colorPrimary : sh_white,
            fontSize: textSizeLargeMedium,
            isCentered: true,
            fontFamily: fontSemibold),
        decoration: widget.isStroked
            ? boxDecoration(bgColor: Colors.transparent, color: sh_colorPrimary)
            : boxDecoration(bgColor: widget.bgColors, radius: widget.radius),
      ),
    );
  }
}

