import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:thrift/model/ProfileUpdateModel.dart';
import 'package:thrift/screens/ChangePasswordScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/NewNumberScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:thrift/utils/ShStrings.dart';

class MyProfileScreen extends StatefulWidget {
  static String tag='/MyProfileScreen';
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  ProfileModel? profileModel;
  var firstNameCont = TextEditingController();
  var lastNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var phoneCont = TextEditingController();
  ProfileUpdateModel? profileUpdateModel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchDetails();

  }

  getLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', "");

    Route route = MaterialPageRoute(
        builder: (context) => LoginScreen());
    Navigator.pushReplacement(context, route);


  }

  Future<ProfileModel?> fetchDetails() async {
//    Dialogs.showLoadingDialog(context, _keyLoader);
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      print("my tokens"+token!);


      // final msg = jsonEncode({"ID": UserId});

      // Response response = await post(
      //     'http://zoo.webstylze.com/wp-json/v3/viewprofile',
      //     headers: headers,
      //     body: msg);

      print('Token : ${token}');
      // final response = await http.get("https://encros.rcstaging.co.in/wp-json/wooapp/v3/profile",
      //   // headers: {HttpHeaders.authorizationHeader: "Basic $token"},
      //     headers: {
      //   'Content-Type': 'application/json',
      //   'Accept': 'application/json',
      //   'Authorization': 'Bearer $token',
      // }
      // );

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Response response = await get(
      //   'https://encros.rcstaging.co.in/wp-json/wooapp/v3/profile',
      //   headers: headers
      // );

      var response =await http.get(Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/profile"),
          headers: headers);


      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      EasyLoading.dismiss();

      profileModel = new ProfileModel.fromJson(jsonResponse);
      // if (new_car == 0) {
      firstNameCont.text = profileModel!.data!.firstName!;
      lastNameCont.text = profileModel!.data!.lastName!;
      emailCont.text = profileModel!.data!.userEmail!;
      phoneCont.text ="+"+
          profileModel!.data!.phoneCode! + profileModel!.data!.phone!;
      prefs.setString('pro_first', profileModel!.data!.firstName!);
      prefs.setString('pro_last', profileModel!.data!.lastName!);
      prefs.setString('pro_email', profileModel!.data!.userEmail!);

      //   addressCont2.text = profileModel.shipping.address2;
      //   cityCont.text = profileModel.shipping.city;
      //   pinCodeCont.text = profileModel.shipping.postcode;
      //   stateCont.text = profileModel.shipping.state;
      //   countryCont.text = profileModel.shipping.country;
      //   parishCont.text = profileModel.shipping.state;
      //
      //   countryname = profileModel.shipping.country;
      //   statename = profileModel.shipping.state;
      // }

      print('sucess');

      return profileModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<ProfileUpdateModel?> getUpdate() async {
    EasyLoading.show(status: 'Please wait...');
    try {

      String email = emailCont.text;
      String firstname = firstNameCont.text;
      String lastname = lastNameCont.text;
      String phone = profileModel!.data!.phone.toString();
      String country_code = profileModel!.data!.phoneCode.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({
        "user_email": email,
        "display_name":email,
        "user_url":"",
        "first_name": firstname,
        "last_name": lastname,
        "phone": phone,
        "phone_code":country_code
      });

      // String body = json.encode(data2);

      http.Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/edit_profile'),
          headers: headers,
          body: msg);
      EasyLoading.dismiss();

//
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      profileUpdateModel = new ProfileUpdateModel.fromJson(jsonResponse);
      toast(profileUpdateModel!.msg);

      // prefs.setString('login_name', firstname);

      return profileUpdateModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<String?> BecameSeller() async {
    EasyLoading.show(status: 'Please wait...');
    try {

      // String email = emailCont.text;
      // String firstname = firstNameCont.text;
      // String lastname = lastNameCont.text;
      // String phone = profileModel!.data!.phone.toString();
      // String country_code = profileModel!.data!.phoneCode.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({
        "shop_name": "Happy",
        "billing_first_name":"keval2",
        "billing_last_name":"Panchal2",
        "billing_email": "keval@gmail.com",
        "billing_phone": "7878392120",
        "billing_address_1": "Hill Colony",
        "billing_city":"Surat",
        "billing_state":"Gujarat",
        "billing_postcode":"393430",
        "billing_country":"India",
        "shipping_first_name":"keval2",
        "shipping_last_name":"Panchal2",
        "shipping_email": "keval@gmail.com",
        "shipping_phone": "7878392120",
        "shipping_address_1": "Hill Colony",
        "shipping_city":"Surat",
        "shipping_state":"Gujarat",
        "shipping_postcode":"393430",
        "shipping_country":"India",
      });

      // String body = json.encode(data2);

      http.Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/become_a_seller'),
          headers: headers,
          body: msg);
      EasyLoading.dismiss();

//
      final jsonResponse = json.decode(response.body);
      print('not json2 $jsonResponse');
      // profileUpdateModel = new ProfileUpdateModel.fromJson(jsonResponse);


      // prefs.setString('login_name', firstname);

      return null;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<bool> _onWillPop() async{
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(
    //       builder: (BuildContext context) => DashboardScreen()),
    //   ModalRoute.withName('/DashboardScreen'),
    // );
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
    final node = FocusScope.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sh_app_bar,
        title: text("My Profile",
            textColor: sh_textColorPrimary,
            fontSize: textSizeNormal,
            fontFamily: fontBold),
        iconTheme: IconThemeData(color: sh_textColorPrimary),
      ),
      body: Container(
        height: height,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20,),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                            CircleAvatar(
                              backgroundImage: AssetImage(sh_no_img),
                              radius: 50,
                            ),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: sh_white,
                            ),
                            width: 30,
                            height: 30,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(spacing_standard),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(spacing_standard_new),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: editTextStyle(sh_hint_first_name, firstNameCont, node,"Please Enter First Name",sh_white,sh_view_color),
                                ),
                                SizedBox(
                                  width: spacing_standard_new,
                                ),
                                Expanded(
                                  child: editTextStyle(sh_hint_last_name, lastNameCont, node,"Please Enter Last Name",sh_white,sh_view_color),
                                )
                              ],
                            ),
                            SizedBox(
                              height: spacing_standard_new,
                            ),
                            // editTextStylePhone(sh_hint_mobile_no, phoneCont, node, context),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Stack(
                                children: [
                                  TextFormField(
                                    readOnly: true,
                                    maxLines: 1,
                                    controller: phoneCont,
                                    onEditingComplete: () => node.nextFocus(),
                                    style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),

                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
                                      hintText: sh_hint_mobile_no,
                                      filled: true,
                                      fillColor: sh_white,
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide:  BorderSide(color: sh_view_color, width: 1.0)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide:  BorderSide(color: sh_view_color, width: 1.0)),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async{
                                      launchScreen(context, NewNumberScreen.tag);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 14, 14, 0),
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "Change",
                                          style: TextStyle(
                                              color: sh_app_blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Regular'),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: spacing_standard_new,
                            ),
                            editTextStyle(sh_hint_email, emailCont, node,"Please Enter Email",sh_white,sh_view_color),
                            SizedBox(
                              height: spacing_standard_new,
                            ),
                            InkWell(
                              onTap: () async{
                                if (_formKey.currentState!.validate()) {
                                  // TODO submit
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  getUpdate();

                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(top: spacing_middle, bottom: spacing_middle),
                                decoration: boxDecoration(bgColor: sh_colorPrimary, radius: 50, showShadow: true),
                                child: text(sh_lbl_save_profile, textColor: sh_white, isCentered: true,fontFamily: 'Bold'),
                              ),
                            ),
                            SizedBox(
                              height: spacing_standard_new,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              // height: double.infinity,
                              child: MaterialButton(
                                padding: EdgeInsets.all(spacing_standard),
                                child: text(sh_lbl_change_pswd,
                                    fontSize: textSizeNormal,
                                    fontFamily: fontMedium,
                                    textColor: sh_colorPrimary),
                                textColor: sh_white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(40.0),
                                    side: BorderSide(color: sh_colorPrimary, width: 1)),
                                color: sh_white,
                                onPressed: () async{
                                  launchScreen(context, ChangePasswordScreen.tag);},
                              ),
                            ),
                            SizedBox(
                              height: spacing_standard_new,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              // height: double.infinity,
                              child: MaterialButton(
                                padding: EdgeInsets.all(spacing_standard),
                                child: text("Beacme a Seller",
                                    fontSize: textSizeNormal,
                                    fontFamily: fontMedium,
                                    textColor: sh_colorPrimary),
                                textColor: sh_white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(40.0),
                                    side: BorderSide(color: sh_colorPrimary, width: 1)),
                                color: sh_white,
                                onPressed: () async{
                                  BecameSeller();
                                  },
                              ),
                            ),

                            // SizedBox(
                            //   width: double.infinity,
                            //   height: 50,
                            //   // height: double.infinity,
                            //   child: MaterialButton(
                            //     padding: EdgeInsets.all(spacing_standard),
                            //     child: text("Logout",
                            //         fontSize: textSizeNormal,
                            //         fontFamily: fontMedium,
                            //         textColor: appBtnColor),
                            //     textColor: sh_white,
                            //     shape: RoundedRectangleBorder(
                            //         borderRadius: new BorderRadius.circular(40.0),
                            //         side: BorderSide(color: appBtnColor!, width: 1)),
                            //     color: sh_white,
                            //     onPressed: () async
                            //     {
                            //       SendAppData();
                            //       getLogout();},
                            //   ),
                            // )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
