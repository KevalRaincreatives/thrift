import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:thrift/model/ForgotModel.dart';
import 'package:thrift/screens/ResetPasswordScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';


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
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/wooapp_reset_password'),
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
          child:   Container(
            alignment: Alignment.center,
            width: width*.75,
            padding: EdgeInsets.all(26),
            child: Column(
              children: [
                Text(
                  "Please provide your registered email address to reset your password",
                  style: TextStyle(
                    fontFamily: 'Medium',
                    color: sh_colorPrimary2,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32,),
                TextFormField(
                  // onEditingComplete: () =>
                  //     node.nextFocus(),
                  controller: emailCont,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Please Enter Email';
                    }
                    return null;
                  },
                  cursorColor: sh_colorPrimary2,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                    hintText: "Email",
                    hintStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                    labelText: "Email",
                    labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
                    ),
                  ),
                  maxLines: 1,
                  style: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                ),

                SizedBox(height: 36,),
                InkWell(
                  onTap: () async {
                    getUpdate();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width*.7,
                    padding: EdgeInsets.only(
                        top: 6, bottom: 10),
                    decoration: boxDecoration(
                        bgColor: sh_btn_color, radius: 10, showShadow: true),
                    child: text("CONTINUE",
                        fontSize: 20.0,
                        textColor: sh_colorPrimary2,
                        isCentered: true,
                        fontFamily: 'Bold'),
                  ),
                ),

                SizedBox(height: 40,),
              ],
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
                      child: Text("Forgot Password",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
