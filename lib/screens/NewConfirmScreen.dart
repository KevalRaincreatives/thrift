import 'dart:async';
import 'dart:convert';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:thrift/database/CartPro.dart';
import 'package:thrift/database/database_hepler.dart';
import 'package:thrift/model/AddShipModel.dart';
import 'package:thrift/model/AddressListModel.dart';
import 'package:thrift/model/CartModel.dart';
import 'package:thrift/model/CouponErrorModel.dart';
import 'package:thrift/model/CouponModel.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/model/ErrorCheckModel.dart';
import 'package:thrift/model/NewShipmentModel.dart';
import 'package:thrift/model/OrderProductModel.dart';
import 'package:thrift/model/OrderSuccessModel.dart';
import 'package:thrift/model/OrderSuccessNewModel.dart';
import 'package:thrift/model/OrderWebSuccessModel.dart';
import 'package:thrift/model/ProductSellerModel.dart';
import 'package:thrift/provider/cart_provider.dart';
import 'package:thrift/screens/AddNewAddressScreen.dart';
import 'package:thrift/screens/DefaultAddressScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/NewConfirmScreen.dart';
import 'package:thrift/screens/OfferListScreen.dart';
import 'package:thrift/screens/OrderSuccessScreen.dart';
import 'package:thrift/screens/PaymentScreen.dart';
import 'package:thrift/screens/WebPaymentScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

import '../provider/home_product_provider.dart';


class NewConfirmScreen extends StatefulWidget {
  static String tag = '/NewConfirmScreen';

  const NewConfirmScreen({Key? key}) : super(key: key);

  @override
  _NewConfirmScreenState createState() => _NewConfirmScreenState();
}

class _NewConfirmScreenState extends State<NewConfirmScreen>
    with TickerProviderStateMixin {
  // CartModel? cat_model;
  var result = "CABF";
  // String? currency, currency_pos;
  TextEditingController _couponController = TextEditingController();
  CouponModel? couponModel;
  CouponErrorModel? couponErrorModel;
  final dbHelper = DatabaseHelper.instance;
  List<CartPro> cartPro = [];
  // String? final_token;
  double fl_total = 50.0;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  bool _resized = false;
  double _height = 0.02;
  double _width = 28;
  String user_total = '';
  double posx = 100.0;
  double posy = 100.0;
  bool isSwitched = true;
  int val = 1;
  int val2 = 1;
  NewShipmentModel? newShipmentModel;
  var selectedShipingIndex = 0;
  AddShipModel? addShipModel;
  // String? firstname, lastname, address1, city, postcode, country_id, state;
  // String? shipping_charge,
  //     total_amount,
  //     payment_method,
  //     shipment_method,
  //     shipment_title,
  //     payment_type;
  OrderSuccessNewModel? orderSuccessModel;
  OrderWebSuccessModel? orderWebSuccessModel;
  // final List<OrderProductModel> itemsModel = [];
  // OrderProductModel? itModel;

  ProductSellerModel? productSellerModel;
  // Future<CartModel?>? fetchAlbummy;
  // Future<String?>? fetchdeliverymy;
  // Future<String?>? fetchaddmy;
  var FeedbackCont = TextEditingController();

  Trace traceCreateOrder = FirebasePerformance.instance.newTrace('create_order');

  @override
  void initState() {
    final emp_pd = Provider.of<CartProvider>(context, listen: false);
    emp_pd.getCartOrder();
    // fetchAlbummy=fetchAlbum();
    // fetchdeliverymy=fetchdelivery();
    // fetchaddmy=fetchadd();
    super.initState();
  }

  // Future<String?> fetchadd() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     firstname = prefs.getString('firstname');
  //     lastname = prefs.getString('lastname');
  //     address1 = prefs.getString('address1');
  //     city = prefs.getString('city');
  //     postcode = prefs.getString('postcode');
  //     country_id = prefs.getString('country_id');
  //     state = prefs.getString('zone_id');
  //     return '';
  //   } catch (e) {
  //     print('caught error $e');
  //   }
  // }
  //
  // Future<String?> fetchdelivery() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? delivery_status = prefs.getString('delivery_status');
  //     if (prefs.getString('delivery_status') == 'yes') {
  //       isVisible = true;
  //
  //       shipping_charge = prefs.getString('shipping_charge');
  //       shipment_method = prefs.getString('shipment_method');
  //       shipment_title = prefs.getString('shipment_title');
  //     } else {
  //       isVisible = false;
  //       shipping_charge = "0";
  //       shipment_method = "";
  //       shipment_title = "";
  //     }
  //
  //     return '';
  //   } catch (e) {
  //     print('caught error $e');
  //   }
  // }

  Future<List<CartPro>> _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    cartPro.clear();
    allRows.forEach((row) => cartPro.add(CartPro.fromJson(row)));
    fl_total = 0.0;
    for (var i = 0; i < cartPro.length; i++) {
      double fnlamnt = double.parse(cartPro[i].line_subtotal!) *
          double.parse(cartPro[i].quantity!);
      fl_total += fnlamnt;
    }

    return cartPro;
  }

  // Future<String?> fetchToken() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     // String pro_id = prefs.getString('pro_id');
  //     final_token = prefs.getString('token');
  //     currency = prefs.getString('currency');
  //     currency_pos = prefs.getString('currency_pos');
  //     if (final_token == null) {
  //       final_token = '';
  //     }
  //
  //     print("mycur"+currency!);
  //     print("mycurpos"+currency_pos!);
  //     return final_token;
  //   } catch (e) {
  //     print('caught error $e');
  //   }
  // }

