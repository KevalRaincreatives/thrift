import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/retry.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/ShLoginErrorNewModel.dart';
import 'package:thrift/model/ShLoginModel.dart';
import 'package:thrift/model/SignUpErrorNewModel.dart';
import 'package:thrift/model/SignUpNewModel.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/SignUpScreen.dart';
import 'package:thrift/screens/TermsConditionScreen.dart';
import 'package:thrift/utils/PinCodeTextField.dart';
import 'package:thrift/utils/PinTheme.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

class VerificationScreen extends StatefulWidget {
  static String tag='/VerificationScreen';
  final String? verificationId,phoneNumber,country_code,fnlNumber;


  VerificationScreen({this.verificationId,this.phoneNumber,this.country_code,this.fnlNumber});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  TextEditingController textEditingController = TextEditingController();
  // ..text = "123456";

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  AuthCredential? _phoneAuthCredential;
  String? _status;
  String _verificationId='';
  int? _code;
  bool? Isresend=false;


  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  // snackBar Widget
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

    try {
      String vari_id='';
      if(Isresend!){
        vari_id=_verificationId;
      }else{
        vari_id=widget.verificationId!;
      }
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: vari_id, smsCode: currentText);
      FirebaseAuth auth = FirebaseAuth.instance;
      // Sign the user in (or link) with the credential
      await auth.signInWithCredential(phoneAuthCredential);
      EasyLoading.dismiss();
      // getSetting();

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TermsConditionScreen(
                country_code: widget.country_code!,
                fnlNumber: widget.fnlNumber!
            )),
      );

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

      setState(() {
        // _status = e.toString() + '\n';
      });
      print(e.toString());
      // toast(e.toString());
      if(e.toString().contains("invalid-verification-code")){
        toast("The sms verification code is invalid");
      }else{
        toast(e.toString());
      }
    }
  }

  Future<void> _submitPhoneNumber() async {
//    FirebaseCrashlytics.instance.crash();
    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    EasyLoading.show(status: 'Sending Code...');
    String phoneNumber = "+"+widget.country_code!+ " "+ widget.fnlNumber!.trim();
    print(phoneNumber);

    /// The below functions are the callbacks, separated so as to make code more redable
    void verificationCompleted(AuthCredential phoneAuthCredential) {
      print('verificationCompleted');
      setState(() {
        _status = 'verificationCompleted\n';
      });
      this._phoneAuthCredential = phoneAuthCredential;
      print(phoneAuthCredential);
    }

    void verificationFailed(FirebaseAuthException error) {
      EasyLoading.dismiss();
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print('verificationFailed');
      toast('verification Failed');
      setState(() {
        _status = '$error\n';
      });
      print(error);
    }

    void codeSent(String verificationId, [int? code]) async{
      print('codeSent');
      this._verificationId = verificationId;
      print(verificationId);
      this._code = code;
      print(code.toString());
//      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      EasyLoading.dismiss();

      setState(() {
        _verificationId = verificationId;
      });
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
      setState(() {
        _status = 'codeAutoRetrievalTimeout\n';
      });
      print(verificationId);
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,

      /// `seconds` didn't work. The underlying implementation code only reads in `millisenconds`
      timeout: Duration(milliseconds: 10000),

      /// If the SIM (with phoneNumber) is in the current device this function is called.
      /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
      verificationCompleted: verificationCompleted,

      /// Called when the verification is failed
      verificationFailed: verificationFailed,

      /// This is called after the OTP is sent. Gives a `verificationId` and `code`
      codeSent: codeSent,

      /// After automatic code retrival `tmeout` this function is called
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    ); // All the callbacks are above
  }

  SignUpNewModel? signup_model;
  SignUpErrorNewModel? signup_error_model;
  ShLoginModel? cat_model;
  ShLoginErrorNewModel? err_model;

  Future<ShLoginModel?> SaveToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? device_id = prefs.getString('device_id');
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({"device_id": device_id});

      // Response response = await post(
      //   Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/add_device'),
      //   headers: headers,
      //   body: msg,
      // );
      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.post(
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/add_device'),
            headers: headers,
            body: msg);
      } finally {
        client.close();
      }


