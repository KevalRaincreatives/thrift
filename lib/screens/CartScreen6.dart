import 'dart:async';
import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
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
import 'package:thrift/model/NewShipmentModel.dart';
import 'package:thrift/model/ProductSellerModel.dart';
import 'package:thrift/screens/AddNewAddressScreen.dart';
import 'package:thrift/screens/AddressListScreen.dart';
import 'package:thrift/screens/DefaultAddressScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/NewConfirmScreen.dart';
import 'package:thrift/screens/OfferListScreen.dart';
import 'package:thrift/screens/PaymentModel.dart';
import 'package:thrift/screens/PaymentScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';


class CartScreen extends StatefulWidget {
  static String tag = '/CartScreen';

  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
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
  String user_total = '';
  double posx = 100.0;
  double posy = 100.0;
  bool isSwitched = true;
  int val = 1;
  int val2 = 1;
  AddressListModel? _addressModel;
  NewShipmentModel? newShipmentModel;
  int? selectedShipingIndex = 0;
  AddShipModel? addShipModel;
  PaymentModel? paymentModel;
  int? selectedPaymentIndex = -1;
  String? total_amount;
  bool first = true;
  bool first2 = true;
  int? address_pos;
  var myprice;
  ProductSellerModel? productSellerModel;
  Future<AddressListModel?>? fetchAddressmy;
  Future<PaymentModel?>? fetchPaymentmy;
  Future<NewShipmentModel?>? fetchShipmentmy;
  Future<CartModel?>? fetchAlbummy;


  @override
  void initState() {
    fetchAddressmy = fetchAddress();
    fetchPaymentmy=fetchPayment();
    fetchShipmentmy=fetchShipment();
    fetchAlbummy=fetchAlbum();
    super.initState();
  }


  Future<AddressListModel?> fetchAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      // String? address_pos=prefs.getString("address_pos");
      // int address_pos=prefs.getString("address_pos").toInt();
      if (prefs.getString("address_pos") == null) {
        // toast("null");
        // print("mycheck null");
        address_pos = 0;
      } else {
        // toast("not null");
        // print("mycheck not null");
        address_pos = prefs.getString("address_pos").toInt();
        // toast(address_pos);
        // print("mycheck" + address_pos!);
      }
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      print(token);

      Response response = await get(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/list_shipping_addres'),
          headers: headers);
      print(
          "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/list_shipping_addres");

      print('Response status2: ${response.statusCode}');
      print('Response bodyaddress: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');

      _addressModel = new AddressListModel.fromJson(jsonResponse);
      if(_addressModel!.data!.length == 0){

      }else {
        prefs.setString(
            'firstname', _addressModel!.data![address_pos!]!.firstName!);
        prefs.setString("lastname", _addressModel!.data![address_pos!]!.lastName!);
        prefs.setString("address1", _addressModel!.data![address_pos!]!.address!);
        prefs.setString("city", _addressModel!.data![address_pos!]!.city!);
        prefs.setString("postcode", _addressModel!.data![address_pos!]!.postcode!);
        prefs.setString(
            "country_id", _addressModel!.data![address_pos!]!.country!);
        prefs.setString("zone_id", _addressModel!.data![address_pos!]!.state!);
      }
      print(_addressModel!.data);

      return _addressModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<NewShipmentModel?> fetchShipment() async {
    // EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      String? user_country = prefs.getString('user_selected_country');
//      print

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Response response = await get(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/get_shipping_methods?country=$user_country'),
          headers: headers);
      // EasyLoading.dismiss();
      print('Response status2: ${response.statusCode}');
      print('Response bodyshipmemt: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');

      newShipmentModel = new NewShipmentModel.fromJson(jsonResponse);
      first2 = false;
      if(prefs.getInt("shiping_index")!=null && prefs.getInt("shiping_index")!=-2){
        // toast("ad");
        selectedShipingIndex=prefs.getInt("shiping_index");
      }else{

        // selectedShipingIndex=-1;
        selectedShipingIndex=0;

        GetShip(newShipmentModel!.methods![selectedShipingIndex!]!.id!.toString());


        // double total;
        // double rate = double.parse(newShipmentModel!
        //     .methods![0]!.settings!.cost!.value!);
        // total = double.parse(cat_model!.total!) + rate;
        // total_amount = total.toString();
        //
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString("total_amnt", total_amount!);


        // myprice2 = double.parse(total_amount!);
        // var myprice = myprice2.toStringAsFixed(2);

      }


      // if(first2) {
      //   // double total;
      //   // double rate = double.parse(
      //   //     newShipmentModel!.methods![0]!.settings!.cost!.value!);
      //   // total = double.parse(total_amount!) + rate;
      //   // total_amount = total.toString();
      // }
      // else{
      //   double total;
      //   double rate = double.parse(
      //       newShipmentModel!.methods![0]!.settings!.cost!.value!);
      //   total = double.parse(total_amount!) + rate;
      //   total_amount = total.toString();
      // }

//      print(cat_model.data);
      return newShipmentModel;
    } catch (e) {
      print('caught error $e');
      // return cat_model;
    }
  }

  Future<AddShipModel?> GetShip(String ship_id) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      String? user_country = prefs.getString('user_selected_country');
