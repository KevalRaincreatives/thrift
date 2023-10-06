import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/OrderListScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

import '../database/database_hepler.dart';
import '../provider/home_product_provider.dart';

class OrderFailScreen extends StatefulWidget {
  static String tag='/OrderFailScreen';
  const OrderFailScreen({Key? key}) : super(key: key);

  @override
  State<OrderFailScreen> createState() => _OrderFailScreenState();
}

class _OrderFailScreenState extends State<OrderFailScreen> {
  String? order_proname,order_proprice,order_proimage;
  Future<String?>? fetchaddMain;
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    fetchaddMain=fetchadd();
    final postMdl = Provider.of<HomeProductListProvider>(context, listen: false);
    postMdl.getHomeProduct('Newest to Oldest',true);
    dbHelper.cleanDatabase();
    super.initState();
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
    // launchScreen(context, DashboardScreen.tag);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => DashboardScreen(selectedTab: 0,)),
      ModalRoute.withName('/DashboardScreen'),
    );
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
          "Fail",
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
                    Icons.cancel,
                    color: sh_app_red,
                    size: 30,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Order Failed!",
                    style: TextStyle(
                        color: sh_app_red,
                        fontSize: 24,
                        fontFamily: "Bold"),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder<String?>(
                future: fetchaddMain,
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
                        Html(
                          data: order_proname!,
                          style: {
                            "body": Style(
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                              // alignment: Alignment.center,
                              textAlign: TextAlign.center,
                              margin: EdgeInsets.zero, padding: EdgeInsets.zero,
                              fontSize: FontSize(16.0),
                              fontWeight: FontWeight.bold,
                              color: sh_colorPrimary2,
                              fontFamily: fontBold,
                            ),
                          },
                        ),
                        // Text(
                        //   order_proname!,
                        //   maxLines: 2,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: TextStyle(
                        //       color: sh_colorPrimary2,
                        //       fontFamily: fontBold,
                        //       fontSize: textSizeMedium),
                        // ),
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


              const SizedBox(
                height: 40,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt("cart_count", 0);
                      Navigator.of(context).pop(ConfirmAction.CANCEL);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(selectedTab: 0),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(spacing_standard),
                      decoration: boxDecoration(
                          bgColor: sh_colorPrimary2,
                          radius: 6,
                          showShadow: true),
                      child: text("Try Again",
                          textColor: sh_white,
                          isCentered: true,
                          fontSize: 16.0,
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
            padding: const EdgeInsets.fromLTRB(10,18,10,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.0,2,6,2),
                      child: IconButton(onPressed: () async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setInt("cart_count", 0);
                        Navigator.of(context).pop(ConfirmAction.CANCEL);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DashboardScreen(selectedTab: 0),
                          ),
                        );
                      }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 32,)),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,6,6,6.0),
                      child: Text("Fail",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
        child: StreamProvider<NetworkStatus>(
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
      ),
    );
  }
}