//      r.raiseForStatus();
//      String body = r.content();
//      print(body);

      final jsonResponse = json.decode(response.body);
      print('device json $jsonResponse');
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      EasyLoading.dismiss();
      launchScreen(context, DashboardScreen.tag);
      // launchScreen(context, DashboardScreen.tag);
      print('sucess');
      return cat_model;
    } catch (e) {
      EasyLoading.dismiss();
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print('caught error $e');
    }
  }

  Future<ShLoginModel?> getLogin() async {
    // EasyLoading.show(status: 'Please wait...');
    try {
      // String username = emailCont.text;
      // String password = passwordCont.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('sg_email');
      String? password = prefs.getString('sg_password');

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


        cat_model = new ShLoginModel.fromJson(jsonResponse);
        print("cat dta$cat_model");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', cat_model!.data!.token.toString());
        prefs.setString('UserId', cat_model!.ID.toString());
        prefs.setString('is_store_owner', cat_model!.data!.is_store_owner.toString());
        prefs.setString('user_country', cat_model!.data!.country!);
        prefs.setString('user_selected_country', cat_model!.data!.country!);


        prefs.setString('profile_name',cat_model!.data!.userNicename!);
        prefs.setString('OrderUserName', cat_model!.data!.displayName!);
        prefs.setString('OrderUserEmail', cat_model!.data!.userEmail!);
        prefs.commit();


SaveToken();

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



  Future<SignUpNewModel?> getSetting() async {
    // Dialogs.showLoadingDialog(context, _keyLoader);
    EasyLoading.show(status: 'Loading...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? first = prefs.getString('sg_first');
      String? last = prefs.getString('sg_last');
      String? email = prefs.getString('sg_email');
      String? username = prefs.getString('sg_username');
      String? password = prefs.getString('sg_password');
      String? bl_country=prefs.getString('bl_country');
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
      final msg = jsonEncode(
          {
         "first_name": first,
        "last_name": last,
        "username": username,
        "email": email,
        "phone": phone,
        "phone_code":country_code,
        "password": password,
         "billing_country": bl_country
      });

      print(msg);

      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.post(
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/registration'),
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
        prefs.setString('login_email', email!);
        prefs.setString('login_pass', password!);
        prefs.setString('login_name', first!);
        // prefs.setString('login_secret', signup_model!.secret!);
        // toast('Success');
        // getLogin();
        // EasyLoading.dismiss();
        // launchScreen(context, LoginScreen.tag);
        getLogin();

        // launchScreen(context, T2Dialog.tag);
      }else{
        EasyLoading.dismiss();
        signup_error_model= new SignUpErrorNewModel.fromJson(jsonResponse);
        toast(signup_error_model!.msg);
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
    return Scaffold(
      backgroundColor: PRIMARY_COLOR,
      body: StreamProvider<NetworkStatus>(
        initialData: NetworkStatus.Online,
        create: (context) =>
        NetworkStatusService().networkStatusController.stream,
        child: NetworkAwareWidget(
          onlineChild: GestureDetector(
            onTap: () {},
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 30),
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(sh_app_logo,color: sh_colorPrimary2,),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Phone Number Verification',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: RichText(
                      text: TextSpan(
                          text: "Enter the code sent to ",
                          children: [
                            TextSpan(
                                text: "${widget.fnlNumber}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                          style: TextStyle(color: Colors.black54, fontSize: 15)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: formKey,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 30),
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
                          // validator: (v) {
                          //   if (v!.length < 3) {
                          //     return "I'm from validator";
                          //   } else {
                          //     return null;
                          //   }
                          // },
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      TextButton(
                          onPressed: () {
                            _submitPhoneNumber();
                            Isresend=true;
                            snackBar("OTP resend!!");},
                          child: Text(
                            "RESEND",
                            style: TextStyle(
                                color: sh_colorPrimary2,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Container(
                    margin:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                    child: InkWell(
                      onTap: () async {
                        formKey.currentState!.validate();
                        // conditions for validating
                        if (currentText.length != 6) {
                          errorController!.add(ErrorAnimationType
                              .shake); // Triggering error shake animation
                          setState(() => hasError = true);
                        } else {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => TermsConditionScreen(
                          //           country_code: widget.country_code!,
                          //           fnlNumber: widget.fnlNumber!
                          //       )),
                          // );

                          _login();

                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            top: spacing_middle, bottom: spacing_middle),
                        decoration: boxDecoration(
                            bgColor: sh_app_background, radius: 10, showShadow: true),
                        child: text("VERIFY",
                            textColor: sh_colorPrimary2,
                            isCentered: true,
                            fontFamily: 'Bold'),
                      ),
                    ),


                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          child: TextButton(
                            child: Text("Clear"),
                            onPressed: () {
                              textEditingController.clear();
                            },
                          )),
                      // Flexible(
                      //     child: TextButton(
                      //       child: Text("Set Text"),
                      //       onPressed: () {
                      //         setState(() {
                      //           textEditingController.text = "123456";
                      //         });
                      //       },
                      //     )),
                    ],
                  )
                ],
              ),
            ),
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
      ),

    );

  }
}
