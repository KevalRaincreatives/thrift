import 'dart:convert';
import 'package:thrift/api_service/Url.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/NumberCheckModel.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/VerificationScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';

class NewSignUpScreen extends StatefulWidget {
  static String tag='/NewSignUpScreen';
  const NewSignUpScreen({Key? key}) : super(key: key);

  @override
  _NewSignUpScreenState createState() => _NewSignUpScreenState();
}

class _NewSignUpScreenState extends State<NewSignUpScreen> {
  var firstNameCont = TextEditingController();
  var lastNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var passwordCont = TextEditingController();
  var _phoneNumberController= TextEditingController();
  var confrmpasswordCont= TextEditingController();
  Country _selectedDialogCountry =  CountryPickerUtils.getCountryByPhoneCode('1-246');
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
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/chk_phone_availability'),
          headers: headers,
          body: msg);

      // Response response = await get(
      //   'https://moco.bb/wp-json/v3/check_phone?phone_number=$phoneNumber&country_code=$urlEncoded',
      // );


      final jsonResponse = json.decode(response.body);
      print('Response body2: ${response.body}');
      print('not json $jsonResponse');
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

        print('sucess');
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

    void codeSent(String verificationId, [int? code]) async{
      print('codeSent');
      this._verificationId = verificationId;
      print(verificationId);
      this._code = code;
      print(code.toString());
//      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      EasyLoading.dismiss();

      var firstNameCont = TextEditingController();
      var lastNameCont = TextEditingController();
      var emailCont = TextEditingController();
      var passwordCont = TextEditingController();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('sg_first', firstNameCont.text.toString());
      prefs.setString('sg_last', lastNameCont.text.toString());
      prefs.setString('sg_email', firstNameCont.text.toString());
      prefs.setString('sg_password', passwordCont.text.toString());

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
    final node = FocusScope.of(context);

    Widget _buildDialogItem(Country country) => Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Text("+${country.phoneCode}",style: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),),
        SizedBox(width: 8.0),
        Flexible(child: Text(country.name,style: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),))
      ],
    );

    void _openCountryPickerDialog() => showDialog<void>(
      context: context,
      builder: (BuildContext context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: CountryPickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: Colors.pinkAccent,
              searchInputDecoration: InputDecoration(hintText: 'Search...',hintStyle: TextStyle(color: sh_app_txt_color)),
              isSearchable: true,
              title: Text('Select your phone code',style: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),),
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
      body: Stack(
        children: [
          Container(
            decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [
                      sh_app_background,
                      Colors.white38,
                    ],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    tileMode: TileMode.repeated
                )
            ),
          ),
          Container(
            height: height,
            width: width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: IconButton(onPressed: () {
                          Navigator.pop(context);
                        }, icon: Icon(Icons.keyboard_arrow_left,color: Colors.black,size: 36,)),
                      ),

                      Center(child: Text("Getting Started",style: TextStyle(color: Colors.black,fontSize: 22,fontFamily: 'Bold'),))
                    ],
                  ),
                  SizedBox(height: 26,),
                  Container(
                    width: width*.7,
                    child: Column(
                      children: [
                        TextFormField(
                          onEditingComplete: () =>
                              node.nextFocus(),
                          controller: firstNameCont,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please Enter First name';
                            }
                            return null;
                          },
                          cursorColor: sh_app_txt_color,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                            hintText: "First name",
                            hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                            labelText: "First name",
                            labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:  BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                          ),
                          maxLines: 1,
                          style: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                        ),
                        SizedBox(height: 12,),
                        TextFormField(
                          onEditingComplete: () =>
                              node.nextFocus(),
                          controller: lastNameCont,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please Enter Last name';
                            }
                            return null;
                          },
                          cursorColor: sh_app_txt_color,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                            hintText: "Last name",
                            hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                            labelText: "Last name",
                            labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:  BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                          ),
                          maxLines: 1,
                          style: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                        ),
                        SizedBox(height: 12,),
                        TextFormField(
                          onEditingComplete: () =>
                              node.nextFocus(),
                          controller: emailCont,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please Enter Email';
                            }
                            return null;
                          },
                          cursorColor: sh_app_txt_color,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                            hintText: "Email",
                            hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                            labelText: "Email",
                            labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:  BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                          ),
                          maxLines: 1,
                          style: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                        ),
                        SizedBox(height: 12,),
                        TextFormField(
                          onEditingComplete: () =>
                              node.nextFocus(),
                          keyboardType: TextInputType.number,
                          controller: _phoneNumberController,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please Enter Number';
                            }
                            return null;
                          },
                          cursorColor: sh_app_txt_color,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                            hintText: "Mobile Number",
                            hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                            labelText: "Mobile Number",
                            labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:  BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                          ),
                          maxLines: 1,
                          style: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                        ),
                        SizedBox(height: 12,),
                        TextFormField(
                          onEditingComplete: () =>
                              node.nextFocus(),
                          controller: passwordCont,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please Enter Password';
                            }
                            return null;
                          },
                          cursorColor: sh_app_txt_color,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                            hintText: "Password",
                            hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                            labelText: "Password",
                            labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:  BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                          ),
                          maxLines: 1,
                          style: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                        ),
                        SizedBox(height: 12,),
                        TextFormField(
                          onEditingComplete: () =>
                              node.nextFocus(),
                          controller: confrmpasswordCont,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Please Enter Password';
                            }
                            return null;
                          },
                          cursorColor: sh_app_txt_color,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                            hintText: "Confirm Password",
                            hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                            labelText: "Confirm Password",
                            labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:  BorderSide(color: sh_app_txt_color, width: 1.0),
                            ),
                          ),
                          maxLines: 1,
                          style: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                        ),
                        SizedBox(height: 12,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: ListTile(
                                onTap: _openCountryPickerDialog,
                                title: _buildDialogItem(_selectedDialogCountry),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down,color: sh_app_txt_color,)
                          ],
                        ),
                        Container(
                          height: 1.0,
                          color: sh_app_txt_color,
                        ),
                        SizedBox(height: 6,),
                        Text("*COUNTRY* is required to allow us to match you with listings in your country. If you travel to another country, it can always be changed in settings. ",style: TextStyle(color: sh_textColorPrimary,fontSize: 12),),
                        SizedBox(height: 16,),
                        InkWell(
                          onTap: () async {
                            getCheck();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width*.7,
                            padding: EdgeInsets.only(
                                top: 6, bottom: 10),
                            decoration: boxDecoration(
                                bgColor: sh_btn_color, radius: 10, showShadow: true),
                            child: text("Sign Up",
                                fontSize: 24.0,
                                textColor: sh_app_txt_color,
                                isCentered: true,
                                fontFamily: 'Bold'),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            text("Already have an account?", textColor: sh_textColorSecondary,fontSize: 13.0),
                            Container(
                              margin: EdgeInsets.only(left: 4),
                              child: GestureDetector(

                                  child: Text("Log In",
                                      style: TextStyle(
                                          fontSize: textSizeMedium,
                                          decoration: TextDecoration.underline,
                                          color: sh_app_txt_color,
                                          fontFamily: 'Bold'
                                      )),
                                  onTap: () {
                                    launchScreen(context, LoginScreen.tag);
                                  }),
                            )
                          ],
                        ),
                        SizedBox(height: 30,),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
