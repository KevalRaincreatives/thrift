import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/CheckUserModel.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:thrift/model/ProfileUpdateModel.dart';
import 'package:thrift/screens/AddressListScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/ChangePasswordScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/MyProfileScreen.dart';
import 'package:thrift/screens/NewNumberScreen.dart';
import 'package:thrift/screens/OrderListScreen.dart';
import 'package:thrift/screens/ProfileScreen.dart';
import 'package:thrift/screens/SellerEditProfileScreen.dart';
import 'package:thrift/screens/VendorOrderListScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:badges/badges.dart';

class AccountFragment extends StatefulWidget {
  const AccountFragment({Key? key}) : super(key: key);

  @override
  _AccountFragmentState createState() => _AccountFragmentState();
}

class _AccountFragmentState extends State<AccountFragment> {
  CheckUserModel? checkUserModel;

  @override
  void initState() {

    super.initState();

  }

  Future<CheckUserModel?> fetchUserStatus() async {

    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(Uri.parse(
        "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/check_seller_status?user_id=$UserId",)
          ,headers: headers);


      print('AccountFragment check_seller_status Response status2: ${response.statusCode}');
      print('AccountFragment check_seller_status Response body2: ${response.body}');

      final jsonResponse = json.decode(response.body);
      checkUserModel = new CheckUserModel.fromJson(jsonResponse);
      prefs.setString('is_store_owner', checkUserModel!.is_store_owner.toString());
      EasyLoading.dismiss();
      if(checkUserModel!.is_store_owner==0){
        launchScreen(context, ProfileScreen.tag);
      } else if (checkUserModel!.is_store_owner==1) {
        launchScreen(context, SellerEditProfileScreen.tag);
      } else if (checkUserModel!.is_store_owner==2) {
        launchScreen(context, ProfileScreen.tag);
      }


      return checkUserModel;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final node = FocusScope.of(context);

    BadgeCount(){
      if(cart_count==0){
        return Image.asset(
          sh_new_cart,
          height: 44,
          width: 44,
          fit: BoxFit.fill,
          color: sh_white,
        );
      }else{
        return Badge(
          position: BadgePosition.topEnd(top: 4, end: 6),
          badgeContent: Text(cart_count.toString(),style: TextStyle(color: sh_white,fontSize: 8),),
          child: Image.asset(
            sh_new_cart,
            height: 44,
            width: 44,
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
          "My Account",
          style: TextStyle(color: sh_white,fontFamily: 'TitleCursive',fontSize: 40),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          GestureDetector(
            onTap: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt("shiping_index", -2);
              prefs.setInt("payment_index", -2);
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
            height: height,
            width: width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: width,
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                            child: InkWell(
                              onTap: () async {
                                fetchUserStatus();
                                // SharedPreferences prefs = await SharedPreferences.getInstance();
                                // if (prefs.getString("is_store_owner") == '0') {
                                //   launchScreen(context, ProfileScreen.tag);
                                // } else if (prefs.getString("is_store_owner") == '1') {
                                //   launchScreen(context, SellerEditProfileScreen.tag);
                                // } else if (prefs.getString("is_store_owner") == '2') {
                                //   launchScreen(context, ProfileScreen.tag);
                                //
                                // }
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    18.0, 12, 12, 12),
                                child: Text("My Account",
                                  style: TextStyle(
                                      color: sh_colorPrimary2,
                                      fontSize: 20,
                                      fontFamily: fontSemibold),),
                              ),
                            )),
                        InkWell(
                          onTap: () {
                            launchScreen(context, OrderListScreen.tag);
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                18.0, 12, 12, 12),
                            child: Text("My Orders", style: TextStyle(
                                color: sh_colorPrimary2,
                                fontSize: 20,
                                fontFamily: fontSemibold),),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences
                                .getInstance();
                            prefs.setString('from', "address");
                            launchScreen(
                                context, AddressListScreen.tag);
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                18.0, 12, 12, 12),
                            child: Text("My Addresses",
                              style: TextStyle(color: sh_colorPrimary2,
                                  fontSize: 20,
                                  fontFamily: fontSemibold),),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences
                                .getInstance();
                            String? final_token = prefs.getString(
                                'token');
                            prefs.setString("token", "");
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => LoginScreen(),
                            //   ),
                            // );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginScreen()),
                              ModalRoute.withName('/LoginScreen'),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                18.0, 12, 12, 12),
                            child: Text("Sign Out", style: TextStyle(
                                color: sh_colorPrimary2,
                                fontSize: 20,
                                fontFamily: fontSemibold),),
                          ),
                        ),
                      ],
                    ),

                  ),


                ],
              ),
            ),
          ),
        ),
        // Positioned to take only AppBar size
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child:
          Container(
            padding: const EdgeInsets.fromLTRB(30,18,10,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(1.0,0,6,0),
                    //   child: IconButton(onPressed: () {
                    //     // Navigator.pop(context);
                    //   }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 32,)),
                    // ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,6,6,6.0),
                      child: Text("My Account",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
                    // SizedBox(width: 16,)
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
      body: SafeArea(
        child: setUserForm(),
      ),
    );
  }
}
