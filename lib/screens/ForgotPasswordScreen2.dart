import 'dart:convert';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:thrift/model/ForgotModel.dart';
import 'package:thrift/screens/ResetPasswordScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShStrings.dart';

class ForgotPasswordScreen extends StatefulWidget {  static String tag='/ForgotPasswordScreen';
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  var emailCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  ForgotModel? numberCheckModel;

  Future<ForgotModel?> getUpdate() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      String email = emailCont.text;
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final msg = jsonEncode({"email": email});

      Response response = await post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/wooapp_reset_password'),
          headers: headers,
          body: msg);

      final jsonResponse = json.decode(response.body);
      print('forgot password $jsonResponse');
      numberCheckModel = new ForgotModel.fromJson(jsonResponse);
      EasyLoading.dismiss();
      if (numberCheckModel!.success!) {
        showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {return AlertDialog(
              title: Text('Sent'),
              content: SingleChildScrollView(
                child: Text(numberCheckModel!.msg!),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(ConfirmAction.CANCEL);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ResetPasswordScreen(emails: email)),
                    );
//                    launchScreen(context, ForgotResetPassScreen.tag);
                  },
                ),
              ],
            );}
        );
      } else {
        showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {return AlertDialog(
              title: Text('Fail'),
              content: SingleChildScrollView(
                child: Text(numberCheckModel!.msg!),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(ConfirmAction.CANCEL);

//                    launchScreen(context, ForgotResetPassScreen.tag);
                  },
                ),
              ],
            );}
        );
      }

      print('sucess');
      return numberCheckModel;
    } catch (e) {
      print('caught error $e');
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      EasyLoading.dismiss();
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
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 68),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                            SizedBox(height: 48),
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
                                      color: sh_textColorSecondary,
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
                                    children: [
                                      Container(

                                        child: Column(
                                          children: [
                                            Text(
                                              "Forgot Password",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 24,
                                                fontFamily: "ExtraBold",
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              "Please provide your registered email address to reset your password",
                                              style: TextStyle(
                                                fontFamily: 'Regular',
                                                color: Color(0xaf000000),
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 21.67),
                                      TextFormField(
                                        keyboardType: TextInputType.text,
                                        autofocus: false,
                                        style: TextStyle(
                                          color: sh_app_black,
                                          fontSize: textSizeMedium,
                                          fontFamily: "Regular",
                                          fontWeight: FontWeight.w600,
                                        ),
                                        controller: emailCont,
                                        textCapitalization:
                                        TextCapitalization.words,
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Please Enter Email';
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
                                              fontFamily: 'Regular',
                                              fontSize: textSizeMedium),
                                          hintText: sh_hint_email,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              20.0, 18.0, 20.0, 18.0),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4.0),
                                              borderSide: BorderSide(
                                                  color: sh_textColorSecondary,
                                                  width: 0.4)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(4.0),
                                              borderSide: BorderSide(
                                                  color: sh_textColorSecondary,
                                                  width: 0.2)),
                                        ),
                                      ),
                                      SizedBox(height: 21.67),
                                      Container(
                                        height: 60,
                                        child: GestureDetector(
                                          onTap: () {
                                            getUpdate();
                                            // launchScreen(context, ResetPasswordScreen.tag);
                                          },
                                          child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(4),
                                              color: sh_colorPrimary,
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
                                                  "CONTINUE",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontFamily: "Bold",
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
                                      SizedBox(height: 21.67),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
