import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/screens/CartScreen2.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/OrderListScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;

class OrderSuccessScreen extends StatefulWidget {
  static String tag='/OrderSuccessScreen';
  const OrderSuccessScreen({Key? key}) : super(key: key);

  @override
  _OrderSuccessScreenState createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  String? order_proname,order_proprice,order_proimage;

  @override
  void initState() {
    AddPushNotification();
    super.initState();
  }

  Future<String?> AddPushNotification() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      String? fnl_seller= prefs.getString('fnl_seller');
      String? ord_id= prefs.getString('ord_id');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final msg = jsonEncode({"order_id": ord_id,"seller_id": fnl_seller});

      var response = await http.post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/send_push_notification_order'),headers: headers,
          body: msg
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

  Future<String?> fetchadd() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      order_proname = prefs.getString('order_proname');
      order_proprice = prefs.getString('order_proprice');
      order_proimage = prefs.getString('order_proimage');
      return '';
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<bool> _onWillPop()  async{
    launchScreen(context, DashboardScreen.tag);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    MyPrice() {
      var myprice2, myprice;
      if (order_proprice == '') {
        myprice = '0.00';
      } else {
        myprice2 = double.parse(order_proprice!);
        myprice = myprice2.toStringAsFixed(2);
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(
          //   "\$" + myprice,
          //   style: TextStyle(
          //       color: sh_black,
          //       fontFamily: fontBold,
          //       fontSize: textSizeSMedium2),
          // ),
          Text(
            "\$"+myprice!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: sh_black,
                fontFamily: fontBold,
                fontSize: textSizeMedium),
          )
        ],
      );
    }


    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Success",
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
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          color: sh_white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: sh_colorPrimary2,
                    size: 30,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Order Placed!",
                    style: TextStyle(
                        color: sh_colorPrimary2,
                        fontSize: 24,
                        fontFamily: "Bold"),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder<String?>(
                future: fetchadd(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(order_proimage!,
                              width: width * .4, height: width * .4, fit: BoxFit.fill),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          order_proname!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: sh_colorPrimary2,
                              fontFamily: fontBold,
                              fontSize: textSizeMedium),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        MyPrice(),
                        SizedBox(
                          height: 4,
                        ),

                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  // By default, show a loading spinner.
                  return CircularProgressIndicator();
                },
              ),


              SizedBox(
                height: 30,
              ),
              Container(
                height: 0.5,
                color: sh_app_txt_color,
              ),
              SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  Text(
                    "An email notification ",
                    style: TextStyle(
                        color: sh_black, fontSize: 15, fontFamily: "Bold"),
                  ),
                  Text(
                    "will be sent",
                    style: TextStyle(
                        color: sh_colorPrimary2,
                        fontSize: 15,
                        fontFamily: "Bold"),
                  ),
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  Text(
                    "arrange collection or delivery of your item",
                    style: TextStyle(
                        color: sh_colorPrimary2,
                        fontSize: 15,
                        fontFamily: "Bold"),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt("cart_count", 0);
launchScreen(context, DashboardScreen.tag);
                    },
                    child: Container(
                      padding: EdgeInsets.all(spacing_standard),
                      decoration: boxDecoration(
                          bgColor: sh_btn_color,
                          radius: 6,
                          showShadow: true),
                      child: text("Continue Shopping",
                          textColor: sh_colorPrimary2,
                          isCentered: true,
                          fontSize: 12.0,
                          fontFamily: 'Bold'),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt("cart_count", 0);
                      Navigator.of(context).pop(ConfirmAction.CANCEL);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderListScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(spacing_standard),
                      decoration: boxDecoration(
                          bgColor: sh_colorPrimary2,
                          radius: 6,
                          showShadow: true),
                      child: text("View Order",
                          textColor: sh_white,
                          isCentered: true,
                          fontSize: 12.0,
                          fontFamily: 'Bold'),
                    ),
                  ),
                ],
              )
            ],
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
                      child: Text("Success",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Cursive'),),
                    )
                  ],
                ),
                // GestureDetector(
                //   onTap: () async{
                //     SharedPreferences prefs = await SharedPreferences.getInstance();
                //     prefs.setInt("shiping_index", -2);
                //     prefs.setInt("payment_index", -2);
                //     launchScreen(context, CartScreen.tag);
                //   },
                //   child: Container(
                //     padding: EdgeInsets.fromLTRB(4, 0, 20, 0),
                //     child: Image.asset(
                //       sh_new_cart,
                //       height: 50,
                //       width: 50,
                //       color: sh_white,
                //     ),
                //   ),
                //
                // ),
              ],
            ),
          ),
        ),
      ]);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
          child: setUserForm(),
        ),
      ),
    );

  }
}