//      print

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg =
          jsonEncode({"shipping_method": ship_id, "country": user_country});
      print(msg);

      Response response = await post(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/add_shipping_charge'),
          headers: headers,
          body: msg);
      EasyLoading.dismiss();
      print('Response status2: ${response.statusCode}');
      print('Response body26: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json ship$jsonResponse');

      addShipModel = new AddShipModel.fromJson(jsonResponse);
      prefs.setString(
          "shipping_charge", addShipModel!.shippingCharge!.toString());
      print("mypricess"+addShipModel!.total.toString());
      prefs.setString("total_amnt", addShipModel!.total.toString());
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setInt("shiping_index", selectedShipingIndex!);

      // total_amount=addShipModel!.total.toString();

      // fetchAlbum();
      // launchScreen(context, NewConfirmScreen.tag);

//      print(cat_model.data);
      return addShipModel;
    } catch (e) {
      print('caught error $e');
      // return cat_model;
    }
  }

  Future<PaymentModel?> fetchPayment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? user_country = prefs.getString('user_selected_country');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Response response = await get(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/list_payment_method/?country=$user_country'),
          headers: headers);
      final jsonResponse = json.decode(response.body);
      print('not json 2count$jsonResponse');
      paymentModel = new PaymentModel.fromJson(jsonResponse);

      print(paymentModel!.data);
      if(prefs.getInt("payment_index")!=null && prefs.getInt("payment_index")!=-2){
        // toast("cd");
        selectedPaymentIndex=prefs.getInt("payment_index");
      }else{
        // toast("dd");
        selectedPaymentIndex=-1;
      }
      return paymentModel;
    } catch (e) {
      print('caught error $e');
    }
  }

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
      String? user_country = prefs.getString('user_selected_country');
      print(token);
      if (token != null && token != '') {
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

        Response response = await get(
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/woocart?country=$user_country'),
            headers: headers);

        print('Response status2: ${response.statusCode}');
        print('Response bodyalbum: ${response.body}');
        final jsonResponse = json.decode(response.body);
        print('not json $jsonResponse');
        cat_model = new CartModel.fromJson(jsonResponse);

        if (cat_model!.cart == null) {
          prefs.setInt("cart_count", 0);
        }else if (cat_model!.cart!.length == 0) {
          prefs.setInt("cart_count", 0);
        }else{
          prefs.setInt("cart_count", cat_model!.cart!.length);
        }


        user_total = cat_model!.total.toString();
        if (first) {
          total_amount = cat_model!.total.toString();
        } else {
          first = false;
        }

        if (cat_model!.couponDiscountTotals!.length == 0) {
          prefs.setString("coupon_code", "");
          prefs.setString("coupon_amount", "");
        } else {
          prefs.setString("coupon_code", cat_model!.appliedCoupons![0]);
          prefs.setString(
              "coupon_amount", cat_model!.couponDiscountTotals!.toString());
        }
      } else {
        _queryAll();
      }


      // first2=false;

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
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/remove_cart_item'),
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
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/remove_cart_item'),
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
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/update_cart'),
            headers: headers,
            body: msg);
      }
      EasyLoading.dismiss();
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      setState(() {});
      // if(prefs.getInt('cart_count')!=null){
      // int cart_tot=prefs.getInt('cart_count')!-1;
      prefs.setInt("cart_count", prefs.getInt('cart_count')!-1);
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
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/apply_coupon'),
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
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/remove_coupon'),
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

  Future<String> fnlPrice() async{
    var myprice2;
    if (first2) {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // if(prefs.getInt("shiping_index")!=null){
      //
      // }else{
      //   myprice2 = double.parse(cat_model!.total.toString());
      // }

      // myprice2 = double.parse(cat_model!.total.toString());
      // setState(() {
        fetchShipment();
      // });

    } else {

      if(selectedShipingIndex==-1){
        myprice2 = double.parse(cat_model!.total.toString());
      }else {

        double total;
        double rate = double.parse(newShipmentModel!
            .methods![selectedShipingIndex!]!.settings!.cost!.value!);
        total = double.parse(cat_model!.total!) + rate;
        total_amount = total.toString();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("total_amnt", total_amount!);

        myprice2 = double.parse(total_amount!);
      }
    }

    myprice = myprice2.toStringAsFixed(2);
    return myprice;
  }

  Future<ProductSellerModel?> fetchSeller() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pro_id = cat_model!.cart![0]!.productId;
      // toast(pro_id);
      // print(
      //     "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/get_product_seller?product_id=$pro_id");
      Response response = await get(Uri.parse(
          'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/get_product_seller?product_id=$pro_id'));
      final jsonResponse = json.decode(response.body);
      print('not json p2pr$jsonResponse');
      productSellerModel = new ProductSellerModel.fromJson(jsonResponse);
      // prefs.setString("fnl_seller", productSellerModel.seller)
      prefs.setString("fnl_seller", productSellerModel!.seller!.sellerId.toString());
      EasyLoading.dismiss();
      launchScreen(context, NewConfirmScreen.tag);
      return productSellerModel;
    } catch (e) {
      EasyLoading.dismiss();
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

    void _update(
        id,
        pro_id,
        pro_name,
        product_img,
        variation_id,
        variation_name,
        variation_value,
        qty,
        line_subtotal,
        line_total,
        st_status) async {
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

        CartPro car = CartPro(
            id,
            pro_id,
            pro_name,
            product_img,
            variation_id,
            variation_name,
            variation_value,
            quantitys,
            line_subtotal,
            fnlamnt.toString());

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
                    showShadow: true, radius: 0, bgColor: sh_light_gray),
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
                              borderRadius: BorderRadius.circular(2.0),
                              borderSide: BorderSide(
                                  color: sh_textColorSecondary, width: 0.4)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(2.0),
                                  topRight: Radius.circular(0.0),
                                  bottomLeft: Radius.circular(2.0),
                                  bottomRight: Radius.circular(0.0)),
                              borderSide: BorderSide(
                                  color: sh_textColorSecondary, width: 0.2)),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () async {
                            getCoupon();
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                            onTap: () async {
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
                child: Wrap(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                      decoration: BoxDecoration(
                          color: pro_back,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(0),
                              topLeft: Radius.circular(0))),
                      child: Wrap(
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cat_model!.cart![pos]!.variations![index]!
                                      .attributeName!,
                                  style: TextStyle(
                                      color: sh_textColorPrimary,
                                      fontSize: 14,
                                      fontFamily: 'Medium'),
                                ),
                                Text(" : "),
                                Text(
                                  cat_model!.cart![pos]!.variations![index]!
                                      .attributeValue!,
                                  style: TextStyle(
                                      color: sh_textColorPrimary,
                                      fontSize: 14,
                                      fontFamily: 'Medium'),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
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
          for (int i = 0; i < split_name.length; i++) i: split_name[i]
        };

        final split_value = cartPro[pos].variation_value!.split(',');
        final Map<int, String> var_value = {
          for (int i = 0; i < split_value.length; i++) i: split_value[i]
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          var_name[index]!,
                          style: TextStyle(
                              color: sh_textColorPrimary,
                              fontSize: 14,
                              fontFamily: 'Medium'),
                        ),
                        Text(" : "),
                        Text(
                          var_value[index]!,
                          style: TextStyle(
                              color: sh_textColorPrimary,
                              fontSize: 14,
                              fontFamily: 'Medium'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }
    }

    CartPrice(int pos) {
      var myprice2 = double.parse(cat_model!.cart![pos]!.productPrice!);
      var myprice = myprice2.toStringAsFixed(2);

      return text(currency! + myprice + " " + cat_model!.currency!,
          textColor: sh_app_black, fontFamily: fontBold, fontSize: 14.0);
    }

    Cart(CartModel models, int positions, animation, bool rsize) {
      // toast(positions.toString());
      if (rsize) {
        return Container(
          color: sh_white,
          // margin: EdgeInsets.only(bottom: spacing_standard_new),
          child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    flex: 3,
                    child: AnimatedSize(
                      curve: Curves.bounceInOut,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(spacing_standard_new)),
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
                                fontFamily: fontSemibold),
                          ),
                          Container(child: VariationName(positions)),
                          SizedBox(
                            height: 4,
                          ),
                          CartPrice(positions),
                          SizedBox(
                            height: 9,
                          ),
                          InkWell(
                            onTap: () async {
                              // BecameSeller();
                              setState(() {
                                user_total = '';
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
                                        duration:
                                            const Duration(milliseconds: 500));
                                  } else {
                                    listKey.currentState!.removeItem(
                                        positions,
                                        (_, animation) => Cart(cat_model!,
                                            positions, animation, true),
                                        duration:
                                            const Duration(milliseconds: 500));
                                    cat_model!.cart!.removeAt(positions);
                                  }
                                } else {
                                  cat_model!.cart!.removeAt(positions);

                                  listKey.currentState!.removeItem(
                                      positions,
                                      (_, animation) => Cart(cat_model!,
                                          positions, animation, true),
                                      duration:
                                          const Duration(milliseconds: 500));
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
                            child: Container(
                              width: MediaQuery.of(context).size.width * .7,
                              padding: EdgeInsets.only(top: 6, bottom: 10),
                              decoration: boxDecoration(
                                  bgColor: sh_btn_color,
                                  radius: 10,
                                  showShadow: true),
                              child: text("Remove",
                                  fontSize: 16.0,
                                  textColor: sh_colorPrimary2,
                                  isCentered: true,
                                  fontFamily: 'Bold'),
                            ),
                          ),
                        ],
                      ),
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
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(spacing_standard_new)),
                        child: Image.network(
                          cat_model!.cart![positions]!.productImage!,
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
                        children: <Widget>[
                          Text(
                            cat_model!.cart![positions]!.productName!,
                            style: TextStyle(
                                color: sh_colorPrimary2,
                                fontSize: 14,
                                fontFamily: fontBold),
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
                          InkWell(
                            onTap: () async {
                              // BecameSeller();
                              setState(() {
                                user_total = '';
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
                                        duration:
                                            const Duration(milliseconds: 500));
                                  } else {
                                    listKey.currentState!.removeItem(
                                        positions,
                                        (_, animation) => Cart(cat_model!,
                                            positions, animation, true),
                                        duration:
                                            const Duration(milliseconds: 500));
                                    cat_model!.cart!.removeAt(positions);
                                  }
                                } else {
                                  cat_model!.cart!.removeAt(positions);

                                  listKey.currentState!.removeItem(
                                      positions,
                                      (_, animation) => Cart(cat_model!,
                                          positions, animation, true),
                                      duration:
                                          const Duration(milliseconds: 500));
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
                            child: Container(
                              padding: EdgeInsets.all(4.0),
                              decoration: boxDecoration(
                                  bgColor: sh_btn_color,
                                  radius: 6,
                                  showShadow: true),
                              child: text("Remove",
                                  fontSize: 12.0,
                                  textColor: sh_colorPrimary2,
                                  isCentered: true,
                                  fontFamily: fontSemibold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),

              ],
            ),
          ),
        );
      }
    }

    SubCPrice(int positions) {
      var myprice2 = double.parse(cartPro[positions].line_subtotal!);
      var myprice = myprice2.toStringAsFixed(2);

      return text(currency! + myprice,
          textColor: sh_app_black, fontFamily: 'Bold');
    }

    CartGuest(CartPro models, int positions, animation, bool rsize) {
      if (rsize) {
        return Container(
          color: sh_white,
          child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: 8,
                  ),
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
                                          if (positions == cartPro.length - 1) {
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

                                          if (cartPro.length == 2) {
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
                                    icon: Icon(Icons.add,
                                        color: sh_black, size: 16),
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
              SizedBox(
                height: 10,
              ),
              Container(
                height: 1,
                color: sh_view_color,
              )
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
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: 8,
                    ),
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
                                        int pos = positions;

                                        if (positions > 0) {
                                          if (positions == cartPro.length - 1) {
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
                                          if (cartPro.length == 2) {
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
                                          } else {
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
                                            () => _update(
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
                                    icon: Icon(Icons.add,
                                        color: sh_black, size: 16),
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
        );
      }
    }

    CouponDiscount() {
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            text(sh_coupon_desc,
                fontSize: textSizeSMedium,
                fontFamily: fontBold,
                textColor: sh_textColorPrimary),
            text(
                currency! +
                    cat_model!.couponDiscountTotals![0]!.coupon_price
                        .toString(),
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
        var myprice2 = double.parse(cat_model!.total.toString());
        var myprice = myprice2.toStringAsFixed(2);
        print("mypricess"+myprice);
        prefs.setString("total_amnt", myprice);

        launchScreen(context, DefaultAddressScreen.tag);
        // launchScreen(context, DefaultNewAddressScreen.tag);
      } else {
        launchScreen(context, LoginScreen.tag);
      }
    }

    SubPrice() {
      var myprice2 = double.parse(cat_model!.subTotal.toString());
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
      );
    }

    CheckPrice() async
    {
      if(selectedShipingIndex==-1) {}else{
        double total;
        double rate = double.parse(newShipmentModel!
            .methods![selectedShipingIndex!]!.settings!.cost!.value!);
        total = double.parse(cat_model!.total!) + rate;
        total_amount = total.toString();

        print(total_amount);
        // myprice2 = double.parse(total_amount!);
        var myprice = double.parse(total_amount!).toStringAsFixed(2);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("total_amnt", myprice.toString());
      }
    }

     TotalPrice() {
      var myprice2;
      if (first2) {

        myprice2 = double.parse(cat_model!.total.toString());
        var myprice = myprice2.toStringAsFixed(2);
toast(myprice+"1");
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            text("Total",
                fontSize: textSizeMedium,
                fontFamily: fontBold,
                textColor: sh_colorPrimary2),
            text(currency! + myprice + " " + cat_model!.currency!,
                fontSize: textSizeMedium,
                fontFamily: fontBold,
                textColor: sh_black),
          ],
        );



        myprice2 = double.parse(cat_model!.total.toString());
      } else {

        if(selectedShipingIndex==-1){
          myprice2 = double.parse(cat_model!.total.toString());
          var myprice = myprice2.toStringAsFixed(2);
          toast(myprice+"2");

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text("Total",
                  fontSize: textSizeMedium,
                  fontFamily: fontBold,
                  textColor: sh_colorPrimary2),
              text(currency! + myprice + " " + cat_model!.currency!,
                  fontSize: textSizeMedium,
                  fontFamily: fontBold,
                  textColor: sh_black),
            ],
          );
        }
        else {

          double total;
          double rate = double.parse(newShipmentModel!
              .methods![selectedShipingIndex!]!.settings!.cost!.value!);
          total = double.parse(cat_model!.total!) + rate;
          total_amount = total.toString();

          // SharedPreferences prefs = await SharedPreferences.getInstance();
          // prefs.setString("total_amnt", total_amount!);


          myprice2 = double.parse(total_amount!);
          var myprice = myprice2.toStringAsFixed(2);

          // toast(myprice +"3");
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text("Total",
                  fontSize: textSizeMedium,
                  fontFamily: fontBold,
                  textColor: sh_colorPrimary2),
              text(currency! + myprice + " " + cat_model!.currency!,
                  fontSize: textSizeMedium,
                  fontFamily: fontBold,
                  textColor: sh_black),
            ],
          );
        }
      }

      // var myprice = myprice2.toStringAsFixed(2);

    }

    // TotalPrice2() {
    //   var myprice2;
    //   if (first2) {
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //     if(prefs.getInt("shiping_index")!=null){
    //       toast("ad");
    //       selectedShipingIndex=prefs.getInt("shiping_index");
    //     }else{
    //       toast("bd");
    //       selectedShipingIndex=-1;
    //     }
    //
    //     myprice2 = double.parse(cat_model!.total.toString());
    //   } else {
    //
    //     if(selectedShipingIndex==-1){
    //       myprice2 = double.parse(cat_model!.total.toString());
    //     }else {
    //
    //       double total;
    //       double rate = double.parse(newShipmentModel!
    //           .methods![selectedShipingIndex!]!.settings!.cost!.value!);
    //       total = double.parse(cat_model!.total!) + rate;
    //       total_amount = total.toString();
    //
    //       myprice2 = double.parse(total_amount!);
    //     }
    //   }
    //
    //   // var myprice = myprice2.toStringAsFixed(2);
    //   return Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: <Widget>[
    //       text("Total",
    //           fontSize: textSizeMedium,
    //           fontFamily: fontBold,
    //           textColor: sh_colorPrimary2),
    //       text(currency! + myprice + " " + cat_model!.currency!,
    //           fontSize: textSizeMedium,
    //           fontFamily: fontBold,
    //           textColor: sh_black),
    //     ],
    //   );
    // }

    void _openCustomDialog() {
      showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Center(child: Text('Address is not Valid',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16,),
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
                          child: text("Ok",
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

    CheckPayButton() {
      if (val == 1) {
        return InkWell(
          onTap: () async {
            // BecameSeller();
            // launchScreen(context, PaymentScreen.tag);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? user_country = prefs.getString('user_selected_country');
            if(isSwitched){
            if (_addressModel!.data!.length == 0) {
              toast("Please Add a Address");
            } else if (_addressModel!.data![address_pos!]!.country!=user_country) {
              // toast("Please Change Address");
              // toast(_addressModel!.data![address_pos!]!.country!+" - "+user_country!);
              _openCustomDialog();
            }
            else {
              if (selectedShipingIndex == -1) {
                toast("Please Select Shipping Method");
              }else if (selectedPaymentIndex == -1) {
                toast("Please Select Payment Method");
              } else {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                prefs.setString('shipment_title', "free_shipping");
                prefs.setString('shipment_method', "Free shipping");

                // prefs.setString("shipping_charge", "0");
                prefs.setString("delivery_status", "yes");
                prefs.setString(
                    'shipment_title',
                    newShipmentModel!.methods![selectedShipingIndex!]!.id!
                        .toString());
                prefs.setString('shipment_method',
                    newShipmentModel!.methods![selectedShipingIndex!]!.title!);

                prefs.setString('payment_method',
                    paymentModel!.data![selectedPaymentIndex!]!.id!);
                prefs.setString('payment_type',
                    paymentModel!.data![selectedPaymentIndex!]!.title!);
                prefs.setString('publish_key',
                    paymentModel!.data![selectedPaymentIndex!]!
                        .publishableKey!);
                prefs.setString('secret_key',
                    paymentModel!.data![selectedPaymentIndex!]!.secretKey!);
                if (paymentModel!.data![selectedPaymentIndex!]!.testmode!) {
                  prefs.setString('testmode', "True");
                } else {
                  prefs.setString('testmode', "False");
                }

                // GetShip(newShipmentModel!.methods![selectedShipingIndex]!.id!
                //     .toString());
                // launchScreen(context, NewConfirmScreen.tag);
                fetchSeller();
              }
            }
            }else{

                if (selectedPaymentIndex == -1) {
                  toast("Please Select Payment Method");
                } else {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  // prefs.setString(
                  //     'firstname', _addressModel!.data![0]!.firstName!);
                  // prefs.setString("lastname", _addressModel!.data![0]!.lastName!);
                  // prefs.setString("address1", _addressModel!.data![0]!.address!);
                  // prefs.setString("city", _addressModel!.data![0]!.city!);
                  // prefs.setString("postcode", _addressModel!.data![0]!.postcode!);
                  // prefs.setString(
                  //     "country_id", _addressModel!.data![0]!.country!);
                  // prefs.setString("zone_id", _addressModel!.data![0]!.state!);
                  //
                  // prefs.setString('shipment_title', "free_shipping");
                  // prefs.setString('shipment_method', "Free shipping");

                  // prefs.setString("shipping_charge", "0");

                  // prefs.setString(
                  //     'shipment_title',
                  //     newShipmentModel!.methods![selectedShipingIndex!]!.id!
                  //         .toString());
                  // prefs.setString('shipment_method',
                  //     newShipmentModel!.methods![selectedShipingIndex!]!.title!);

                  prefs.setString('payment_method',
                      paymentModel!.data![selectedPaymentIndex!]!.id!);
                  prefs.setString('payment_type',
                      paymentModel!.data![selectedPaymentIndex!]!.title!);
                  prefs.setString('publish_key',
                      paymentModel!.data![selectedPaymentIndex!]!
                          .publishableKey!);
                  prefs.setString('secret_key',
                      paymentModel!.data![selectedPaymentIndex!]!.secretKey!);
                  if (paymentModel!.data![selectedPaymentIndex!]!.testmode!) {
                    prefs.setString('testmode', "True");
                  } else {
                    prefs.setString('testmode', "False");
                  }
                  print("mypricess"+cat_model!.total.toString());
                  prefs.setString("total_amnt", cat_model!.total.toString());
                  prefs.setString("delivery_status", "no");
                  // GetShip(newShipmentModel!.methods![selectedShipingIndex]!.id!
                  //     .toString());
                  // launchScreen(context, NewConfirmScreen.tag);
                  fetchSeller();
                }

            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 6, bottom: 10),
            decoration: boxDecoration(
                bgColor: sh_btn_color, radius: 10, showShadow: true),
            child: text("Checkout",
                fontSize: 16.0,
                textColor: sh_colorPrimary2,
                isCentered: true,
                fontFamily: 'Bold'),
          ),
        );
      } else {
        return InkWell(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? user_country = prefs.getString('user_selected_country');
            if(isSwitched){
            if (_addressModel!.data!.length == 0) {
              toast("Please Add a Address");
            } else if (_addressModel!.data![address_pos!]!.country!=user_country) {
              // toast("Please Change Address");
              // toast(_addressModel!.data![address_pos!]!.country!+" - "+user_country!);
              _openCustomDialog();
            } else {
              if (selectedShipingIndex == -1) {
                toast("Please Select Shipping Method");
              }else if (selectedPaymentIndex == -1) {
                toast("Please Select Payment Method");
              } else {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString(
                    'firstname', _addressModel!.data![0]!.firstName!);
                prefs.setString("lastname", _addressModel!.data![0]!.lastName!);
                prefs.setString("address1", _addressModel!.data![0]!.address!);
                prefs.setString("city", _addressModel!.data![0]!.city!);
                prefs.setString("postcode", _addressModel!.data![0]!.postcode!);
                prefs.setString(
                    "country_id", _addressModel!.data![0]!.country!);
                prefs.setString("zone_id", _addressModel!.data![0]!.state!);

                prefs.setString('shipment_title', "free_shipping");
                prefs.setString('shipment_method', "Free shipping");

                // prefs.setString("shipping_charge", "0");

                prefs.setString(
                    'shipment_title',
                    newShipmentModel!.methods![selectedShipingIndex!]!.id!
                        .toString());
                prefs.setString('shipment_method',
                    newShipmentModel!.methods![selectedShipingIndex!]!.title!);
                // GetShip(newShipmentModel!.methods![selectedShipingIndex]!.id!
                //     .toString());

                prefs.setString("delivery_status", "yes");
                // launchScreen(context, NewConfirmScreen.tag);
                fetchSeller();
              }
            }
            }else{

                if (selectedPaymentIndex == -1) {
                  toast("Please Select Payment Method");
                } else {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  // prefs.setString(
                  //     'firstname', _addressModel!.data![0]!.firstName!);
                  // prefs.setString("lastname", _addressModel!.data![0]!.lastName!);
                  // prefs.setString("address1", _addressModel!.data![0]!.address!);
                  // prefs.setString("city", _addressModel!.data![0]!.city!);
                  // prefs.setString("postcode", _addressModel!.data![0]!.postcode!);
                  // prefs.setString(
                  //     "country_id", _addressModel!.data![0]!.country!);
                  // prefs.setString("zone_id", _addressModel!.data![0]!.state!);
                  //
                  // prefs.setString('shipment_title', "free_shipping");
                  // prefs.setString('shipment_method', "Free shipping");
                  //
                  // // prefs.setString("shipping_charge", "0");
                  //
                  // prefs.setString(
                  //     'shipment_title',
                  //     newShipmentModel!.methods![selectedShipingIndex!]!.id!
                  //         .toString());
                  // prefs.setString('shipment_method',
                  //     newShipmentModel!.methods![selectedShipingIndex!]!.title!);
                  // GetShip(newShipmentModel!.methods![selectedShipingIndex]!.id!
                  //     .toString());
                  print("mypricess"+cat_model!.total.toString());
                  prefs.setString("total_amnt", cat_model!.total.toString());
                  prefs.setString("delivery_status", "no");
                  // launchScreen(context, NewConfirmScreen.tag);
                  fetchSeller();
                }

            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 6, bottom: 10),
            decoration: boxDecoration(
                bgColor: sh_btn_color, radius: 10, showShadow: true),
            child: text("Checkout",
                fontSize: 16.0,
                textColor: sh_colorPrimary2,
                isCentered: true,
                fontFamily: 'Bold'),
          ),
        );
      }
    }

    listView(data) {
      return Padding(
        padding: const EdgeInsets.only(bottom: spacing_standard_new),
        child: InkWell(
          onTap: () {
            setState(() {
              // selectedAddressIndex = index;
            });
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(color: sh_colorPrimary2),
              color: sh_white,
              borderRadius: BorderRadius.circular(10.0),
              // boxShadow: true
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      text(
                          _addressModel!.data![address_pos!]!.firstName! +
                              " " +
                              _addressModel!.data![address_pos!]!.lastName!,
                          textColor: sh_textColorPrimary,
                          fontFamily: fontMedium,
                          fontSize: textSizeSMedium),
                      text(_addressModel!.data![address_pos!]!.address!,
                          textColor: sh_textColorPrimary,
                          fontFamily: fontRegular,
                          fontSize: textSizeSMedium2),
                      text(
                          _addressModel!.data![address_pos!]!.city! +
                              "," +
                              _addressModel!.data![address_pos!]!.state!,
                          textColor: sh_textColorPrimary,
                          fontFamily: fontRegular,
                          fontSize: textSizeSMedium2),
                      text(
                          _addressModel!.data![address_pos!]!.country! +
                              "," +
                              _addressModel!.data![address_pos!]!.postcode!,
                          textColor: sh_textColorPrimary,
                          fontFamily: fontRegular,
                          fontSize: textSizeSMedium2),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('from', "default");
                    prefs.setInt('payment_index', selectedPaymentIndex!);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                AddressListScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: boxDecoration(
                        bgColor: sh_btn_color, radius: 6, showShadow: true),
                    child: text("Change",
                        textColor: sh_colorPrimary2,
                        isCentered: true,
                        fontSize: 12.0,
                        fontFamily: fontSemibold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    ListAddressValidation() {
      if (_addressModel!.data!.length == 0) {
        return Container(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No Address Found',
                  style: TextStyle(
                      fontSize: 16,
                      color: sh_colorPrimary2,
                      fontFamily: 'Bold',
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 12,
                ),
                InkWell(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('from', "default");
                    prefs.setInt('payment_index', selectedPaymentIndex!);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                AddNewAddressScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.0),

                    decoration: BoxDecoration(
                        border: Border.all(color: sh_colorPrimary2),
                      color: sh_white,
                      borderRadius: BorderRadius.circular(10.0),
                      // boxShadow: true
                    ),
                    // boxDecoration(
                    //     bgColor: sh_app_background,
                    //     radius: 10,
                    //     showShadow: true),
                    child: text("Add New Address",
                        textColor: sh_colorPrimary2,
                        isCentered: true,
                        fontSize: 12.0,
                        fontFamily: 'Bold'),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return listView(_addressModel!.data);
      }
    }

    FlatRatePrice(int index) {
      var myprice2, myprice;
      if (newShipmentModel!.methods![index]!.settings!.cost!.value! == '') {
        myprice = '0.00';
      } else {
        myprice2 = double.parse(
            newShipmentModel!.methods![index]!.settings!.cost!.value!);
        myprice = myprice2.toStringAsFixed(2);
      }
      return Row(
        children: [
          Text("\$" + myprice + " " + newShipmentModel!.currency!,
              style:
                  TextStyle(color: sh_black, fontSize: 14, fontFamily: fontSemibold)),
        ],
      );
    }

    ListValidation() {
      if (cat_model!.cart == null) {
        return Container(
          alignment: Alignment.center,
          child: Text(
            'Your Cart is currently empty',
            style: TextStyle(
                fontSize: 16,
                color: sh_textColorPrimary,
                fontWeight: FontWeight.bold),
          ),
        );
      } else if (cat_model!.cart!.length == 0) {
        return Container(
          alignment: Alignment.center,
          child: Text(
            'Your Cart is currently empty',
            style: TextStyle(
                fontSize: 16,
                color: sh_textColorPrimary,
                fontWeight: FontWeight.bold),
          ),
        );
      } else {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24,0,24,70.0),
            child: Container(
              // margin: EdgeInsets.only(
              //     left: spacing_standard_new,
              //     right: spacing_standard_new,
              //     top: spacing_control),
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
                    initialItemCount: cat_model!.cart!.length,
                    itemBuilder: (context, index, animation) {
                      return Cart(cat_model!, index, animation,
                          false); // Refer step 3
                    },
                  ),
                  Container(
                    height: 0.5,
                    color: sh_view_color,
                    width: width,
                    margin: EdgeInsets.only(top: spacing_middle,
                        bottom: spacing_middle),
                  ),


                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery",
                        style: TextStyle(
                            color: sh_colorPrimary2,
                            fontSize: 14,
                            fontFamily: fontBold),
                      ),
                      Row(
                        children: [
                          Text(
                            "No",
                            style: TextStyle(
                                color: sh_colorPrimary2,
                                fontSize: 14,
                                fontFamily: fontBold),
                          ),
                          Switch(
                            value: isSwitched,
                            onChanged: (value) {
                              setState(() {
                                isSwitched = value;
                                print(isSwitched);
                              });
                            },
                            activeTrackColor: sh_btn_color,
                            activeColor: sh_colorPrimary2,
                          ),
                          Text(
                            "Yes",
                            style: TextStyle(
                                color: sh_colorPrimary2,
                                fontSize: 14,
                                fontFamily: fontBold),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: spacing_control_half,
                  ),
                  Visibility(
                    visible: isSwitched,
                    child: Container(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                            top: spacing_control,
                            bottom: spacing_control),
                        itemBuilder: (item, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: spacing_standard_new),
                            child: InkWell(
                              onTap: () async{
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setInt("shiping_index", index);
                                setState(() {

                                  selectedShipingIndex = index;
                                  double total;
                                  double rate = double.parse(newShipmentModel!.methods![index]!.settings!.cost!.value!);
                                  total = double.parse(cat_model!.total!) + rate;
                                  total_amount = total.toString();
                                  GetShip(newShipmentModel!.methods![selectedShipingIndex!]!.id!.toString());
                                });
                              },
                              child: Container(
                                // padding: EdgeInsets.all(spacing_standard_new),
                                // margin: EdgeInsets.only(
                                //   right: spacing_standard_new,
                                //   left: spacing_standard_new,
                                // ),
                                color: sh_white,
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: <Widget>[
                                    Radio(
                                      value: index,
                                      groupValue:
                                      selectedShipingIndex,
                                      onChanged:
                                          (int? value) async{
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.setInt("shiping_index", value!);
                                        setState(() {


                                          selectedShipingIndex =
                                              value;
                                          double total;
                                          double rate = double.parse(
                                              newShipmentModel!
                                                  .methods![
                                              index]!
                                                  .settings!
                                                  .cost!
                                                  .value!);
                                          total = double.parse(
                                              cat_model!
                                                  .total!) +
                                              rate;
                                          total_amount = total
                                              .toString();
                                          GetShip(newShipmentModel!
                                              .methods![
                                          selectedShipingIndex!]!
                                              .id!
                                              .toString());
                                        });
                                      },
                                      activeColor:
                                      sh_colorPrimary2,
                                      // hoverColor: sh_btn_color,

                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  newShipmentModel!
                                                      .methods![
                                                  index]!
                                                      .title!,
                                                  style: TextStyle(
                                                      color:
                                                      sh_colorPrimary2,
                                                      fontSize:
                                                      15,
                                                      fontFamily:
                                                      fontSemibold),
                                                ),
                                              ),

                                              FlatRatePrice(
                                                  index)
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            newShipmentModel!
                                                .methods![
                                            index]!
                                                .methodTitle!,
                                            style: TextStyle(
                                                color:
                                                sh_black,
                                                fontSize: 13,
                                                fontFamily:
                                                fontRegular),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        shrinkWrap: true,
                        itemCount:
                        newShipmentModel!.methods!.length,
                      ),
                    ),
                  ),
                  text("Payment Method",
                      fontSize: textSizeSMedium,
                      fontFamily: fontBold,
                      textColor: sh_colorPrimary2),

                  FutureBuilder<PaymentModel?>(
                    future: fetchPaymentmy,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return PaymentWidget(
                          selectedPaymentIndex:
                          selectedPaymentIndex,
                          paymentModel: paymentModel,
                          onSelectionChanged: (selectedList) async{
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setInt('payment_index', selectedList);
                            setState(() {
                              selectedPaymentIndex = selectedList;
                            });
                          },);
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      // By default, show a loading spinner.
                      return Container();
                    },
                  ),

                  Visibility(
                    visible: isSwitched,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text("Delivered to",
                            fontSize: textSizeSMedium,
                            fontFamily: fontBold,
                            textColor: sh_colorPrimary2),
                        SizedBox(
                          height: spacing_standard,
                        ),

                        Container(
                          child: Center(
                            child: FutureBuilder<AddressListModel?>(
                              future: fetchAddressmy,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Container(
                                    child: ListAddressValidation(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                // By default, show a loading spinner.
                                return Container();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  Container(
                    color: sh_white,
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TotalPrice()

                      ],
                    ),
                  ),

                  SizedBox(
                    height: spacing_middle,
                  ),
                  CheckPayButton()
                ],
              ),
            ),
          ),
        );
      }
    }

    SubCartPrice() {
      var myprice2 = double.parse(fl_total.toString());
      var myprice = myprice2.toStringAsFixed(2);

      return Row(
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
      );
    }

    TotalCartPrice() {
      var myprice2 = double.parse(fl_total.toString());
      var myprice = myprice2.toStringAsFixed(2);
      return Row(
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
            'Your Cart is currently empty',
            style: TextStyle(
                fontSize: 16,
                color: sh_textColorPrimary,
                fontWeight: FontWeight.bold),
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
                            child: Center(child: FinalTotal()),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
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
            future: fetchAlbummy,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FutureBuilder<NewShipmentModel?>(
                  future: fetchShipmentmy,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return
                        ListValidation();
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    // By default, show a loading spinner.
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: ListView.builder(
                        itemBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 48.0,
                                height: 48.0,
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
                                      padding: EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.0),
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
                        ),
                        itemCount: 6,
                      ),
                    );
                    return Center(child: CircularProgressIndicator());
                  },
                );

              } else if (snapshot.hasError) {
//                    return Text("${snapshot.error}");
                return Center(
                    child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Your Cart is currently empty',
                    style: TextStyle(
                        fontSize: 16,
                        color: sh_textColorPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                ));
              }
              // By default, show a loading spinner.
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                enabled: true,
                child: ListView.builder(
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 48.0,
                          height: 48.0,
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
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
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
                  ),
                  itemCount: 6,
                ),
              );
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
                    'Your Cart is currently empty',
                    style: TextStyle(
                        fontSize: 16,
                        color: sh_textColorPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                ));
              }
              // By default, show a loading spinner.
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                enabled: true,
                child: ListView.builder(
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 48.0,
                          height: 48.0,
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
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
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
                  ),
                  itemCount: 6,
                ),
              );
            });
      }
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "My Cart",
          style:
              TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
      );
      // double app_height = appBar.preferredSize.height;
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(children: <Widget>[
              // Background with gradient
              Container(
                  height: 120,
                  width: width,
                  child: Image.asset(sh_upper2, fit: BoxFit.fill)
                  // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
                  ),
              //Above card


              // Positioned to take only AppBar size
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(1.0, 0, 6, 0),
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
                              "My Cart",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontFamily: 'TitleCursive'),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            Container(
              height: height-153,
              width: width,
              color: sh_white,
              child: FutureBuilder<String?>(
                  future: fetchToken(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CheckToken();
                    }
                    // By default, show a loading spinner.
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: ListView.builder(
                        itemBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 48.0,
                                height: 48.0,
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
                                      padding: EdgeInsets.symmetric(vertical: 2.0),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.0),
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
                        ),
                        itemCount: 6,
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
  }

  @override
  void screenUpdate() {
    setState(() {});
  }

  FinalTotal() {
    var myprice2 = double.parse(fl_total.toString());
    var myprice = myprice2.toStringAsFixed(2);

    return text("Total: " + currency! + myprice,
        textColor: sh_app_black,
        fontFamily: 'Bold',
        fontSize: textSizeLargeMedium);
  }

  CartFinalTotal() {
    var myprice2 = double.parse(cat_model!.total.toString());
    var myprice = myprice2.toStringAsFixed(2);
    return text("Total: " + currency! + myprice,
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

class PaymentWidget extends StatefulWidget {
  int? selectedPaymentIndex;
  PaymentModel? paymentModel;
  Function(int)? onSelectionChanged;

  PaymentWidget({Key? key, this.selectedPaymentIndex,this.paymentModel, this.onSelectionChanged})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PaymentWidgetState();
  }
}

class _PaymentWidgetState extends State<PaymentWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Single2(StateSetter setState2, int index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: InkWell(
          onTap: () {
            setState(() {
              widget.selectedPaymentIndex=index;
              widget.onSelectionChanged?.call(index);
              // widget.onSelectionChanged = index;
            });
          },
          child: Container(
            color: sh_white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Radio(
                    value: index,
                    groupValue: widget.selectedPaymentIndex,
                    onChanged: (int? value) {
                      setState(() {
                        widget.selectedPaymentIndex = value!;
                        widget.onSelectionChanged?.call(index);
                      });
                    },
                    activeColor: sh_colorPrimary2),
                Text(widget.paymentModel!.data![index]!.title!),
              ],
            ),
          ),
        ),
      );
    }

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState2) {
      return Container(
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(
              top: spacing_standard, bottom: spacing_standard),
          itemBuilder: (item, index) {
            return Single2(setState2, index);
          },
          shrinkWrap: true,
          itemCount: widget.paymentModel!.data!.length,
        ),
      );
      //   Wrap(
      //   spacing: 8,
      //   direction: Axis.horizontal,
      //   children: techChips2(setState2),
      // );
    });

    ;
  }
}
