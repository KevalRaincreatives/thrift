import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/SignUpErrorNewModel.dart';
import 'package:thrift/model/SignUpNewModel.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

class SignUpScreen extends StatefulWidget {
  static String tag='/SignUpScreen';
  final String? country_code,fnlNumber;

  SignUpScreen({this.country_code,this.fnlNumber});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var firstNameCont = TextEditingController();
  var lastNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var passwordCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  SignUpNewModel? signup_model;
  SignUpErrorNewModel? signup_error_model;



  Future<SignUpNewModel?> getSetting() async {
    // Dialogs.showLoadingDialog(context, _keyLoader);
    EasyLoading.show(status: 'Loading...');
    try {
      String first = firstNameCont.text;
      String last = lastNameCont.text;
      String username = emailCont.text;
      String email = emailCont.text;
      String password = passwordCont.text;
      String phone=widget.fnlNumber!;
      String country_code=widget.country_code!;

      Map<String, String> headers = {'Content-Type': 'application/json'};

      // Response response = await get(
      //   'http://54.245.123.190/gotspotz/wp-json/wooapp/v3/registration?first_name=$first&last_name=$last&username=$username&email=$email&phone=$phone&password=$password',
      //   headers: headers
      // );
      // dynamic response = await http.post(
      //     Uri.parse('https://encros.rcstaging.co.in/wp-json/wooapp/v3/registration'),
      //     body: {
      //       "first_name": first,
      //       "last_name": last,
      //       "username": username,
      //       "email": email,
      //       "phone": phone,
      //       "phone_code":country_code,
      //       "password": password
      //       // "country_code":country_code
      //     });
      final msg = jsonEncode({              "first_name": first,
      "last_name": last,
      "username": username,
      "email": email,
      "phone": phone,
      "phone_code":country_code,
      "password": password
      });


      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.post(
            Uri.parse(
                '${Url.BASE_URL}wp-json/wooapp/v3/registration'),
            headers: headers,
            body: msg);
      } finally {
        client.close();
      }


      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      // signup_model = new SignUpModel.fromJson(jsonResponse);
      signup_model = new SignUpNewModel.fromJson(jsonResponse);
      if(signup_model!.status=='Yes'){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString('Login', "Yes");
        // prefs.setString('login_email', email);
        // prefs.setString('login_pass', password);
        // prefs.setString('login_name', first);
        // getLogin();
        prefs.setString('Login', "Yes");
        prefs.setString('login_email', email);
        prefs.setString('login_pass', password);
        prefs.setString('login_name', first);
        // prefs.setString('login_secret', signup_model!.secret!);
        toast('Success');
        // getLogin();
        EasyLoading.dismiss();
        launchScreen(context, LoginScreen.tag);

        // launchScreen(context, T2Dialog.tag);
      }else{
        EasyLoading.dismiss();
        signup_error_model= new SignUpErrorNewModel.fromJson(jsonResponse);
        toast(signup_error_model!.msg!);
      }

      return null;
    } catch (e) {
      EasyLoading.dismiss();
//      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 68),
                    Container(
                      width: 99,
                      height: 99,
                      child: Container(
                        width: 99,
                        height: 99,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(96),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 25,
                        ),
                        child: Opacity(
                          opacity: 0.50,
                          child: Container(
                            width: 47,
                            height: 49,
                            color: sh_colorPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 35),
                    Container(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            color: Colors.white,
                            boxShadow: [BoxShadow(
                              color: sh_app_blue,
                              blurRadius: 1.0,
                            ),]
                        ),
                        padding: const EdgeInsets.only(
                          top: 35,
                          bottom: 53,
                        ),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Create an Account",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontFamily: "Lato",
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    SizedBox(
                                      width: 301,
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Color(0xaf000000),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15.88),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      autofocus: false,
                                      style: TextStyle(
                                        color: sh_app_black,
                                        fontSize: textSizeMedium,
                                        fontFamily: "Lato",
                                        fontWeight: FontWeight.w600,
                                      ),
                                      controller: firstNameCont,
                                      textCapitalization:
                                      TextCapitalization.words,
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          return 'Please Enter Password';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: sh_editText_background,
                                        focusColor:
                                        sh_editText_background_active,
                                        hintStyle: TextStyle(
                                            color: sh_textColorSecondary,
                                            fontFamily: fontRegular,
                                            fontSize: textSizeMedium),
                                        hintText: "First Name",
                                        contentPadding: EdgeInsets.fromLTRB(
                                            20.0, 18.0, 20.0, 18.0),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(4.0),
                                            borderSide: BorderSide(
                                                color: sh_app_blue,
                                                width: 0.4)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(4.0),
                                            borderSide: BorderSide(
                                                color: sh_app_blue,
                                                width: 0.2)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: spacing_standard_new,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      autofocus: false,
                                      style: TextStyle(
                                        color: sh_app_black,
                                        fontSize: textSizeMedium,
                                        fontFamily: "Lato",
                                        fontWeight: FontWeight.w600,
                                      ),
                                      controller: lastNameCont,
                                      textCapitalization:
                                      TextCapitalization.words,
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          return 'Please Enter Password';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: sh_editText_background,
                                        focusColor:
                                        sh_editText_background_active,
                                        hintStyle: TextStyle(
                                            color: sh_textColorSecondary,
                                            fontFamily: fontRegular,
                                            fontSize: textSizeMedium),
                                        hintText: "Last Name",
                                        contentPadding: EdgeInsets.fromLTRB(
                                            20.0, 18.0, 20.0, 18.0),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(4.0),
                                            borderSide: BorderSide(
                                                color: sh_app_blue,
                                                width: 0.4)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(4.0),
                                            borderSide: BorderSide(
                                                color: sh_app_blue,
                                                width: 0.2)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 15.88),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                style: TextStyle(
                                  color: sh_app_black,
                                  fontSize: textSizeMedium,
                                  fontFamily: "Lato",
                                  fontWeight: FontWeight.w600,
                                ),
                                controller: emailCont,
                                textCapitalization:
                                TextCapitalization.words,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: sh_editText_background,
                                  focusColor:
                                  sh_editText_background_active,
                                  hintStyle: TextStyle(
                                      color: sh_textColorSecondary,
                                      fontFamily: fontRegular,
                                      fontSize: textSizeMedium),
                                  hintText: "Email",
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 18.0, 20.0, 18.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(4.0),
                                      borderSide: BorderSide(
                                          color: sh_app_blue,
                                          width: 0.4)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(4.0),
                                      borderSide: BorderSide(
                                          color: sh_app_blue,
                                          width: 0.2)),                                          ),
                              ),
                              SizedBox(height: 15.88),
                              TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp('[&]')),
                                ],
                                obscureText: !this._showPassword,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                style: TextStyle(
                                  color: sh_app_black,
                                  fontSize: textSizeMedium,
                                  fontFamily: "Lato",
                                  fontWeight: FontWeight.w600,),
                                controller: passwordCont,
                                textCapitalization: TextCapitalization.words,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: sh_editText_background,
                                  focusColor: sh_editText_background_active,
                                  hintStyle: TextStyle(
                                      color: sh_textColorSecondary,
                                      fontFamily: fontRegular,
                                      fontSize: textSizeMedium),
                                  hintText: "Password",
                                  contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 18.0),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(4.0),
                                      borderSide: BorderSide(
                                          color: sh_app_blue,
                                          width: 0.4)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(4.0),
                                      borderSide: BorderSide(
                                          color: sh_app_blue,
                                          width: 0.2)),                                            suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: this._showPassword ? sh_colorPrimary : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(
                                            () => this._showPassword = !this._showPassword);
                                  },
                                ),
                                ),
                              ),
                              SizedBox(height: 15.88),
                              Container(
                                height: 60,
                                child: InkWell(
                                  onTap: () async{
                                    getSetting();
                                  },
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(4),
                                      color: t6colorPrimary,
                                    ),
                                    padding: const EdgeInsets.only(
                                      left: 35,
                                      right: 26,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "SIGN UP",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.88),
                              SizedBox(
                                width: 315,
                                child: Text(
                                  "By tap Sign Up button you accept terms and privacy this app",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xb2000000),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.88),
                              Container(
                                height: 1,
                                color: Color(0xffebebeb),
                              ),
                              SizedBox(height: 5.88),
                              Container(
                                height: 60,
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(76),
                                    color: Color(0x00008b61),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back,
                                        color: sh_app_blue,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Back to Sign In Page",
                                        style: TextStyle(
                                          color: sh_app_blue,
                                          fontSize: 18,
                                          fontFamily: "Lato",
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
