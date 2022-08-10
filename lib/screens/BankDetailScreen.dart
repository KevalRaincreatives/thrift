import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/ViewProModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';

class BankDetailScreen extends StatefulWidget {
  static String tag = '/BankDetailScreen';

  const BankDetailScreen({Key? key}) : super(key: key);

  @override
  _BankDetailScreenState createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends State<BankDetailScreen> {
  var accountNameCont = TextEditingController();
  var bankNameCont = TextEditingController();
  var accountNumberCont = TextEditingController();
  var otherCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? is_store_owner;
  XFile? _image;
  String fnl_img =
      'https://secure.gravatar.com/avatar/598b1f668254d0f7097133846aa32daf?s=96&d=mm&r=g';
  final picker = ImagePicker();
  ViewProModel? viewProModel;
  Future<ViewProModel?>? ViewProfilePicMain;
  Future<String?>? fetchaddMain;

  @override
  void initState() {
    super.initState();
    ViewProfilePicMain = ViewProfilePic();
    fetchaddMain = fetchadd();
  }


  Future<String?> fetchadd() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      is_store_owner = prefs.getString('is_store_owner');
      return is_store_owner;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<ViewProModel?> ViewProfilePic() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };

      final msg = jsonEncode({
        "customer_id": UserId,
      });
      print(msg);

