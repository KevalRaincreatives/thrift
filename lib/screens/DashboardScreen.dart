import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/retry.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/fragments/AccountFragment.dart';
import 'package:thrift/fragments/HomeFragment.dart';
import 'package:thrift/fragments/SettingFragment.dart';
import 'package:thrift/model/CategoryModel.dart';
import 'package:thrift/screens/AddressListScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/CreateProductScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/MyProfileScreen.dart';
import 'package:thrift/screens/OrderListScreen.dart';
import 'package:thrift/screens/ProductlistScreen.dart';
import 'package:thrift/screens/SplashScreen.dart';
import 'package:thrift/screens/TermsConditionScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/utils/T3Dialog.dart';

class DashboardScreen extends StatefulWidget {
  static String tag='/DashboardScreen';
  // const DashboardScreen({Key? key}) : super(key: key);
  var selectedTab=0;

  DashboardScreen({Key? key, required this.selectedTab}) : super(key: key);


  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<CategoryModel> categoryListModel = [];
  var homeFragment = HomeFragment();
  var settingFragment = SettingFragment();
  var profileFragment = AccountFragment();
  var fragments;
  var selectedTab = 0;
  var title = "Home";
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  Future<List<CategoryModel>?> fetchAlbum() async {
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
//       var response = await http.get(
//           Uri.parse("https://encros.rcstaging.co.in/wp-json/wc/v3/products/categories"));
      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.get(
            Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/categories"));
      } finally {
        client.close();
      }


      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      for (Map i in jsonResponse) {
        categoryListModel.add(CategoryModel.fromJson(i));
//        orderListModel = new OrderListModel2.fromJson(i);
      }

      return categoryListModel;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }

  // Future<bool> _onWillPop() {
  //   return showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Are you sure?'),
  //       content: Text('Do you want to exit an App'),
  //       actions: <Widget>[
  //         FlatButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: Text('No'),
  //         ),
  //         FlatButton(
  //           onPressed: () => exit(0),
  //           /*Navigator.of(context).pop(true)*/
  //           child: Text('Yes'),
  //         ),
  //       ],
  //     ),
  //   ) ??
  //       false;
  // }

  @override
  void initState() {
    super.initState();
    fragments = [homeFragment, settingFragment, profileFragment];

    // fetchData();
  }

  Future<bool> _onWillPop()  async{
    if(widget.selectedTab==0){
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to exit an App'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => exit(0),
              /*Navigator.of(context).pop(true)*/
              child: Text('Yes'),
            ),
          ],
        ),
      ) ?? false;
    }else{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DashboardScreen(selectedTab: 0),
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(


      body: WillPopScope(
        onWillPop: _onWillPop,
child: Stack(
  alignment: Alignment.bottomLeft,
  children: <Widget>[
    fragments[widget.selectedTab],
    Container(
      height: 58,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Center(
            child: Container(
              decoration: boxDecoration(
                  bgColor: sh_colorPrimary2, radius: 22, showShadow: true),
              margin: EdgeInsets.fromLTRB(12,0,12,6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  tabItem(0, myimg,myimg_home, 'Home'),
                  tabItem(1, sh_setting,sh_setting_dark, 'Setting'),
                  tabItem(2, sh_account,sh_account_dark, 'Account'),
                ],
              ),
            ),
          )
        ],
      ),
    )
  ],
),
      )

    );
  }
  Widget tabItem(var pos, var icon,var icon2, var title) {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: () async {
          if (pos == 2) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? userid = prefs.getString('UserId');
            if (userid != null && userid != '') {
              widget.selectedTab = pos;
              setState(() {});
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => LoginScreen(screen_name: 'ShHomeScreen'),
              //   ),
              // );
            }
          } else if (pos == 3) {
            widget.selectedTab = pos;
            setState(() {});
          } else if (pos == 0) {
            widget.selectedTab = pos;
            setState(() {});
          } else if (pos == 1) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? userid = prefs.getString('UserId');
            if (userid != null && userid != '') {
              widget.selectedTab = pos;
              setState(() {});
            } else {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ShSignIn(screen_name: 'ShHomeScreen'),
              //   ),
              // );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );

            }
          }
        },
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: boxDecoration(
              bgColor: sh_colorPrimary2, radius: 22, showShadow: false),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
//              SvgPicture.asset(icon,
//                  width: 24,
//                  height: 24,
//                  color: widget.selectedTab == pos ? sh_colorPrimary : sh_app_black),
              Image.asset(widget.selectedTab == pos ? icon2 :icon,
                  width: 48,
                  height: 48,
                  color: widget.selectedTab == pos ? sh_white : sh_white),
              // SizedBox(
              //   height: 4.0,
              // ),
              // Text(
              //   title,
              //   style: TextStyle(
              //       color: widget.selectedTab == pos ? sh_white : sh_app_black,
              //       fontSize: 10.0),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabItem2(var pos, var icon,var icon2, var title) {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: () async {
          if (pos == 2) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? userid = prefs.getString('UserId');
            if (userid != null && userid != '') {
              widget.selectedTab = pos;
              setState(() {});
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => LoginScreen(screen_name: 'ShHomeScreen'),
              //   ),
              // );
            }
          } else if (pos == 3) {
            widget.selectedTab = pos;
            setState(() {});
          } else if (pos == 0) {
            widget.selectedTab = pos;
            setState(() {});
          } else if (pos == 1) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? userid = prefs.getString('UserId');
            if (userid != null && userid != '') {
              widget.selectedTab = pos;
              setState(() {});
            } else {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ShSignIn(screen_name: 'ShHomeScreen'),
              //   ),
              // );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );

            }
          }
        },
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: widget.selectedTab == pos
              ? BoxDecoration(shape: BoxShape.rectangle, color: sh_app_background)
              : BoxDecoration(
              shape: BoxShape.rectangle, color: sh_app_background),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