//   Future<CartModel?> fetchAlbum() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // String pro_id = prefs.getString('pro_id');
//       String? token = prefs.getString('token');
//       currency = prefs.getString('currency');
//       currency_pos = prefs.getString('currency_pos');
//
//       total_amount = prefs.getString('total_amnt');
//       payment_method = prefs.getString('payment_method');
//
//       payment_type = prefs.getString('payment_type');
//       String? user_country = prefs.getString('user_selected_country');
//
//       // print("myship"+shipping_charge!);
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//
//       Response response = await get(
//           Uri.parse(
//               '${Url.BASE_URL}wp-json/wooapp/v3/woocart?country=$user_country'),
//           headers: headers);
//
//       print('NewConfirmScreen woocart Response status2: ${response.statusCode}');
//       print('NewConfirmScreen woocart Response body2: ${response.body}');
//       final jsonResponse = json.decode(response.body);
//
//       cat_model = new CartModel.fromJson(jsonResponse);
//
//       itemsModel.clear();
//
//       prefs.setString(
//           'order_proname', cat_model!.cart![0]!.productName.toString());
//       prefs.setString(
//           'order_proprice', cat_model!.cart![0]!.productPrice.toString());
//       prefs.setString(
//           'order_proimage', cat_model!.cart![0]!.productImage.toString());
//
//       for (int i = 0; i < cat_model!.cart!.length; i++) {
//         if (cat_model!.cart![i]!.variationId.runtimeType == int) {
//           itModel = OrderProductModel(
//               pro_id: cat_model!.cart![i]!.productId.toString(),
//               variation_id: '',
//               quantity: cat_model!.cart![i]!.quantity.toString());
//           itemsModel.add(itModel!);
//         } else if (cat_model!.cart![i]!.variationId.runtimeType == String) {
//           if (cat_model!.cart![i]!.variationId != '') {
//             itModel = OrderProductModel(
//                 pro_id: cat_model!.cart![i]!.productId.toString(),
//                 variation_id: cat_model!.cart![i]!.variationId.toString(),
//                 quantity: cat_model!.cart![i]!.quantity.toString());
//             itemsModel.add(itModel!);
//           } else {
//             itModel = OrderProductModel(
//                 pro_id: cat_model!.cart![i]!.productId.toString(),
//                 variation_id: '',
//                 quantity: cat_model!.cart![i]!.quantity.toString());
//             itemsModel.add(itModel!);
//           }
//         }
//
//         // itModel = OrderProductModel(
//         //     pro_id: cat_model.cart[i].productId.toString(),
//         //     quantity: cat_model.cart[i].quantity.toString());
//         // itemsModel.add(itModel);
//       }
//
// //      print(cat_model.data);
//       return cat_model;
//     } catch (e) {
//       print('caught error $e');
//       // return cat_model;
//     }
//   }

