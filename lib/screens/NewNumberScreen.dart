import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:thrift/mypicker/country_picker_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/NumberCheckModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/OtpNewScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';


class NewNumberScreen extends StatefulWidget {
  static String tag = '/NewNumberScreen';

  const NewNumberScreen({Key? key}) : super(key: key);

  @override
  _NewNumberScreenState createState() => _NewNumberScreenState();
}

class _NewNumberScreenState extends State<NewNumberScreen> {
  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('1-246');
  TextEditingController _phoneNumberController = TextEditingController();
  String? _status;

  AuthCredential? _phoneAuthCredential;
  String? _verificationId;
  int? _code;
  NumberCheckModel? numberCheckModel;

  @override
  void initState() {
    super.initState();
    // fetchtotalMain=fetchtotal();

  }


  Future<String?> getCheck() async {
    try {
      String phoneNumber =  _phoneNumberController.text.toString().trim();
      if (phoneNumber == null || phoneNumber.isEmpty|| phoneNumber.length<5) {
        toast('Please Enter Mobile Number');
      }else{
        getUpdate();
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
      print('NewNumberScreen chk_phone_availability Response status2: ${response.statusCode}');
      print('NewNumberScreen chk_phone_availability Response body2: ${response.body}');
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
            builder: (BuildContext context) {
              return AlertDialog(
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
              );}
        );


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
            builder: (context) => OtpNewScreen(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
                country_code: _selectedDialogCountry.phoneCode,
                fnlNumber: _phoneNumberController.text.toString().trim()
            )),
      );
//      launchScreen(context, OtpScreen.tag);
//      setState(() {
//        _status += 'Code Sent\n';
//      });
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
            padding: EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[

                  Container(
                    decoration: boxDecoration(bgColor: sh_btn_color, color: sh_colorPrimary2, showShadow: true, radius: 10),
                    child: Column(

                      children: <Widget>[
                        ListTile(
                          onTap: _openCountryPickerDialog,
                          title: _buildDialogItem(_selectedDialogCountry),
                        ),
                        quizDivider(),
                        TextFormField(
                          style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular,color: sh_app_txt_color),
                          obscureText: false,
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 22, 16, 22),
                            hintText: "Phone Number",

                            border: InputBorder.none,
                            hintStyle: TextStyle(color: sh_app_txt_color),
                          ),
                        )
                        // quizEditTextStyle("Phone Number"),
                      ],
                    ),
                  ),
                  SizedBox(height: 12,),
                  Text("we'll send you a message to confirm your number.",style: TextStyle(color: sh_colorPrimary2,fontSize: 13,fontWeight: FontWeight.bold,fontFamily: 'Regular'),),
                  SizedBox(height: 40,),
                  InkWell(
                    onTap: () async{
                      getCheck();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width*.7,
                      padding: EdgeInsets.only(
                          top: 6, bottom: 10),
                      decoration: boxDecoration(
                          bgColor: sh_btn_color, radius: 10, showShadow: true),
                      child: text("SEND",
                          fontSize: 16.0,
                          textColor: sh_colorPrimary2,
                          isCentered: true,
                          fontFamily: 'Bold'),
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
                      child: Text("Enter New Number",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
      Scaffold(
      appBar: AppBar(
        backgroundColor: sh_app_bar,
        title: text('Enter New Number',
            textColor: sh_white,
            fontSize: textSizeNormal,
            fontFamily: 'Bold'),
        iconTheme: IconThemeData(color: sh_app_black),
        actionsIconTheme: IconThemeData(color: sh_app_black),
        actions: <Widget>[
          IconButton(
              color: sh_app_black,
              icon: Icon(Icons.shopping_cart),
              onPressed: () async {
                launchScreen(context, CartScreen.tag);
              })
        ],
      ),
      body: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[

              Container(
                decoration: boxDecoration(bgColor: sh_white, color: sh_textColorSecondary, showShadow: true, radius: 10),
                child: Column(

                  children: <Widget>[
                    ListTile(
                      onTap: _openCountryPickerDialog,
                      title: _buildDialogItem(_selectedDialogCountry),
                    ),
                    quizDivider(),
                    TextFormField(
                      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
                      obscureText: false,
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(16, 22, 16, 22),
                        hintText: "Phone Number",

                        border: InputBorder.none,
                        hintStyle: TextStyle(color: sh_textColorSecondary),
                      ),
                    )
                    // quizEditTextStyle("Phone Number"),
                  ],
                ),
              ),
              SizedBox(height: 12,),
              Text("we'll send you a message to confirm your number.",style: TextStyle(color: sh_textColorPrimary,fontSize: 13,fontWeight: FontWeight.bold,fontFamily: 'Regular'),),
              SizedBox(height: 20,),
              InkWell(
                onTap: () async{
                  getCheck();
                },
                child: Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                  padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
                  decoration: BoxDecoration(
                      color: sh_colorPrimary,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Center(
                      child: Text(
                        'SEND',
                        style:
                        TextStyle(fontSize: 17, color: sh_white,fontWeight: FontWeight.bold,fontFamily: 'Bold'),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
Divider quizDivider() {
  return Divider(
    height: 1,
    color: sh_app_txt_color,
    thickness: 1,
  );
}

