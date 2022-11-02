import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/retry.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:thrift/fragments/AccountFragment.dart';
import 'package:thrift/fragments/HomeFragment.dart';
import 'package:thrift/fragments/MySalesFragment.dart';
import 'package:thrift/fragments/SettingFragment.dart';
import 'package:thrift/model/CategoryModel.dart';
import 'package:thrift/model/CheckUserModel.dart';
import 'package:thrift/screens/AddressListScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/CreateProductScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/MyProfileScreen.dart';
import 'package:thrift/screens/OrderListScreen.dart';
import 'package:thrift/screens/ProductlistScreen.dart';
import 'package:thrift/screens/SplashScreen.dart';
import 'package:thrift/screens/TermsConditionScreen.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/utils/T3Dialog.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';


class DashboardScreen extends StatefulWidget {
  static String tag='/DashboardScreen';
  // const DashboardScreen({Key? key}) : super(key: key);
  var selectedTab=0;

  DashboardScreen({Key? key, required this.selectedTab}) : super(key: key);


  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin<DashboardScreen>{
  List<CategoryModel> categoryListModel = [];
  var homeFragment = HomeFragment();
  var settingFragment = SettingFragment();
  var profileFragment = AccountFragment();
  var mysalesFragment = MySalesFragment();
  var fragments;
  var selectedTab = 0;
  var title = "Home";
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  CheckUserModel? checkUserModel;
  int timer = 800, offset = 0;
  Future<String?>? fetchuserstatus;
String? is_store_owner;

  @override
  void initState() {
    super.initState();
    fetchuserstatus=fetchUserStatus();
  }
  @override
  bool get wantKeepAlive => true;


  Future<String?> fetchUserStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      is_store_owner=prefs.getString('is_store_owner');
      if(prefs.getString('is_store_owner')=='0'){
        fragments = [homeFragment, settingFragment, profileFragment];
      }
      else if (prefs.getString('is_store_owner')=='1') {
        // toast("value");
        // launchScreen(context, BecameSellerScreen.tag);
        fragments = [homeFragment, settingFragment, mysalesFragment,profileFragment];
        // Navigator.pushNamed(context, CreateProductScreen.tag).then((_) => setState(() {}));
      } else if (prefs.getString('is_store_owner')=='2') {
        fragments = [homeFragment, settingFragment, profileFragment];
      }


      return 'checkUserModel';
    } catch (e) {
      // EasyLoading.dismiss();
      print('caught error $e');
    }
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
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(


            body: StreamProvider<NetworkStatus>(
              initialData: NetworkStatus.Online,
              create: (context) =>
              NetworkStatusService().networkStatusController.stream,
              child: NetworkAwareWidget(
                onlineChild: WillPopScope(
                    onWillPop: _onWillPop,
                    child: FutureBuilder<String?>(
                      future: fetchuserstatus,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(
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
                                        child:  is_store_owner=='1' ?
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            tabItem(0, sh_homes, sh_homes_dark, 'Home'),
                                            tabItem(1, sh_setting, sh_setting_dark, 'Setting'),
                                            tabItem(2, sh_dollar, sh_dollar_dark, 'Dollar'),

                                            tabItem(3, sh_account, sh_account_dark, 'Account'),
                                          ],
                                        ) : Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            tabItem(0, sh_homes, sh_homes_dark, 'Home'),
                                            tabItem(1, sh_setting, sh_setting_dark, 'Setting'),
                                            tabItem(2, sh_account, sh_account_dark, 'Account'),
                                          ],
                                        )
                                        ,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Container(height: 30,color: sh_colorPrimary2,),
                            Container(
                                height: 130,
                                width: width,
                                child: Image.asset(sh_upper2,fit: BoxFit.fill)
                              // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
                            ),
                            Expanded(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                direction: ShimmerDirection.ltr,
                                child: Container(
                                  padding: EdgeInsets.all(40),
                                  child: GridView.builder(
                                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 200,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20),
                                      itemCount: 8,
                                      itemBuilder: (BuildContext ctx, index) {
                                        offset +=50;
                                        timer = 800 + offset;
                                        // print(timer);
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 100,
                                            width: 100,
                                            color: Colors.grey,
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )

                ),
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
            )


        );
      },
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
                  width: 25,
                  height: 25,
                  fit: BoxFit.fill,
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