//   Future<String?> AddPushData(int order_id) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // String pro_id = prefs.getString('pro_id');
//       String? token = prefs.getString('token');
//       total_amount = prefs.getString('total_amnt');
//       payment_method = prefs.getString('payment_method');
//
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//
//       var response = await http.get(
//           Uri.parse(
//               '${Url.BASE_URL}wp-json/wooapp/v3/order_status_push_notification?payment_method=cod&order_id=$order_id'),
//           headers: headers);
//
//       print('NewConfirmScreen order_status_push_notification Response status2: ${response.statusCode}');
//       print('NewConfirmScreen order_status_push_notification Response body2: ${response.body}');
//
//       final jsonResponse = json.decode(response.body);
//
//       return null;
//     } catch (e) {
// //      return orderListModel;
//       print('caught error $e');
//     }
//   }

  Future<String?> AddPushNotification(int order_id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      String? fnl_seller = prefs.getString('fnl_seller');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final msg = jsonEncode({"order_id": order_id, "seller_id": fnl_seller});

      var response = await http.post(
          Uri.parse(
              '${Url.BASE_URL}wp-json/wooapp/v3/send_push_notification_order'),
          headers: headers,
          body: msg);

      print('NewConfirmScreen send_push_notification_order Response status2: ${response.statusCode}');
      print('NewConfirmScreen send_push_notification_order Response body2: ${response.body}');

      final jsonResponse = json.decode(response.body);

      return null;
    } catch (e) {

//      return orderListModel;
      print('caught error $e');
    }
  }

  Future<OrderSuccessNewModel?> CreateOrder() async {
    await traceCreateOrder.start();
    final cartprovider = Provider.of<CartProvider>(context,listen: false);
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      String? coupon_amount = prefs.getString('coupon_amount');
      String? coupon_code = prefs.getString('coupon_code');
      String? payment_type = prefs.getString('payment_type');
      String? delivery_status = prefs.getString('delivery_status');
      String? fnl_seller = prefs.getString('fnl_seller');
      print(token);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var body;
      if (delivery_status == 'yes') {
        body = json.encode({
          "customer_note": FeedbackCont.text,
          "product_data": cartprovider.itemsModel,
          "payment_method": cartprovider.payment_method,
          "shipping_method": cartprovider.shipment_title,
          "shipping_method_title": cartprovider.shipment_method,
          "shipping_charge": cartprovider.shipping_charge,
          "coupon_code": coupon_code,
          "coupon_amount": coupon_amount,
          "shipping_first_name": cartprovider.firstname,
          "shipping_last_name": cartprovider.lastname,
          "shipping_address_1": cartprovider.address1,
          "shipping_city": cartprovider.city,
          "shipping_state": cartprovider.state,
          "shipping_postcode": cartprovider.postcode,
          "shipping_country": cartprovider.country_id,
          "seller_id": fnl_seller,
          "collect_from_seller": "0"
        });

        print(body);
      } else {
        body = json.encode({
          "customer_note": FeedbackCont.text,
          "product_data": cartprovider.itemsModel,
          "payment_method": cartprovider.payment_method,
          "shipping_method": "",
          "shipping_method_title": "",
          "shipping_charge": "0",
          "coupon_code": coupon_code,
          "coupon_amount": coupon_amount,
          "shipping_first_name": "",
          "shipping_last_name": "",
          "shipping_address_1": "",
          "shipping_city": "",
          "shipping_state": "",
          "shipping_postcode": "",
          "shipping_country": "",
          "seller_id": fnl_seller,
          "collect_from_seller": "1"
        });

        print(body);
      }

      var response = await http.post(
          Uri.parse(
              '${Url.BASE_URL}wp-json/wooapp/v3/create_order'),
          body: body,
          headers: headers);

      EasyLoading.dismiss();

      print('NewConfirmScreen create_order Response status2: ${response.statusCode}');
      print('NewConfirmScreen create_order Response body2: ${response.body}');

      final jsonResponse = json.decode(response.body);


      if (cartprovider.payment_method == "cod") {
        orderSuccessModel = new OrderSuccessNewModel.fromJson(jsonResponse);
        prefs.setString('ord_id', orderSuccessModel!.order_id!.toString());
        AddPushNotification(orderSuccessModel!.order_id!);
        toast(orderSuccessModel!.msg!);
        launchScreen(context, OrderSuccessScreen.tag);
      } else {
        ErrorCheckModel errorCheckModel =
            new ErrorCheckModel.fromJson(jsonResponse);
        if (errorCheckModel.success == "true") {
          orderWebSuccessModel =
              new OrderWebSuccessModel.fromJson(jsonResponse);
          print("Myweburl : "+orderWebSuccessModel!.redirectUrl.toString());
          prefs.setString(
              "weburl", orderWebSuccessModel!.redirectUrl.toString());
          prefs.setString('ord_id', orderWebSuccessModel!.orderId!.toString());
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const WebPaymentScreen(),
            ),
          );
          // launchScreen(context, WebPaymentScreen.tag);
        } else {
          CouponErrorModel couponErrorModel =
              new CouponErrorModel.fromJson(jsonResponse);
          toast(couponErrorModel.error.toString());
        }
      }

      // AddPushData(orderSuccessModel!.order_id!);

