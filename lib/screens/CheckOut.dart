import 'package:flutter/material.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';


class CheckOut extends StatefulWidget {
  static String tag='/CheckOut';
  const CheckOut({Key? key}) : super(key: key);

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  String? ord_id;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: sh_new_app_background,
        width: width,
        child: Stack(
          children: <Widget>[

            Container(
              width: width,
              padding: EdgeInsets.fromLTRB(20, 30, 20, 84),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.check_circle,
                    color: sh_colorPrimary,
                    size: 60,
                  ),
                  SizedBox(
                    height: 26,
                  ),
                  Text(
                    "Thank You!",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 26,
                  ),
                  Text(
                    "Your order has been placed successfully!",
                    style: TextStyle(
                        color: sh_app_black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 26,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Your Order ID is #',
                        style: TextStyle(
                            color: sh_app_black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ord_id!,
                        style: TextStyle(
                            color: sh_colorPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 36,
                  ),
                  // Text(
                  //   'Please allow us 2 working days',
                  //   style: TextStyle(
                  //       color: sh_app_black,
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(
                  //   height: 2,
                  // ),
                  // Text(
                  //   'to get back to you',
                  //   style: TextStyle(
                  //       color: sh_app_black,
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(height: 40,),
                  Row(
                    children: <Widget>[
                      Expanded(flex: 5, child: Container()),
                      Expanded(
                          flex: 5,
                          child: InkWell(
                            onTap: () async{
                              launchScreen(context, DashboardScreen.tag);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  sh_lbl_continue,
                                  style:
                                  TextStyle(color: sh_colorPrimary, fontSize: 22,fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
