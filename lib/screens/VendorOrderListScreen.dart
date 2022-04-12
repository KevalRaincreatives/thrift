import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/OrderListModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/OrderDetailScreen.dart';
import 'package:thrift/screens/VendorOrderDetailScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:badges/badges.dart';

class VendorOrderListScreen extends StatefulWidget {
  static String tag='/VendorOrderListScreen';
  const VendorOrderListScreen({Key? key}) : super(key: key);

  @override
  _VendorOrderListScreenState createState() => _VendorOrderListScreenState();
}

class _VendorOrderListScreenState extends State<VendorOrderListScreen> {
  OrderListModel? orderListModel;
  String? productPerRow,
      showDiscountPrice,
      showShortDesc,currency_symbol,price_decimal_sep,price_num_decimals;
  String? sh_app_bars;

  Future<OrderListModel?> fetchOrder() async {
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
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/view_vendor_order'),
          headers: headers);

      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      orderListModel = new OrderListModel.fromJson(jsonResponse);

      return orderListModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<bool> _onWillPop() async{
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => DashboardScreen(selectedTab: 0,)),
      ModalRoute.withName('/DashboardScreen'),
    );
    return false;
  }

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


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var height = MediaQuery
        .of(context)
        .size
        .height;
    toCurrencyFormat({var format = '\$'}) {
      return format + this;
    }

    OrderDate(int index) {
      String hh = orderListModel!.data![index]!.postTitle!.substring(13);
      String dd = hh.substring(0, hh.length - 10);
      return text(
          dd +
              "\n Order Placed",
          maxLine: 2,
          fontSize: textSizeMedium,
          textColor: sh_textColorPrimary);


    }

    CartPrice(int index){
      var myprice2 =double.parse(orderListModel!.data![index]!.total.toString());
      var myprice = myprice2.toStringAsFixed(2);
      var myprice3;
      if(price_decimal_sep==',') {
        myprice3 = myprice.replaceAll('.', ',').toString();
      }else{
        myprice3=myprice;
      }
      return                           text7("Total : \$" +
          myprice3 +" "+orderListModel!.currency!,
          textColor: sh_app_txt_color,
          fontFamily: 'Bold',
          fontSize: textSizeNormal);
    }

    listView() {
      if(orderListModel!.data!.length == 0){
        return Container(
          height: height-130,
          alignment: Alignment.center,
          child: Center(
            child: Text(
              'No Order Found',
              style: TextStyle(
                  fontSize: 20,
                  color: sh_colorPrimary2,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      }else {
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: orderListModel!.data!.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('order_id',
                    orderListModel!.data![index]!.ID!.toString());
                prefs.commit();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VendorOrderDetailScreen()));
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: EdgeInsets.all(10.0),
                decoration: boxDecoration(
                  radius: 12,
                  showShadow: true,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            text7("ID :#" +
                                orderListModel!.data![index]!.ID.toString(),
                                textColor: sh_textColorPrimary,
                                fontFamily: 'Bold',
                                fontSize: textSizeLargeMedium),
                            SizedBox(height: 4),
                            text7(orderListModel!.data![index]!.products![0]!.name!,
                                textColor: sh_app_txt_color,
                                fontFamily: 'Bold',
                                fontSize: textSizeNormal),
                            CartPrice(index),
                            // text7("Total : $currency_symbol" +
                            //     orderListModel!.data![index]!.total.toString(),
                            //     textColor: sh_colorPrimary,
                            //     fontFamily: 'Bold',
                            //     fontSize: textSizeNormal),
                            SizedBox(
                              height: spacing_standard,
                            ),
                            Expanded(
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment
                                      .stretch,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          OrderDate(index)


                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
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
        );
      }
    }

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

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          sh_lbl_my_orders,
          style:
          TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
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
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          color: sh_white,
          child: WillPopScope(
            onWillPop: _onWillPop,
            child: Container(
              width: width,
              height: height,
              child: SafeArea(
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        // TopBar(t1_Listing),
                        FutureBuilder<OrderListModel?>(
                          future: fetchOrder(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return listView();
                            }
                            return Center(child: CircularProgressIndicator());
                          },
                        ),

                        Container(
                          height: 16,
                        )
                      ],
                    ),
                  ),
                ),
              ),
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
                        launchScreen(context, DashboardScreen.tag);
                      }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 36,)),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(sh_lbl_my_sales,style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Cursive'),),
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

      body: WillPopScope(
          onWillPop: _onWillPop,
          child: SafeArea(child: setUserForm())),
    );


  }
}
