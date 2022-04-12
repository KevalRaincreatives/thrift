import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/database/CartPro.dart';
import 'package:thrift/database/database_hepler.dart';
import 'package:thrift/model/GuestCartModel.dart';
import 'package:thrift/model/ShLoginErrorNewModel.dart';
import 'package:thrift/model/ShLoginModel.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/ForgotPasswordScreen.dart';
import 'package:thrift/screens/OtpScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart' hide boxDecoration;
import 'package:thrift/utils/T6Colors.dart';
import 'package:thrift/utils/T6Strings.dart';
import 'package:thrift/utils/T6Widget.dart';
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  static String tag='/LoginScreen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<CartPro> cartPro = [];
  GuestCartModel? itModel;
  final List<GuestCartModel> itemsModel = [];


  var emailCont = TextEditingController();
  var passwordCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  ShLoginModel? cat_model;
  ShLoginErrorNewModel? err_model;

  Future<String?> CreateOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');

      print(token);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // final msg = jsonEncode({
      //   "product_id": pro_id,
      //   "variation_id":var_id
      // });
      Map msg = {
        'cart_data': itemsModel
      };




      var body = json.encode({
        "cart_data": itemsModel
      });

      // String body = json.encode(msg);
      print(body);

      var response;

      response = await http
          .post(Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/add_cart_data'), body: body,headers: headers);

      EasyLoading.dismiss();

      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');

      final allRows = await dbHelper.queryAllRows();
      cartPro.clear();
      allRows.forEach((row) => cartPro.add(CartPro.fromJson(row)));
      for (int i = 0; i < cartPro.length; i++) {
        final rowsDeleted = await dbHelper.delete(cartPro[i].id!);
      }

      launchScreen(context, DashboardScreen.tag);



      return null;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
      // return cat_model;
    }
  }

  Future<List<CartPro>> _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    cartPro.clear();
    allRows.forEach((row) => cartPro.add(CartPro.fromJson(row)));
    // _showMessageInScaffold('Query done.');
    print(cartPro.length.toString());

    if (cartPro.length > 0) {
      for (int i = 0; i < cartPro.length; i++) {

          itModel = GuestCartModel(
              product_id: cartPro[i].product_id.toString(),
              variation_id: cartPro[i].variation_id.toString(),
              variation: cartPro[i].variation_name.toString(),
              quantity: cartPro[i].quantity.toString(),
              line_subtotal: cartPro[i].line_total.toString(),
              line_total: cartPro[i].line_total.toString());
          itemsModel.add(itModel!);



      }

      CreateOrder();
    } else {
      EasyLoading.dismiss();
      // if (widget.screen_name == 'ProfileScreen') {
      //   launchScreen(context, ProfileScreen.tag);
      // }else if (widget.screen_name == 'OrderListScreen') {
      //   launchScreen(context, OrderListScreen.tag);
      // }else if (widget.screen_name == 'AddressListScreen') {
      //   launchScreen(context, AddressListScreen.tag);
      // }else{
      launchScreen(context, DashboardScreen.tag);
      // }
    }

    return cartPro;
  }

  Future<ShLoginModel?> getLogin() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      String username = emailCont.text;
      String password = passwordCont.text;

      Map data = {
        'username': username,
        'password': password,
      };
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final msg = jsonEncode({"username": username, "password": password});

      // Response response = await get(
      //     'http://zoo.webstylze.com/wp-json/v3/login?username=$username&password=$password');
      // dynamic response = await http
      //     .post(Uri.parse('https://encros.rcstaging.co.in/wp-json/wooapp/v3/login'), body: {
      //   "username": username,
      //   "password": password
      //   // "country_code":country_code
      // });

      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.post(
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/login'),
            headers: headers,
            body: msg);
      } finally {
        client.close();
      }



      final jsonResponse = json.decode(response.body);
      print('not json login$jsonResponse');
      print('Response bodylogin: ${response.body}');
      if (response.statusCode == 200) {
        EasyLoading.dismiss();

        cat_model = new ShLoginModel.fromJson(jsonResponse);
        print("cat dta$cat_model");


        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', cat_model!.data!.token.toString());
        prefs.setString('UserId', cat_model!.ID.toString());
        // prefs.setString('UserName', cat_model.userDisplayName);
        // prefs.setString('UserType', 'Normal');
        prefs.commit();

        _queryAll();
        // launchScreen(context, DashboardScreen.tag);

// toast("sucess");
        print('sucess');
      } else {
        EasyLoading.dismiss();
        err_model = new ShLoginErrorNewModel.fromJson(jsonResponse);

        toast(err_model!.message);
        // toast('Something Went Wrong');
//        print("cat dta$cat_model");

      }
      return cat_model;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final node = FocusScope.of(context);
    return Scaffold(
      backgroundColor: sh_white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: height,
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(alignment: Alignment.center, child: Text('THRIFT APP',style: TextStyle(color: sh_colorPrimary,fontSize: 28,fontFamily: 'ExtraBold'),)),
                SizedBox(
                  height: 30,
                ),
                text(t6_lbl_user_name, textColor: t6textColorPrimary),
                SizedBox(
                  height: 8,
                ),

                Container(
                  decoration: boxDecoration(radius: 12, showShadow: true, bgColor: t6white),
                  child: TextFormField(
                    onEditingComplete: () =>
                        node.nextFocus(),
                    style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
                    controller: emailCont,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Please Enter Username';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(26, 18, 4, 18),
                      hintText: t6_lbl_user_name,
                      filled: true,
                      fillColor: t6white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: t6white, width: 0.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: t6white, width: 0.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                text("Password*", textColor: t6textColorPrimary),
                SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: boxDecoration(radius: 12, showShadow: true, bgColor: t6white),
                  child: TextFormField(
                    onEditingComplete: () =>
                        node.nextFocus(),
                    style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
                    controller: passwordCont,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Please Enter Password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(26, 18, 4, 18),
                      hintText: "Password",
                      filled: true,
                      fillColor: t6white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: t6white, width: 0.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: t6white, width: 0.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async{
                    launchScreen(context,
                        ForgotPasswordScreen.tag);
                  },
                    child: Container(alignment: Alignment.topRight, child: text(t6_lbl_forgot_password))),
                SizedBox(
                  height: 16,
                ),
                T6Button(
                  textContent: t6_lbl_sign_in,
                  onPressed: () async{
                    getLogin();
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    text(t6_lbl_new_to_this_experience),
                    SizedBox(
                      width: 4,
                    ),
                    GestureDetector(child: Text(t6_lbl_sign_up, style: TextStyle(fontSize: textSizeMedium, decoration: TextDecoration.underline, color: t6form_google)), onTap: () {
                      launchScreen(context, OtpScreen.tag);
                    })
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
