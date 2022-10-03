import 'dart:convert';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:thrift/model/NumberCheckModel.dart';
import 'package:thrift/screens/VerificationScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:thrift/utils/T6Colors.dart';
import 'package:thrift/utils/T6Widget.dart';
import 'package:nb_utils/nb_utils.dart';

class OtpScreen extends StatefulWidget {
  static String tag='/OtpScreen';
  const OtpScreen({Key? key}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Country _selectedDialogCountry =
  CountryPickerUtils.getCountryByPhoneCode('1-246');
  TextEditingController _phoneNumberController = TextEditingController();
  String? _status;

  AuthCredential? _phoneAuthCredential;
  String? _verificationId;
  int? _code;
  NumberCheckModel? numberCheckModel;


  Future<String?> getCheck() async {
    try {
      String phoneNumber =  _phoneNumberController.text.toString().trim();
      if (phoneNumber == null || phoneNumber.isEmpty|| phoneNumber.length<5) {
        toast('Please Enter Mobile Number');
      }else{
        getUpdate();
        // _submitPhoneNumber();
      }
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<NumberCheckModel?> getUpdate() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      String phoneNumber =  _phoneNumberController.text.toString().trim();

      String country=_selectedDialogCountry.phoneCode;

      String urlEncoded = Uri.encodeFull(country);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final msg =
      jsonEncode({"phone_code": country,"phone":phoneNumber});

      Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/chk_phone_availability'),
          headers: headers,
          body: msg);

      // Response response = await get(
      //   'https://moco.bb/wp-json/v3/check_phone?phone_number=$phoneNumber&country_code=$urlEncoded',
      // );


      final jsonResponse = json.decode(response.body);
      print('OtpScreen chk_phone_availability Response status2: ${response.statusCode}');
      print('OtpScreen chk_phone_availability Response body2: ${response.body}');
      numberCheckModel = new NumberCheckModel.fromJson(jsonResponse);
      if (numberCheckModel!.success!) {
        EasyLoading.dismiss();
        _submitPhoneNumber();
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      }else {
        EasyLoading.dismiss();
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context)
            {
              return  AlertDialog(
                title: Text('Fail'),
                content: SingleChildScrollView(
                  child: Text(numberCheckModel!.msg!),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop(ConfirmAction.CANCEL);
//                    launchScreen(context, ShHomeScreen.tag);
                    },
                  ),
                ],
              );});


      }
      return numberCheckModel;
    } catch (e) {
      print('caught error $e');
      EasyLoading.dismiss();
      // VerifyNumberScreen(
      //     country_code: _selectedDialogCountry.phoneCode,
      //     fnlNumber: _phoneNumberController.text.toString().trim()
      // ).launch(context);
    }
  }

  Future<void> _submitPhoneNumber() async {
//    FirebaseCrashlytics.instance.crash();
    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    EasyLoading.show(status: 'Sending Code...');
    String phoneNumber = "+"+_selectedDialogCountry.phoneCode+ " "+ _phoneNumberController.text.toString().trim();
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

    void codeSent(String verificationId, [int? code]) {
      print('codeSent');
      this._verificationId = verificationId;
      print(verificationId);
      this._code = code;
      print(code.toString());
//      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VerificationScreen(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
                country_code: _selectedDialogCountry.phoneCode,
                fnlNumber: _phoneNumberController.text.toString().trim()
            )),
      );
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

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    Widget _buildDialogItem(Country country) => Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Text("+${country.phoneCode}"),
        SizedBox(width: 8.0),
        Flexible(child: Text(country.name))
      ],
    );

    void _openCountryPickerDialog() => showDialog<void>(
      context: context,
      builder: (BuildContext context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: CountryPickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: Colors.pinkAccent,
              searchInputDecoration: InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              title: Text('Select your phone code'),
              onValuePicked: (Country country) =>
                  setState(() =>
                  _selectedDialogCountry = country),
              priorityList: [
                CountryPickerUtils.getCountryByIsoCode('BB'),
                CountryPickerUtils.getCountryByIsoCode('US'),
              ],
              itemBuilder: _buildDialogItem)),
    );
return Scaffold(
  body: Container(
    height: height,
    width: width,
    color: sh_white,
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
                                    fontFamily: "ExtraBold",
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  width: 301,
                                  child: Text(
                                    "Please provide your mobile number to login securely we will link your mobile number to your account",
                                    style: TextStyle(
                                      fontFamily: 'Regular',
                                      color: Color(0xaf000000),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 35.88),
                          Container(
                            decoration: boxDecoration(showShadow: false, bgColor: sh_white, radius: 4, color: sh_colorPrimary),
                            padding: EdgeInsets.all(0),
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: ListTile(
                                    onTap: _openCountryPickerDialog,
                                    title: _buildDialogItem(_selectedDialogCountry),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15.88),
                          TextFormField(
                            obscureText: false,
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: sh_app_black,fontSize: textSizeLargeMedium, fontFamily: "Regular",
                              fontWeight: FontWeight.w800,),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: sh_editText_background,
                              focusColor:
                              sh_editText_background_active,
                              counterText: "",
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
                              hintText: sh_hint_mobile_no,
                              hintStyle: TextStyle(color: sh_textColorSecondary, fontSize: textSizeMedium,fontFamily: "Regular",
                                fontWeight: FontWeight.w800,),

                            ),
                          ),
                          SizedBox(height: 35.88),
                          Container(
                            height: 60,
                            child: InkWell(
                              onTap: () async{
                                getCheck();
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
                                    color: sh_app_black,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Back to Sign In Page",
                                    style: TextStyle(
                                      color: sh_app_black,
                                      fontSize: 18,
                                      fontFamily: "Bold",
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