//              SvgPicture.asset(icon,
//                  width: 24,
//                  height: 24,
//                  color: widget.selectedTab == pos ? sh_colorPrimary : sh_app_black),
              Image.asset(widget.selectedTab == pos ? icon2 :icon,
                  width: 28,
                  height: 28,
                  color: widget.selectedTab == pos ? sh_app_txt_color : sh_app_txt_color),
              // SizedBox(
              //   height: 4.0,
              // ),
              // Text(
              //   title,
              //   style: TextStyle(
              //       color: widget.selectedTab == pos ? sh_white : sh_app_black,
              //       fontSize: 10.0),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabItem3(var pos, var icon,var icon2, var title) {
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: () async {
          if (pos == 2) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? userid = prefs.getString('UserId');
            if (userid != null && userid != '') {
              widget.selectedTab = pos;
              setState(() {});
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => LoginScreen(screen_name: 'ShHomeScreen'),
              //   ),
              // );
            }
          } else if (pos == 3) {
            widget.selectedTab = pos;
            setState(() {});
          } else if (pos == 0) {
            widget.selectedTab = pos;
            setState(() {});
          } else if (pos == 1) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? userid = prefs.getString('UserId');
            if (userid != null && userid != '') {
              widget.selectedTab = pos;
              setState(() {});
            } else {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ShSignIn(screen_name: 'ShHomeScreen'),
              //   ),
              // );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );

            }
          }
        },
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: widget.selectedTab == pos
              ? BoxDecoration(shape: BoxShape.rectangle, color: sh_app_background)
              : BoxDecoration(
              shape: BoxShape.rectangle, color: sh_app_background),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
//              SvgPicture.asset(icon,
//                  width: 24,
//                  height: 24,
//                  color: widget.selectedTab == pos ? sh_colorPrimary : sh_app_black),
              Image.asset(widget.selectedTab == pos ? icon2 :icon,
                  width: 28,
                  height: 28,
                  color: widget.selectedTab == pos ? sh_app_txt_color : sh_app_txt_color),
              // SizedBox(
              //   height: 4.0,
              // ),
              // Text(
              //   title,
              //   style: TextStyle(
              //       color: widget.selectedTab == pos ? sh_white : sh_app_black,
              //       fontSize: 10.0),
              // ),
            ],
          ),
        ),
      ),
    );
  }

}


class T2Drawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return T2DrawerState();
  }
}

class T2DrawerState extends State<T2Drawer> {
  var selectedItem = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,

      child: Drawer(
        elevation: 8,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: sh_white,
            child: Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 70, right: 20),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                      decoration: new BoxDecoration(color: sh_colorPrimary, borderRadius: new BorderRadius.only(bottomRight: const Radius.circular(24.0), topRight: const Radius.circular(24.0))),
                      /*User Profile*/
                      child: Row(
                        children: <Widget>[
                          // CircleAvatar(backgroundImage: AssetImage(t2_profile), radius: 40),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  text("t2_user_name", textColor: sh_white, fontFamily: fontBold, fontSize: textSizeNormal),
                                  SizedBox(height: 8),
                                  text("t2_user_email", textColor: sh_white, fontSize: textSizeMedium),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
                SizedBox(height: 30),
                getDrawerItem(myimg, t2_lbl_profile, 1),
                getDrawerItem(myimg, sh_lbl_my_orders, 2),
                getDrawerItem(myimg, sh_lbl_my_address, 3),
                getDrawerItem(myimg, t2_lbl_settings, 4),
                getDrawerItem(myimg, t2_lbl_sign_out, 5),
                SizedBox(height: 30),
                Divider(color: sh_view_color, height: 1),
                SizedBox(height: 30),
                getDrawerItem(myimg, sh_lbl_terms, 6),
                getDrawerItem(myimg, t2_lbl_help_and_feedback, 7),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getDrawerItem(String icon, String name, int pos) {
    return GestureDetector(
      onTap: () async{
        toast(pos.toString());
        if(pos==1){
         launchScreen(context, MyProfileScreen.tag);
        }else if(pos==2){
          launchScreen(context, OrderListScreen.tag);
        }else if(pos==3){
          launchScreen(context, AddressListScreen.tag);
        }else if(pos==5){
          SharedPreferences prefs =
          await SharedPreferences.getInstance();
          // String UserId = prefs.getString('UserId');
          prefs.setString('final_token', '');
          prefs.setString('token', '');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    LoginScreen()),
            ModalRoute.withName('/LoginScreen'),
          );
        }else if(pos==6){
          launchScreen(context, TermsConditionScreen.tag);
        }else if(pos==7){
          launchScreen(context, CreateProductScreen.tag);
        }else {
          setState(() {
            selectedItem = pos;
          });
        }
      },
      child: Container(
        color: selectedItem == pos ? t2_colorPrimaryLight : sh_white,
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: <Widget>[
            Image.asset(myimg, width: 20, height: 20),
            SizedBox(width: 20),
            text(name, textColor: selectedItem == pos ? sh_colorPrimary : sh_textColorPrimary, fontSize: textSizeLargeMedium, fontFamily: fontMedium)
          ],
        ),
      ),
    );
  }
}

