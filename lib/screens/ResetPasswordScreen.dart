import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:thrift/model/ForgotModel.dart';
import 'package:thrift/screens/SplashScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

class ResetPasswordScreen extends StatefulWidget {
  static String tag='/ResetPasswordScreen';
  final String? emails;


  ResetPasswordScreen({this.emails});


  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  var emailCont = TextEditingController();
  var passwordCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  ForgotModel? numberCheckModel;

  Future<ForgotModel?> getUpdate() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      String code = emailCont.text;
      String password = passwordCont.text;
      String email = widget.emails!;
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final msg =
      jsonEncode({"email": email, "otp": code, "new_password": password});

      Response response = await post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/set_new_password'),
          headers: headers,
          body: msg);

      final jsonResponse = json.decode(response.body);
      print('ResetPasswordScreen set_new_password Response status2: ${response.statusCode}');
      print('ResetPasswordScreen set_new_password Response body2: ${response.body}');
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SplashScreen()),
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


      return numberCheckModel;
    } catch (e) {
      print('caught error $e');
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Forgot Password",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),

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
          child:   Form(
            key: _formKey,
            child: Container(
              alignment: Alignment.center,
              width: width*.75,
              padding: EdgeInsets.all(26),
              child: Column(
                children: [
                  Container(

                    child: Column(
                      children: [
                        Text(
                          "We have sent a reset code to your email.Enter it below to continue.",
                          style: TextStyle(
                            fontFamily: 'Medium',
                            color: sh_colorPrimary2,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 21.67),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          autofocus: false,
                          style: TextStyle(
                            color: sh_app_txt_color,
                            fontSize: textSizeMedium,
                            fontFamily: "Medium",
                          ),
                          controller: emailCont,
                          textCapitalization:
                          TextCapitalization.words,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please Enter Code';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: sh_btn_color,
                            focusColor:
                            sh_editText_background_active,
                            hintStyle: TextStyle(
                                color: sh_app_txt_color,
                                fontFamily: 'Medium',
                                fontSize: textSizeMedium),
                            hintText: sh_hint_main_code,
                            contentPadding: EdgeInsets.fromLTRB(
                                16, 8, 4, 8),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(22.0),
                                borderSide: BorderSide(
                                    color: sh_app_txt_color,
                                    width: 0.4)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(22.0),
                                borderSide: BorderSide(
                                    color: sh_app_txt_color,
                                    width: 0.2)),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(),
                      ),
                    ],
                  ),
                  SizedBox(height: 21.67),
                  TextFormField(
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.deny(RegExp('[&]')),
                    // ],
                    obscureText: !this._showPassword,
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    style: TextStyle(
                      color: sh_app_txt_color,
                      fontSize: textSizeMedium,
                      fontFamily: "Medium"),
                    controller: passwordCont,
                    textCapitalization: TextCapitalization.words,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Please Enter New Password';
                      }else if(!validateStructure(text)){
                        return 'Your password should not contain following\ncharacters: (){}[]|`¬¦ "£%^&*"<>:;#~-+=,';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: sh_btn_color,
                      focusColor: sh_editText_background_active,
                      hintStyle: TextStyle(
                          color: sh_app_txt_color,
                          fontFamily: 'Medium',
                          fontSize: textSizeMedium),
                      hintText: sh_hint_new_password,
                      contentPadding:
                      EdgeInsets.fromLTRB(16, 8, 4, 8),
                      focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(22.0),
                          borderSide: BorderSide(
                              color: sh_app_txt_color,
                              width: 0.4)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(22.0),
                          borderSide: BorderSide(
                              color: sh_app_txt_color,
                              width: 0.2)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.remove_red_eye,
                          color: this._showPassword ? sh_app_txt_color : Colors.grey,
                        ),
                        onPressed: () {
                          setState(
                                  () => this._showPassword = !this._showPassword);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 21.67),
                  GestureDetector(
                    onTap: () {
      if (_formKey.currentState!.validate()) {
        // launchScreen(context, HomeScreen.tag);
        getUpdate();
      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width*.7,
                      padding: EdgeInsets.only(
                          top: 6, bottom: 10),
                      decoration: boxDecoration(
                          bgColor: sh_btn_color, radius: 10, showShadow: true),
                      child: text("RESET",
                          fontSize: 22.0,
                          textColor: sh_app_txt_color,
                          isCentered: true,
                          fontFamily: 'Medium'),
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
          child: Container(
            padding: const EdgeInsets.fromLTRB(0,spacing_middle4,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6.0,2,6,2),
                      child: IconButton(onPressed: () {
                        Navigator.pop(context);
                      }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 36,)),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text("Reset Password",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
      resizeToAvoidBottomInset: false,
      body: StreamProvider<NetworkStatus>(
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
    );

  }
}
