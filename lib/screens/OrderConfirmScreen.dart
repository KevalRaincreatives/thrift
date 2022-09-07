import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/CartModel.dart';
import 'package:thrift/model/OrderProductModel.dart';
import 'package:thrift/model/OrderSuccessModel.dart';
import 'package:thrift/model/ShAddress.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/screens/CheckOut.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';

class OrderConfirmScreen extends StatefulWidget {
  static String tag='/OrderConfirmScreen';
  const OrderConfirmScreen({Key? key}) : super(key: key);

  @override
  _OrderConfirmScreenState createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  bool agree = false;
  var currentIndex = 0;
  Timer? timer;
  var isLoaded = false;
  Future<CartModel>? futureAlbum;
  CartModel? cat_model;
  OrderSuccessModel? orderSuccessModel;
  var result = "CABF";
  String? currency,
      currency_pos,
      shipping_charge,
      total_amount,
      payment_method,
      shipment_method,
      shipment_title;

  String? firstname, lastname, address1, city, postcode, country_id, state;
  final List<OrderProductModel> itemsModel = [];
  final ScrollController _homeController = ScrollController();
  OrderProductModel? itModel;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchData();

  }

  Future<String?> AddPushData(int order_id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      total_amount = prefs.getString('total_amnt');
      payment_method = prefs.getString('payment_method');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };


      var response = await http.get(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/order_status_push_notification?payment_method=cod&order_id=$order_id'),headers: headers
      );

      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);




      return null;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }

  // void setError(dynamic error) {
  //   _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(error.toString())));
  //   setState(() {
  //     _error = error.toString();
  //   });
  // }

  fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String?  publish_key = prefs.getString('publish_key');
    String?  testmode = prefs.getString('testmode');
    if(prefs.getString('testmode')=='True'){
      testmode='test';
    }else{
      testmode='live';
    }
    // StripePayment.setOptions(
    //     StripeOptions(publishableKey: publish_key, merchantId: "Test", androidPayMode: testmode));
    // var banner = await loadBanners();
    setState(() {
      // list.clear();
      // list.addAll(products);
    });
  }


  Future<String?> fetchcurrency() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = prefs.getString('currency');
      currency_pos = prefs.getString('currency_pos');
      return '';
    } catch (e) {
      print('Caught error $e');
    }
  }

  Future<String?> fetchadd() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      firstname = prefs.getString('firstname');
      lastname = prefs.getString('lastname');
      address1 = prefs.getString('address1');
      city = prefs.getString('city');
      postcode = prefs.getString('postcode');
      country_id = prefs.getString('country_id');
      state = prefs.getString('zone_id');
      return '';
    } catch (e) {
      print('Caught error $e');
    }
  }

  Future<CartModel?> fetchCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      currency = prefs.getString('currency');
      currency_pos = prefs.getString('currency_pos');
      shipping_charge = prefs.getString('shipping_charge');
      total_amount = prefs.getString('total_amnt');
      payment_method = prefs.getString('payment_method');
      shipment_method = prefs.getString('shipment_method');
      shipment_title = prefs.getString('shipment_title');

      print(token);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Response response = await get(
      //     'https://encros.rcstaging.co.in/wp-json/wooapp/v3/woocart',
      //     headers: headers);

      var response = await http.get(Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/woocart'),headers: headers);

      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      cat_model = new CartModel.fromJson(jsonResponse);

      itemsModel.clear();

      for (int i = 0; i < cat_model!.cart!.length; i++) {
        if (cat_model!.cart![i]!.variationId.runtimeType == int) {
          itModel = OrderProductModel(
              pro_id: cat_model!.cart![i]!.productId.toString(),
              variation_id: '',
              quantity: cat_model!.cart![i]!.quantity.toString());
          itemsModel.add(itModel!);
        } else if (cat_model!.cart![i]!.variationId.runtimeType == String) {
          if (cat_model!.cart![i]!.variationId != '') {
            itModel = OrderProductModel(
                pro_id: cat_model!.cart![i]!.productId.toString(),
                variation_id: cat_model!.cart![i]!.variationId.toString(),
                quantity: cat_model!.cart![i]!.quantity.toString());
            itemsModel.add(itModel!);
          } else {
            itModel = OrderProductModel(
                pro_id: cat_model!.cart![i]!.productId.toString(),
                variation_id: '',
                quantity: cat_model!.cart![i]!.quantity.toString());
            itemsModel.add(itModel!);
          }
        }

        // itModel = OrderProductModel(
        //     pro_id: cat_model.cart[i].productId.toString(),
        //     quantity: cat_model.cart[i].quantity.toString());
          // itemsModel.add(itModel);
      }

//      print(cat_model.data);
      return cat_model;
    } catch (e) {
      print('caught error $e');
      // return cat_model;
    }
  }

  Future<String?> Checkorder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      String? coupon_amount= prefs.getString('coupon_amount');
      String? coupon_code= prefs.getString('coupon_code');
      String? payment_type= prefs.getString('payment_type');


      print(token);

      if(payment_type=='PayPal') {
        // launchScreen(context, AddCardScreen.tag);
        print("papypal");
      }else if(payment_type=='Credit Card (Stripe)'){

        // makePayment();

      }else{
        print("cash");
        CreateOrder();
      }
      return '';
    } catch (e) {
      print('Caught error $e');
    }
  }

  Future<OrderSuccessModel?> CreateOrder() async {


    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      String? coupon_amount= prefs.getString('coupon_amount');
      String? coupon_code= prefs.getString('coupon_code');
      String? payment_type= prefs.getString('payment_type');


      print(token);



      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // final msg = jsonEncode
      //   "product_id": pro_id,
      //   "variation_id":var_id
      // });
      // Map msg = {
      //   "customer_note": "",
      //   "product_data": itemsModel,
      //   "payment_method": payment_method,
      //   "shipping_method": shipment_title,
      //   "shipping_method_title": shipment_method,
      //   "shipping_charge": shipping_charge,
      //   "coupon_code": coupon_code,
      //   "coupon_amount": coupon_amount,
      //   "shipping_first_name": firstname,
      //   "shipping_last_name": lastname,
      //   "shipping_address_1": address1,
      //   "shipping_city": city,
      //   "shipping_state": state,
      //   "shipping_postcode": postcode,
      //   "shipping_country": country_id
      // };
      //
      // String body = json.encode(msg);
      // print(body);


      var body = json.encode({
        "customer_note": "",
        "product_data": itemsModel,
        "payment_method": payment_method,
        "shipping_method": shipment_title,
        "shipping_method_title": shipment_method,
        "shipping_charge": shipping_charge,
        "coupon_code": coupon_code,
        "coupon_amount": coupon_amount,
        "shipping_first_name": firstname,
        "shipping_last_name": lastname,
        "shipping_address_1": address1,
        "shipping_city": city,
        "shipping_state": state,
        "shipping_postcode": postcode,
        "shipping_country": country_id
      });

      print(body);

      // Response response = await post(
      //     'https://encros.rcstaging.co.in/wp-json/wooapp/v3/create_order',
      //     headers: headers,
      //     body: body);

      var response = await http.post(Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/create_order'), body: body,headers: headers);

      EasyLoading.dismiss();

      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      orderSuccessModel = new OrderSuccessModel.fromJson(jsonResponse);
      toast(orderSuccessModel!.msg);
      prefs.setString('ord_id', orderSuccessModel!.order_id!.toString());
      AddPushData(orderSuccessModel!.order_id!);

      launchScreen(context, CheckOut.tag);

//      print(cat_model.data);
      return orderSuccessModel;

    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
      // return cat_model;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }




  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;


    Applycoupon() {



      if (cat_model!.couponDiscountTotals!.length == 0) {
        // do sth
        return Row(
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
        var myprice2 =double.parse(cat_model!.couponDiscountTotals![0]!.coupon_price!.toString());
        var myprice = myprice2.toStringAsFixed(2);
        // var myprice3;
        // if(price_decimal_sep==',') {
        //   myprice3 = myprice.replaceAll('.', ',').toString();
        // }else{
        //   myprice3=myprice;
        // }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            text(sh_lbl_coupon_discount,
                fontSize: textSizeSMedium,
                fontFamily: fontBold,
                textColor: sh_textColorPrimary),
            text("-"+currency! + myprice,
                fontSize: textSizeSMedium,
                fontFamily: fontBold,
                textColor: sh_textColorPrimary),
          ],
        );
      }
    }

    SubPrice(){
      var myprice2 =double.parse(cat_model!.subTotal.toString());
      var myprice = myprice2.toStringAsFixed(2);
      // var myprice3;
      // if(price_decimal_sep==',') {
      //   myprice3 = myprice.replaceAll('.', ',').toString();
      // }else{
      //   myprice3=myprice;
      // }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          text(sh_lbl_sub_total,
              fontSize: textSizeSMedium,
              fontFamily: fontBold,
              textColor: sh_textColorPrimary),
          text(currency! + myprice,
              textColor: sh_textColorPrimary,
              fontFamily: fontBold,
              fontSize: textSizeSMedium),
        ],
      );
    }

    ShippingPrice(){
      var myprice2 =double.parse(shipping_charge!);
      var myprice = myprice2.toStringAsFixed(2);
      // var myprice3;
      // if(price_decimal_sep==',') {
      //   myprice3 = myprice.replaceAll('.', ',').toString();
      // }else{
      //   myprice3=myprice;
      // }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          text("Shipping Charge :",
              fontSize: textSizeSMedium,
              fontFamily: fontBold,
              textColor: sh_textColorPrimary),
          text(currency! + myprice,
              fontSize: textSizeSMedium,
              fontFamily: fontBold,
              textColor: sh_textColorPrimary),
        ],
      );
    }

    TotalPrice(){
      var myprice2 =double.parse(total_amount.toString());
      var myprice = myprice2.toStringAsFixed(2);
      // var myprice3;
      // if(price_decimal_sep==',') {
      //   myprice3 = myprice.replaceAll('.', ',').toString();
      // }else{
      //   myprice3=myprice;
      // }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          text(sh_lbl_total_amount,
              fontSize: textSizeSMedium,
              fontFamily: fontBold,
              textColor: sh_textColorPrimary),
          text(currency! + myprice,
              textColor: sh_colorPrimary,
              fontFamily: fontBold,
              fontSize: textSizeLargeMedium),
        ],
      );
    }

    paymentDetail() {
      return Container(
        margin: EdgeInsets.fromLTRB(spacing_standard_new, spacing_standard_new,
            spacing_standard_new, spacing_standard_new),
        decoration:
        BoxDecoration(border: Border.all(color: sh_view_color, width: 1.0),color: sh_white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(spacing_standard_new,
                  spacing_middle, spacing_standard_new, spacing_middle),
              child: text("Payment Detail",
                  textColor: sh_textColorPrimary,
                  fontSize: textSizeLargeMedium,
                  fontFamily: 'Bold'),
            ),
            Divider(
              height: 1,
              color: sh_view_color,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(spacing_standard_new,
                  spacing_middle, spacing_standard_new, spacing_middle),
              child: Column(
                children: <Widget>[
                  // Row(
                  //   children: <Widget>[
                  //     text(sh_lbl_sub_total),
                  //     text(currency! + cat_model!.subTotal.toString(),
                  //         textColor: sh_colorPrimary,
                  //         fontFamily: fontBold,
                  //         fontSize: textSizeLargeMedium),
                  //   ],
                  // ),
                  SubPrice(),
                  ShippingPrice(),
                  Applycoupon(),
                  TotalPrice()
                ],
              ),
            )
          ],
        ),
      );
    }

    address() {
      return FutureBuilder<String?>(
          future: fetchadd(),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (!snapshot.hasData)
              return CupertinoActivityIndicator(
                animating: true,
              );
            return Container(
              width: double.infinity,
              color: sh_white,
              padding: EdgeInsets.all(spacing_standard_new),
              margin: EdgeInsets.all(spacing_standard_new),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  text("Delivered to:",
                      fontSize: textSizeSMedium,
                      fontFamily: fontBold,
                      textColor: sh_textColorPrimary),
                  text(firstname! + " " + lastname!,
                      textColor: sh_textColorPrimary,
                      fontFamily: fontBold,
                      fontSize: textSizeLargeMedium),
                  text(address1,
                      textColor: sh_textColorPrimary,
                      fontSize: textSizeLargeMedium),
                  text(city! + "," + state!,
                      textColor: sh_textColorPrimary,
                      fontSize: textSizeLargeMedium),
                  text(country_id! + "," + postcode!,
                      textColor: sh_textColorPrimary,
                      fontSize: textSizeLargeMedium),
                  SizedBox(
                    height: spacing_standard_new,
                  ),
                ],
              ),
            );
          });
    }

    cartList2() {
      return FutureBuilder<CartModel?>(
          future: fetchCart(),
          builder: (BuildContext context, AsyncSnapshot<CartModel?> snapshot) {
            if (!snapshot.hasData)
              return CupertinoActivityIndicator(
                animating: true,
              );
            return Column(
              children: [
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: cat_model!.cart!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Carts(cat_model!, index, currency!,sh_colorPrimary,sh_app_black,sh_view_color,sh_textColorPrimary);
                    }),
                paymentDetail(),
                Row(
                  children: [
                    Checkbox(
                      value: agree,
                      onChanged: (value) {
                        setState(() {
                          agree = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'I have read and accept terms and conditions',
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ],
            );
          });
    }

    bottomButtons() {
      return Container(
          height: 60,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: sh_shadow_color,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 3))
          ], color: sh_colorPrimary),
          child: FutureBuilder<String?>(
              future: fetchcurrency(),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (!snapshot.hasData)
                  return CupertinoActivityIndicator(
                    animating: true,
                  );
                return Row(
                  children: <Widget>[

                    Expanded(
                      child: InkWell(
                        child: Container(
                          child: text("Confirm Your Order",
                              textColor: sh_white,
                              fontSize: textSizeLargeMedium,
                              fontFamily: 'Bold'),
                          color: sh_colorPrimary,
                          alignment: Alignment.center,
                          height: double.infinity,
                        ),
                        onTap: () {
                          // CreateOrder();
                          Checkorder();
                          // launchScreen(context, CheckOut.tag);
                        },
                      ),
                    )
                  ],
                );
              })
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: sh_app_bar,
        title: text(sh_order_summary,
            textColor: sh_textColorPrimary,
            fontSize: textSizeNormal,
            fontFamily: fontBold),
        iconTheme: IconThemeData(color: sh_textColorPrimary),
        // text(sh_order_summary,
        //     textColor: sh_white, fontSize: textSizeNormal, fontFamily: 'Bold'),
      ),
      body: Container(
        height: height,
        width: width,
        child: Center(
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              Container(
                height: height,
                child: Column(
                  children: [
                    Expanded(
                      flex: 9,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            address(),
                            cartList2(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: sh_white,
                        child: bottomButtons(),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}

class Carts extends StatelessWidget {
  // FoodDish model;
  CartModel? model;
  int? position;
  String? currency;
  Color? sh_colorPrimary,sh_app_black,sh_view_color,sh_textColorPrimary;

  Carts(CartModel model, int pos, String curr,Color sh_colorPrimary,Color sh_app_black,Color sh_view_color,Color sh_textColorPrimary) {
    this.model = model;
    this.position = pos;
    this.currency = curr;
    this.sh_colorPrimary=sh_colorPrimary;
    this.sh_app_black=sh_app_black;
    this.sh_view_color=sh_view_color;
    this.sh_textColorPrimary=sh_textColorPrimary;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    VariationName(int pos) {
      if (model!.cart![pos]!.variationId.runtimeType == int) {
        return Container();
      } else if (model!.cart![pos]!.variationId.runtimeType == String) {
        if (model!.cart![pos]!.variationId != '') {
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: model!.cart![pos]!.variations!.length,
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
                          model!.cart![pos]!.variations![index]!.attributeName!,
                          style: TextStyle(
                              color: sh_textColorPrimary, fontSize: 14, fontFamily: 'Medium'),
                        ),
                        Text(" : "),
                        Text(
                          model!.cart![pos]!.variations![index]!.attributeValue!,
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

          //   Text(
          //   model!.cart![pos]!.variation!.attributeColor!,
          //   style: TextStyle(color: sh_colorPrimary, fontSize: 14),
          // );
        } else {
          return Container();
        }
      }
    }

    CartPrice(int position){
      var myprice2 =double.parse(model!.cart![position]!.productPrice!);
      var myprice = myprice2.toStringAsFixed(2);
      // var myprice3;
      // if(price_decimal_sep==',') {
      //   myprice3 = myprice.replaceAll('.', ',').toString();
      // }else{
      //   myprice3=myprice;
      // }
      return text(
        currency! + myprice,
      );
    }

    return Container(
      // margin: EdgeInsets.only(bottom: spacing_standard_new),
      margin: EdgeInsets.fromLTRB(
          spacing_standard_new, 0, spacing_standard_new, spacing_standard_new),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(spacing_middle)),
              child: Image.network(
                model!.cart![position!]!.productImage!,
                fit: BoxFit.fill,
                height: width * 0.20,
              ),
            ),
          ),
          SizedBox(
            width: spacing_standard_new,
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  model!.cart![position!]!.productName!,
                  style: TextStyle(color: sh_app_black, fontSize: 16),
                ),
                Container(child: VariationName(position!)),
                SizedBox(
                  height: 4,
                ),
                CartPrice(position!),

                SizedBox(
                  height: 4,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                      spacing_standard, 1, spacing_standard, 1),
                  decoration: BoxDecoration(
                      border: Border.all(color: sh_view_color!, width: 1)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      text("Qty: " + model!.cart![position!]!.quantity.toString(),
                          textColor: sh_textColorPrimary,
                          fontSize: textSizeSMedium)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