//      print(cat_model.data);
      await traceCreateOrder.stop();
      return orderSuccessModel;
    } catch (e) {
      await traceCreateOrder.stop();
      EasyLoading.dismiss();
      toast(e.toString());
      print('caught error $e');
      // return cat_model;
    }
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Checkout",
          style:
              TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
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
              width: width,
              height: height,
              child: Consumer<CartProvider>(builder: ((context, value, child) {
                var myprice2Ship = value.loader ? double.parse('0.0'):double.parse(value.shipping_charge.toString());
                var mypriceShip = value.loader ? double.parse('0.0'):myprice2Ship.toStringAsFixed(2);
                var myprice2Total = value.loader ? double.parse('0.0'):double.parse(value.total_amount.toString());
                var mypriceTotal = value.loader ? double.parse('0.0'):myprice2Total.toStringAsFixed(2);
                return value.loader ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  enabled: true,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 60.0,
                              height: 60.0,
                              color: Colors.white,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    height: 8.0,
                                    color: Colors.white,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 8.0,
                                    color: Colors.white,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                  ),
                                  Container(
                                    width: 40.0,
                                    height: 8.0,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Container(
                          width: width*.3,
                          height: 8.0,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          width: double.infinity,
                          height: 40.0,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 18,),
                        Container(
                          width: width*.3,
                          height: 8.0,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          width: double.infinity,
                          height: 80.0,
                          color: Colors.white,
                        ),

                        const SizedBox(height: 20,),
                        Container(
                          width: double.infinity,
                          height: 100.0,
                          color: Colors.white,
                        ),
                      ],),
                  ),
                ) :
                Container(
                  height: height,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 9,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 70),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 26,
                                      right: 26,
                                      top: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 8,
                                      ),
                                      AnimatedList(
                                        key: listKey,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        initialItemCount: value.cat_model!.cart!.length,
                                        itemBuilder: (context, index, animation) {
                                          var myprice2 = double.parse(value.cat_model!.cart![index]!.productPrice!);
                                          var myprice = myprice2.toStringAsFixed(2);

                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset(0, 0),
                                            ).animate(animation),
                                            child: Container(
                                              color: sh_white,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                          BorderRadius.all(Radius.circular(spacing_standard_new)),
                                                          child: Image.network(
                                                            value.cat_model!.cart![index]!.productImage!,
                                                            fit: BoxFit.fill,
                                                            height: width * 0.26,
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
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: <Widget>[
                                                            SizedBox(
                                                              height: spacing_standard,
                                                            ),
                                                            Html(
                                                              data: value.cat_model!.cart![index]!.productName!,
                                                              style: {
                                                                "body": Style(
                                                                  maxLines: 2,
                                                                  margin: EdgeInsets.zero, padding: EdgeInsets.zero,
                                                                  fontSize: FontSize(16.0),
                                                                  fontWeight: FontWeight.bold,
                                                                  color: sh_colorPrimary2,
                                                                  fontFamily: fontBold,
                                                                ),
                                                              },
                                                            ),
                                                            // Text(
                                                            //   value.cat_model!.cart![index]!.productName!,
                                                            //   style: TextStyle(
                                                            //       color: sh_colorPrimary2,
                                                            //       fontSize: 16,
                                                            //       fontFamily: fontBold),
                                                            // ),
                                                            // Container(child: VariationName(positions,cartprovider)),
                                                            SizedBox(
                                                              height: 4,
                                                            ),
                                                            text(value.currency! + myprice + " " + "USD",
                                                                textColor: sh_black, fontFamily: fontSemibold, fontSize: 16.0),
                                                            // text(currency! + cat_model!.cart![positions]!.productPrice!,
                                                            //     textColor: sh_app_black, fontFamily: 'Bold'),
                                                            SizedBox(
                                                              height: 9,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    height: 1,
                                                    color: sh_view_color,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ); // Refer step 3
                                        },
                                      ),
                                      Container(
                                        height: 0.5,
                                        color: sh_view_color,
                                        width: width,
                                        margin: EdgeInsets.only(
                                            bottom: spacing_standard_new),
                                      ),

                                      text("Details",
                                          fontSize: textSizeMedium,
                                          fontFamily: fontBold,
                                          textColor: sh_colorPrimary2),
                                      SizedBox(
                                        height: 6.0,
                                      ),
                                      Visibility(
                                        visible: isSwitched,
                                        child: Container(
                                          padding: EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: sh_colorPrimary2),
                                            color: sh_white,
                                            borderRadius: BorderRadius.circular(10.0),
                                            // boxShadow: true
                                          ),

                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Visibility(
                                                visible: value.isVisible!,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        value.shipment_method!,
                                                        style: TextStyle(
                                                            color: sh_black,
                                                            fontSize: 15,
                                                            fontFamily: fontSemibold),
                                                      ),
                                                    ),
                                                    // ShipPrice(cartprovider)
                                                    Text(value.currency! + mypriceShip.toString() + " " + "USD",
                                                        style: TextStyle(color: sh_colorPrimary2, fontSize: 15, fontFamily: fontBold))
                                                    // Text("\$"+shipping_charge!+".00"+" "+cat_model!.currency!,style: TextStyle(color: sh_black,fontSize: 15,fontFamily: "Bold"),)
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: spacing_standard,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    value.payment_type!,
                                                    style: TextStyle(
                                                        color: sh_black,
                                                        fontSize: 15,
                                                        fontFamily: fontSemibold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: spacing_standard_new,
                                      ),
                                      Visibility(
                                        visible: value.isVisible!,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            text("Delivered to",
                                                fontSize: textSizeMedium,
                                                fontFamily: fontBold,
                                                textColor: sh_colorPrimary2),
                                            SizedBox(
                                              height: spacing_standard,
                                            ),
                                            Container(
                                              child: Center(
                                                child: Container(
                                                  width: width,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(bottom: spacing_standard_new),
                                                    child: Container(
                                                      padding: EdgeInsets.all(12.0),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: sh_colorPrimary2),
                                                        color: sh_white,
                                                        borderRadius: BorderRadius.circular(10.0),
                                                        // boxShadow: true
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          text(value.firstname! + " " + value.lastname!,
                                                              textColor: sh_textColorPrimary,
                                                              fontFamily: fontMedium,
                                                              fontSize: textSizeSMedium),
                                                          text(value.address1,
                                                              textColor: sh_textColorPrimary, fontSize: textSizeSMedium),
                                                          text(value.city! + "," + value.state!,
                                                              textColor: sh_textColorPrimary, fontSize: textSizeSMedium),
                                                          text(value.country_id! + "," + value.postcode!,
                                                              textColor: sh_textColorPrimary, fontSize: textSizeSMedium),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        color: Colors.transparent,
                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: TextFormField(
                                          controller: FeedbackCont,
                                          maxLines: 5,
                                          // keyboardType: TextInputType.text, textInputAction: TextInputAction.done,
                                          style: TextStyle(
                                              color: sh_textColorPrimary,
                                              fontSize: textSizeMedium,
                                              fontFamily: "Bold"),
                                          decoration: InputDecoration(
                                            filled: true,
                                            hintMaxLines: 3,
                                            fillColor: sh_text_back,
                                            contentPadding:
                                            EdgeInsets.fromLTRB(16, 16, 16, 16),
                                            hintText: "Notes",
                                            hintStyle:
                                            TextStyle(color: sh_textColorSecondary),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: sh_transparent, width: 0.7),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                  color: sh_transparent, width: 0.7),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: sh_white,
                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                text("Total",
                                                    fontSize: textSizeMedium,
                                                    fontFamily: fontBold,
                                                    textColor: sh_colorPrimary2),
                                                text(value.currency! + mypriceTotal.toString() + " " + "USD",
                                                    fontSize: textSizeMedium,
                                                    fontFamily: fontBold,
                                                    textColor: sh_black),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: spacing_middle,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          CreateOrder();
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.only(top: 6, bottom: 10),
                                          decoration: boxDecoration(
                                              bgColor: sh_btn_color, radius: 10, showShadow: true),
                                          child: text(value.payment_method == "cod" ? "Confirm & Place Order" :"Confirm & Pay",
                                              fontSize: 16.0,
                                              textColor: sh_colorPrimary2,
                                              isCentered: true,
                                              fontFamily: 'Bold'),
                                        ),
                                      )


                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
      } )),
          ),
        ),
        // Positioned to take only AppBar size
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.0, 2, 6, 2),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 32,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,6,6,6.0),
                      child: Text(
                        "Checkout",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'TitleCursive'),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    return Sizer(
        builder: (context, orientation, deviceType) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: StreamProvider<NetworkStatus>(
          initialData: NetworkStatus.Online,
          create: (context) =>
          NetworkStatusService().networkStatusController.stream,
          child: NetworkAwareWidget(
            onlineChild: SafeArea(child: setUserForm()),
            offlineChild: Container(
              child: Center(
                child: Text(
                  "No internet connection!",
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w600,
                      fontSize: 20.0),
                ),
              ),
            ),
          ),
        ),
      );
        },
    );
  }

  @override
  void screenUpdate() {
    setState(() {});
  }

  FinalTotal(cartprovider) {
    var myprice2 = double.parse(fl_total.toString());
    var myprice = myprice2.toStringAsFixed(2);

    return text("Total: " + cartprovider.currency! + myprice,
        textColor: sh_app_black,
        fontFamily: 'Bold',
        fontSize: textSizeLargeMedium);
  }

  CartFinalTotal(cartprovider) {
    var myprice2 = double.parse(cartprovider.catModel!.total.toString());
    var myprice = myprice2.toStringAsFixed(2);
    return text("Total: " + cartprovider.currency! + myprice,
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