Padding editTextStyle(var hintText, var cn, final node,String alert,Color sh_white,Color sh_view_color) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      controller: cn,
      onEditingComplete: () => node.nextFocus(),
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      validator: (text) {
        if (text == null || text.isEmpty) {
          return alert;
        }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        hintText: hintText,
        filled: true,
        fillColor: sh_white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide:  BorderSide(color: sh_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide:  BorderSide(color: sh_view_color, width: 1.0)),
      ),
    ),
  );
}

Padding editTextStylePhone(var hintText, var cn, final node, var ctx,int sh_white,int sh_view_color,int sh_app_blue) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: Stack(
      children: [
        TextFormField(
          readOnly: true,
          maxLines: 1,
          controller: cn,
          onEditingComplete: () => node.nextFocus(),
          style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),

          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
            hintText: hintText,
            filled: true,
            fillColor: Color(sh_white),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: BorderSide(color: Color(sh_view_color), width: 1.0)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide:  BorderSide(color: Color(sh_view_color), width: 1.0)),
          ),
        ),
        GestureDetector(
          onTap: () async{
            launchScreen(ctx, NewNumberScreen.tag);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 14, 0),
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                "Change",
                style: TextStyle(
                    color: Color(sh_app_blue),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Regular'),
              ),
            ),
          ),
        )
      ],
    ),
  );
}