      Response response = await post(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/v3/view_profile_picture'),
          headers: headers,
          body: msg);
      print('Response body: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      viewProModel = new ViewProModel.fromJson(jsonResponse);

      // fnl_img = viewProModel!.profilePicture!;
      accountNumberCont.text=viewProModel!.accountNumber.toString();
      accountNameCont.text=viewProModel!.nameOfAccount.toString();
      bankNameCont.text=viewProModel!.nameOfBank.toString();
      otherCont.text=viewProModel!.otherDetails.toString();

      return viewProModel;
    } catch (e) {
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print('caught error $e');
    }
  }

  int? cart_count;

  Future<String?> fetchtotal() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('cart_count') != null) {
        cart_count = prefs.getInt('cart_count');
      } else {
        cart_count = 0;
      }

      return '';
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<String?> UploadPic() async {
    EasyLoading.show(status: 'Updating...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };


      final msg = jsonEncode({
        "name_of_account": accountNameCont.text,
        "account_number": accountNumberCont.text,
        "name_of_bank": bankNameCont.text,
        "other_details": otherCont.text,
        "customer_id":UserId
      });
      // print(fileName);

      Response response = await post(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/v3/update_account_details'),
          headers: headers,
          body: msg);
      print('Response body: ${response.body}');
      EasyLoading.dismiss();
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');

      toast('Updated');
      Navigator.pop(context);
      // order_det_model = new OrderDetailModel.fromJson(jsonResponse);
      return null;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final node = FocusScope.of(context);

    BadgeCount() {
      if (cart_count == 0) {
        return Image.asset(
          sh_new_cart,
          height: 50,
          width: 50,
          fit: BoxFit.fill,
          color: sh_white,
        );
      } else {
        return Badge(
          position: BadgePosition.topEnd(top: 4, end: 6),
          badgeContent: Text(
            cart_count.toString(),
            style: TextStyle(color: sh_white),
          ),
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
          "Banking Information",
          style:
              TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          GestureDetector(
            onTap: () async {
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
            height: height,
            width: width,
            color: sh_white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Container(
                        width: width * .7,
                        child: FutureBuilder<ViewProModel?>(
                          future: ViewProfilePicMain,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  TextFormField(
                                    onEditingComplete: () =>
                                        node.nextFocus(),
                                    controller: accountNameCont,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Please Enter Name of account';
                                      }
                                      return null;
                                    },
                                    cursorColor: sh_colorPrimary2,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                                      hintText: "Name of account",
                                      hintStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                                      labelText: "Name of account",
                                      labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Bold'),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
                                      ),
                                    ),
                                    maxLines: 1,
                                    style: TextStyle(color: sh_black,fontFamily: 'Bold'),
                                  ),
                                  SizedBox(height: 16,),
                                  TextFormField(
                                    onEditingComplete: () =>
                                        node.nextFocus(),
                                    controller: accountNumberCont,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Please Enter Account number';
                                      }
                                      return null;
                                    },
                                    cursorColor: sh_colorPrimary2,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                                      hintText: "Account number",
                                      hintStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                                      labelText: "Account number",
                                      labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Bold'),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
                                      ),
                                    ),
                                    maxLines: 1,
                                    style: TextStyle(color: sh_black,fontFamily: 'Bold'),
                                  ),
                                  SizedBox(height: 16,),
                                  TextFormField(
                                    onEditingComplete: () =>
                                        node.nextFocus(),
                                    controller: bankNameCont,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Please Enter Name of Bank';
                                      }
                                      return null;
                                    },
                                    cursorColor: sh_app_txt_color,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                                      hintText: "Name of Bank",
                                      hintStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                                      labelText: "Name of Bank",
                                      labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Bold'),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
                                      ),
                                    ),
                                    maxLines: 1,
                                    style: TextStyle(color: sh_black,fontFamily: 'Bold'),
                                  ),
                                  SizedBox(height: 16,),
                                  TextFormField(
                                    onEditingComplete: () =>
                                        node.nextFocus(),
                                    controller: otherCont,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Please Enter Other Details';
                                      }
                                      return null;
                                    },
                                    cursorColor: sh_app_txt_color,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                                      hintText: "Other Details",
                                      hintStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                                      labelText: "Other Details",
                                      labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Bold'),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
                                      ),
                                    ),
                                    maxLines: 1,
                                    style: TextStyle(color: sh_black,fontFamily: 'Bold'),
                                  ),
                                  SizedBox(height: 36,),
                                  InkWell(
                                    onTap: () async {
                                      UploadPic();
                                      // launchScreen(context, ChangePasswordScreen.tag);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*.7,
                                      padding: EdgeInsets.only(
                                          top: 6, bottom: 10),
                                      decoration: boxDecoration(
                                          bgColor: sh_btn_color, radius: 10, showShadow: true),
                                      child: text("Update",
                                          fontSize: 16.0,
                                          textColor: sh_colorPrimary2,
                                          isCentered: true,
                                          fontFamily: 'Bold'),
                                    ),
                                  ),

                                ],
                              );
                            }
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              direction: ShimmerDirection.ltr,
                              child: Container(
                                width: width,
                                padding: EdgeInsets.fromLTRB(12,12,50,12),
                                child: Column(
                                  children: [
                                    Container(
                                        child: InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                18.0, 12, 12, 12),
                                            child:                             Container(
                                              width: double.infinity,
                                              height: 12.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                    SizedBox(height: 10,),
                                    Container(
                                        child: InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                18.0, 12, 12, 12),
                                            child:                             Container(
                                              width: double.infinity,
                                              height: 12.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                    SizedBox(height: 10,),
                                    Container(
                                        child: InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                18.0, 12, 12, 12),
                                            child:                             Container(
                                              width: double.infinity,
                                              height: 12.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                    SizedBox(height: 10,),
                                    Container(
                                        child: InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                18.0, 12, 12, 12),
                                            child:                             Container(
                                              width: double.infinity,
                                              height: 12.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                    SizedBox(height: 10,),
                                    Container(
                                        child: InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                18.0, 12, 12, 12),
                                            child:                             Container(
                                              width: double.infinity,
                                              height: 12.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),

                              ),
                            );
                          },
                        )),
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
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, spacing_middle4, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6.0, 2, 6, 2),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 36,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        "Banking Information",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 45,
                            fontFamily: 'Cursive'),
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

    return Scaffold(
      body: SafeArea(child: setUserForm()),
    );
  }
}
