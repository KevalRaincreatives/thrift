import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/ProfileUpdateModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/PinCodeTextField.dart';
import 'package:thrift/utils/PinTheme.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';


class OtpNewScreen extends StatefulWidget {
  static String tag='/OtpNewScreen';
  final String? verificationId,phoneNumber,country_code,fnlNumber;

  OtpNewScreen({this.verificationId,this.phoneNumber,this.country_code,this.fnlNumber});


  @override
  _OtpNewScreenState createState() => _OtpNewScreenState();
}

class _OtpNewScreenState extends State<OtpNewScreen> {
  ProfileUpdateModel? profileUpdateModel;
  String? _status;

  AuthCredential? _phoneAuthCredential;
  // String text2 = '';
  // FocusNode? pin2FocusNode;
  // FocusNode? pin3FocusNode;
  // FocusNode? pin4FocusNode;
  // FocusNode? pin5FocusNode;
  // FocusNode? pin6FocusNode;
  // TextEditingController ot1Controller = TextEditingController();
  // TextEditingController ot2Controller = TextEditingController();
  // TextEditingController ot3Controller = TextEditingController();
  // TextEditingController ot4Controller = TextEditingController();
  // TextEditingController ot5Controller = TextEditingController();
  // TextEditingController ot6Controller = TextEditingController();
  TextEditingController textEditingController = TextEditingController();
  // ..text = "123456";

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    // pin2FocusNode = FocusNode();
    // pin3FocusNode = FocusNode();
    // pin4FocusNode = FocusNode();
    // pin5FocusNode = FocusNode();
    // pin6FocusNode = FocusNode();
    errorController = StreamController<ErrorAnimationType>();
  }

  @override
  void dispose() {
    super.dispose();
    // pin2FocusNode!.dispose();
    // pin3FocusNode!.dispose();
    // pin4FocusNode!.dispose();
    // pin5FocusNode!.dispose();
    // pin6FocusNode!.dispose();
    errorController!.close();

  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  // Widget otpNumberWidget(int position) {
  //   try {
  //     return Container(
  //       height: 40,
  //       width: 40,
  //       decoration: BoxDecoration(
  //           border: Border.all(color: Colors.black, width: 0),
  //           borderRadius: const BorderRadius.all(Radius.circular(8))
  //       ),
  //       child: Center(child: Text(text2[position], style: TextStyle(color: Colors.black),)),
  //     );
  //   } catch (e) {
  //     return Container(
  //       height: 40,
  //       width: 40,
  //       decoration: BoxDecoration(
  //           border: Border.all(color: Colors.black, width: 0),
  //           borderRadius: const BorderRadius.all(Radius.circular(8))
  //       ),
  //     );
  //   }
  // }

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _login() async {
    /// This method is used to login the user
    /// `AuthCredential`(`_phoneAuthCredential`) is needed for the signIn method
    /// After the signIn method from `AuthResult` we can get `FirebaserUser`(`_firebaseUser`)
    ///
    EasyLoading.show(status: 'Verifying...');
    // String pin=ot1Controller.text.toString()+ot2Controller.text.toString()+ot3Controller.text.toString()+ot4Controller.text.toString()
    //     +ot5Controller.text.toString()+ot6Controller.text.toString();
    try {

      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: widget.verificationId!, smsCode: currentText);
      FirebaseAuth auth = FirebaseAuth.instance;
      // Sign the user in (or link) with the credential
      await auth.signInWithCredential(phoneAuthCredential);
      EasyLoading.dismiss();
      getUpdate();
      setState(
            () {
          hasError = false;
          snackBar("OTP Verified!!");
        },
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => SignUpScreen(
      //           country_code: widget.country_code,
      //           fnlNumber: widget.fnlNumber
      //       )),
      // );
    } catch (e) {
      EasyLoading.dismiss();
      toast(e.toString());
      setState(() {
        _status = e.toString() + '\n';
      });
      print(e.toString());
    }
  }

  Future<ProfileUpdateModel?> getUpdate() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pro_first = prefs.getString('pro_first');
      String? pro_last = prefs.getString('pro_last');
      String? pro_email = prefs.getString('pro_email');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode(
          {"display_name":pro_email,"user_email": pro_email, "user_url":"","first_name": pro_first, "last_name": pro_last,"phone": widget.fnlNumber,"phone_code": widget.country_code});

      print(msg);

      // String body = json.encode(data2);

      Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/edit_profile'),
          headers: headers,
          body: msg);
      EasyLoading.dismiss();

//
      final jsonResponse = json.decode(response.body);
      print('OtpNewScreen edit_profile Response status2: ${response.statusCode}');
      print('OtpNewScreen edit_profile Response body2: ${response.body}');
      profileUpdateModel = new ProfileUpdateModel.fromJson(jsonResponse);
      toast(profileUpdateModel!.msg);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => DashboardScreen(selectedTab: 0,)),
        ModalRoute.withName('/DashboardScreen'),
      );

      return profileUpdateModel;
    } catch (e) {
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
    String phone=widget.phoneNumber!;

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
          "Enter New Number",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
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
          child:  Container(
            width: width,
            height: height,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[

                  Container(
                    padding: EdgeInsets.fromLTRB(26,0,26,0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height*0.08,),
                        Row(children: [
                          Text("Confirm",style: TextStyle(color: sh_app_txt_color,fontSize: 28,fontWeight: FontWeight.bold),),
                          SizedBox(width: 8,),
                          Text("your number",style: TextStyle(color: sh_app_txt_color,fontSize: 28,fontWeight: FontWeight.bold),),
                        ],),
                        SizedBox(height: 12,),
                        Text("Enter the code we sent via SMS to "+phone,style: TextStyle(color: sh_textColorPrimary,fontSize: 13,fontWeight: FontWeight.normal),maxLines: 2,),
                        SizedBox(height: 20,),
                        Form(
                          key: formKey,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 00),
                              child: PinCodeTextField(
                                appContext: context,
                                pastedTextStyle: TextStyle(
                                  color: sh_colorPrimary2,
                                  fontWeight: FontWeight.bold,
                                ),
                                length: 6,
                                obscureText: false,
                                // obscuringCharacter: '*',
                                // obscuringWidget: FlutterLogo(
                                //   size: 24,
                                // ),
                                blinkWhenObscuring: true,
                                animationType: AnimationType.none,
                                validator: (v) {
                                  if (v!.length < 3) {
                                    return "I'm from validator";
                                  } else {
                                    return null;
                                  }
                                },
                                pinTheme: PinTheme(
                                  // shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(5),
                                  fieldHeight: 50,
                                  fieldWidth: 40,
                                  activeFillColor: Colors.white,
                                ),
                                cursorColor: Colors.black,
                                animationDuration: Duration(milliseconds: 300),
                                enableActiveFill: true,
                                errorAnimationController: errorController,
                                controller: textEditingController,
                                keyboardType: TextInputType.number,
                                boxShadows: [
                                  BoxShadow(
                                    offset: Offset(0, 1),
                                    color: Colors.black12,
                                    blurRadius: 10,
                                  )
                                ],
                                onCompleted: (v) {
                                  print("Completed");
                                },
                                // onTap: () {
                                //   print("Pressed");
                                // },
                                onChanged: (value) {
                                  print(value);
                                  setState(() {
                                    currentText = value;
                                  });
                                },
                                beforeTextPaste: (text) {
                                  print("Allowing to paste $text");
                                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                  return true;
                                },
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            hasError ? "*Please fill up all the cells properly" : "",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        // Form(
                        //   child: Column(
                        //     children: [
                        //       Row(
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           SizedBox(
                        //             width: width*.11,
                        //             child: TextFormField(
                        //               autofocus: true,
                        //               obscureText: false,
                        //               controller: ot1Controller,
                        //               style: TextStyle(fontSize: 20),
                        //               keyboardType: TextInputType.number,
                        //               textAlign: TextAlign.center,
                        //               decoration: otpInputDecoration,
                        //               onChanged: (value) {
                        //                 nextField(value, pin2FocusNode!);
                        //               },
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: width*.11,
                        //             child: TextFormField(
                        //               focusNode: pin2FocusNode,
                        //               obscureText: false,
                        //               controller: ot2Controller,
                        //               style: TextStyle(fontSize: 20),
                        //               keyboardType: TextInputType.number,
                        //               textAlign: TextAlign.center,
                        //               decoration: otpInputDecoration,
                        //               onChanged: (value) => nextField(value, pin3FocusNode!),
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: width*.11,
                        //             child: TextFormField(
                        //               focusNode: pin3FocusNode,
                        //               obscureText: false,
                        //               controller: ot3Controller,
                        //               style: TextStyle(fontSize: 20),
                        //               keyboardType: TextInputType.number,
                        //               textAlign: TextAlign.center,
                        //               decoration: otpInputDecoration,
                        //               onChanged: (value) => nextField(value, pin4FocusNode!),
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: width*.11,
                        //             child: TextFormField(
                        //               focusNode: pin4FocusNode,
                        //               obscureText: false,
                        //               controller: ot4Controller,
                        //               style: TextStyle(fontSize: 20),
                        //               keyboardType: TextInputType.number,
                        //               textAlign: TextAlign.center,
                        //               decoration: otpInputDecoration,
                        //               onChanged: (value) => nextField(value, pin5FocusNode!),
                        //
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: width*.11,
                        //             child: TextFormField(
                        //               focusNode: pin5FocusNode,
                        //               obscureText: false,
                        //               controller: ot5Controller,
                        //               style: TextStyle(fontSize: 20),
                        //               keyboardType: TextInputType.number,
                        //               textAlign: TextAlign.center,
                        //               decoration: otpInputDecoration,
                        //               onChanged: (value) => nextField(value, pin6FocusNode!),
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: width*.11,
                        //             child: TextFormField(
                        //               focusNode: pin6FocusNode,
                        //               obscureText: false,
                        //               controller: ot6Controller,
                        //               style: TextStyle(fontSize: 20),
                        //               keyboardType: TextInputType.number,
                        //               textAlign: TextAlign.center,
                        //               decoration: otpInputDecoration,
                        //               onChanged: (value) {
                        //                 if (value.length == 1) {
                        //                   pin6FocusNode!.unfocus();
                        //                   // Then you need to check is the code is correct or not
                        //                 }
                        //               },
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       // DefaultButton(
                        //       //   text: "Continue",
                        //       //   press: () {},
                        //       // )
                        //     ],
                        //   ),
                        // ),
                        // Container(
                        //   margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        //     child: OtpForm()),

                        SizedBox(height: 20,),
                        Row(children: [
                          Text("Didn't get a code?",style: TextStyle(color: sh_textColorPrimary,fontSize: 15,fontWeight: FontWeight.bold),),
                          SizedBox(width: 8,),
                          Text("Send again",style: TextStyle(color: sh_colorPrimary2,fontSize: 15,fontWeight: FontWeight.bold),),
                        ],),
                        SizedBox(height: 50,),
                        InkWell(
                          onTap: () async {
                            formKey.currentState!.validate();
                            // conditions for validating
                            if (currentText.length != 6) {
                              errorController!.add(ErrorAnimationType
                                  .shake); // Triggering error shake animation
                              setState(() => hasError = true);
                            } else {
                              // getSetting();
                              _login();

                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                                top: spacing_middle, bottom: spacing_middle),
                            decoration: boxDecoration(
                                bgColor: sh_app_background, radius: 10, showShadow: true),
                            child: text("Save Profile",
                                textColor: sh_colorPrimary2,
                                isCentered: true,
                                fontFamily: 'Bold'),
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
          child: Container(
            padding: const EdgeInsets.fromLTRB(10,18,10,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.0,2,6,2),
                      child: IconButton(onPressed: () {
                        Navigator.pop(context);
                      }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 32,)),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,6,6,6.0),
                      child: Text("Enter OTP",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
