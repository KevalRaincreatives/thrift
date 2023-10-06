import 'dart:async';
import 'dart:convert';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:country_pickers/country.dart';
import 'package:thrift/mypicker/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/NumberCheckModel.dart';
import 'package:thrift/screens/EmailVerifyScreen.dart';
import 'package:thrift/screens/LoginEmailVerifyScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/VerificationScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:thrift/model/SignUpNewModel.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:thrift/model/ShLoginErrorNewModel.dart';
import 'package:thrift/model/ShLoginModel.dart';
import 'package:thrift/model/SignUpErrorNewModel.dart';
import 'package:thrift/screens/TermsConditionScreen.dart';

import '../provider/pro_det_provider.dart';
import '../utils/auth_service.dart';
import 'EmailExistVerifyScreen.dart';


class NewSignUpScreen extends StatefulWidget {
  static String tag='/NewSignUpScreen';
  const NewSignUpScreen({Key? key}) : super(key: key);

  @override
  _NewSignUpScreenState createState() => _NewSignUpScreenState();
}

class _NewSignUpScreenState extends State<NewSignUpScreen> {
  var firstNameCont = TextEditingController();
  var lastNameCont = TextEditingController();
  var userNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var passwordCont = TextEditingController();
  var _phoneNumberController= TextEditingController();
  var confrmpasswordCont= TextEditingController();
  bool _showOldPassword = false;
  bool _showPassword = false;
  Country _selectedDialogCountry =  CountryPickerUtils.getCountryByPhoneCode('1-246');
  String? _status;
  final _formKey = GlobalKey<FormState>();

  AuthCredential? _phoneAuthCredential;
  String? _verificationId;
  int? _code;
  NumberCheckModel? numberCheckModel;
  int val = 1;
  bool singleTap = true;
  SignUpNewModel? signup_model;
  SignUpErrorNewModel? signup_error_model;
  ShLoginModel? cat_model;
  ShLoginErrorNewModel? err_model;
  bool isEmailVerified= false;


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
      //   Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/add_device'),
      //   headers: headers,
      //   body: msg,
      // );
      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.post(
            Uri.parse(
                '${Url.BASE_URL}wp-json/wooapp/v3/add_device'),
            headers: headers,
            body: msg);
      } finally {
        client.close();
      }


      final jsonResponse = json.decode(response.body);
      print('TermsConditionScreen add_device Response status2: ${response.statusCode}');
      print('TermsConditionScreen add_device Response body2: ${response.body}');
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      EasyLoading.dismiss();
      // try {
      //   UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //       email: emailCont.text.toString().trim(),
      //       password: "12345678"
      //   );
      //   User? user = FirebaseAuth.instance.currentUser;
      //
      //   if (user!= null && !user.emailVerified) {
      //     // await user.sendEmailVerification();
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) =>
      //               EmailVerifyScreen()),);
      //   }
      //
      // } on FirebaseAuthException catch (e) {
      //   if (e.code == 'weak-password') {
      //     print('The password provided is too weak.');
      //   } else if (e.code == 'email-already-in-use') {
      //     print('The account already exists for that email.');
      //   }
      // } catch (e) {
      //   print(e);
      // }
      // launchScreen(context, DashboardScreen.tag);
      return cat_model;
    } on Exception catch (e) {
      EasyLoading.dismiss();

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
                '${Url.BASE_URL}wp-json/wooapp/v3/login'),
            headers: headers,
            body: msg);
      } finally {
        client.close();
      }



      final jsonResponse = json.decode(response.body);
      print('TermsConditionScreen login Response status2: ${response.statusCode}');
      print('TermsConditionScreen login Response body2: ${response.body}');
      if (response.statusCode == 200) {


        cat_model = new ShLoginModel.fromJson(jsonResponse);


        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', cat_model!.data!.token.toString());
        prefs.setString('UserId', cat_model!.ID.toString());
        prefs.setString('is_store_owner', cat_model!.data!.is_store_owner.toString());
        prefs.setString('user_country', cat_model!.data!.country!);
        prefs.setString('user_selected_country', cat_model!.data!.country!);
        prefs.setString('vendor_country', cat_model!.data!.country!);

        prefs.setString('profile_name',cat_model!.data!.userNicename!);
        prefs.setString('OrderUserName', cat_model!.data!.displayName!);
        prefs.setString('OrderUserEmail', cat_model!.data!.userEmail!);
        prefs.commit();

        Provider.of<ProductDetailProvider>(context, listen: false).setLoggedInStatus(true);
        SaveToken();


      } else {
        EasyLoading.dismiss();
        err_model = new ShLoginErrorNewModel.fromJson(jsonResponse);

        toast(err_model!.message!);
        // toast('Something Went Wrong');
//        print("cat dta$cat_model");

      }
      return cat_model;
    } on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }


  Future<SignUpNewModel?> getSetting() async {

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('sg_first', firstNameCont.text.toString());
      prefs.setString('sg_last', lastNameCont.text.toString());
      prefs.setString('sg_email', emailCont.text.toString());
      prefs.setString('sg_username', userNameCont.text.toString());
      prefs.setString('sg_password', passwordCont.text.toString());
      prefs.setString('bl_country', _selectedDialogCountry.name.toString());



      Map<String, String> headers = {'Content-Type': 'application/json'};

      final msg = jsonEncode(
          {
            "first_name": firstNameCont.text.toString(),
            "last_name": lastNameCont.text.toString(),
            "username": userNameCont.text.toString(),
            "email": emailCont.text.toString(),
            "phone": _phoneNumberController.text.toString().trim(),
            "phone_code":_selectedDialogCountry.phoneCode,
            "password": passwordCont.text.toString(),
            "billing_country": _selectedDialogCountry.name
          });

      print(msg);

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


      print('TermsConditionScreen registration Response status2: ${response.statusCode}');
      print('TermsConditionScreen registration Response body2: ${response.body}');

      final jsonResponse = json.decode(response.body);

      // signup_model = new SignUpModel.fromJson(jsonResponse);
      signup_model = new SignUpNewModel.fromJson(jsonResponse);
      if(signup_model!.status=='Yes'){EasyLoading.dismiss();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('Login', "Yes");
        prefs.setString('login_email', emailCont.text.toString().trim());
        prefs.setString('login_pass', passwordCont.text);
        prefs.setString('login_name', firstNameCont.text);
        // getLogin();


        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>
        //             LoginEmailVerifyScreen()));

        try {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailCont.text.toString().trim(),
              password: "12345678"
          );
          User? user = FirebaseAuth.instance.currentUser;

          if (user!= null && !user.emailVerified) {
            // await user.sendEmailVerification();
            EasyLoading.dismiss();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      EmailVerifyScreen()),);
          }

        } on FirebaseAuthException catch (e) {
          EasyLoading.dismiss();
          if (e.code == 'weak-password') {
            print('The password provided is too weak.');
          }
          else if (e.code == 'email-already-in-use') {
            print('The account already exists for that email.');
          }
        } catch (e) {
          EasyLoading.dismiss();
          print(e);
        }


      }else{
        EasyLoading.dismiss();
        singleTap = true;
        signup_error_model= new SignUpErrorNewModel.fromJson(jsonResponse);
        toast(signup_error_model!.msg!);
      }

      return null;
    }
    on Exception catch (e) {
      EasyLoading.dismiss();
      singleTap = true;

      print('caught error $e');
    }
  }

  Future<NumberCheckModel?> getUpdate() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      String phoneNumber =  _phoneNumberController.text.toString().trim();
      String email =  emailCont.text.toString();
      String username =  userNameCont.text.toString();

      String country=_selectedDialogCountry.phoneCode;

      String urlEncoded = Uri.encodeFull(country);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final msg =
      jsonEncode({"phone_code": country,"phone":phoneNumber,"email":email,"username":username});
      print(msg);

      Response response = await post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/chk_data_availability'),
          headers: headers,
          body: msg);


      final jsonResponse = json.decode(response.body);
      print('NewSignUpScreen chk_data_availability Response status2: ${response.statusCode}');
      print('NewSignUpScreen chk_data_availability Response body2: ${response.body}');
      numberCheckModel = new NumberCheckModel.fromJson(jsonResponse);
      if (numberCheckModel!.success!) {


        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('sg_first', firstNameCont.text.toString());
        prefs.setString('sg_last', lastNameCont.text.toString());
        prefs.setString('sg_email', emailCont.text.toString());
        prefs.setString('sg_username', userNameCont.text.toString());
        prefs.setString('sg_password', passwordCont.text.toString());
        prefs.setString('bl_country', _selectedDialogCountry.name.toString());


        // _submitPhoneNumber();

getSetting();

      }else {
        final AuthService _auth = AuthService();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        await _auth.signInWithEmailAndPassword2(email, "12345678").then((
            result) async {
          EasyLoading.dismiss();
          if (result is String) {
            // logToFile(printFileLogs());
            if (result.contains("user-not-found")) {
              // toast("user-not-found");
              await _auth.registerWithEmailAndPassword(
                  email, "12345678")
                  .then((result) async {
                // logToFile(result);
                if (result != null) {
                  User? _user;
                  _user = await FirebaseAuth.instance.currentUser;
                  if (_user != null && !_user.emailVerified) {
                    // await user.sendEmailVerification();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EmailExistVerifyScreen()),);
                  }


                  // launchScreen(context, DashboardScreen.tag);
                } else {
                  EasyLoading.dismiss();

                  showDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context)
                      {
                        return  AlertDialog(
                          title: const Text('Fail'),
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
                  // prefs.setString('UserId', "");
                  // setState(() {
                  //   // error = 'Error while registering the user!';
                  //   // _isLoading = false;
                  // });
                }
              });
            }
            else {
              toast("Something went wrong");
            }
          }
          else {
            EasyLoading.dismiss();
            isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
            if (isEmailVerified) {
              // toast("Verified");
              showDialog<void>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context)
                  {
                    return  AlertDialog(
                      title: const Text('Fail'),
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
            } else {
              // toast("Not Verified");
              prefs.setString('EmailVerified', "No");
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EmailExistVerifyScreen()),);
            }
          }
        });


      }
      return numberCheckModel;
    } on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
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
      toast('verification Failed ');
      toast(error.message!);
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

      // var firstNameCont = TextEditingController();
      // var lastNameCont = TextEditingController();
      // var emailCont = TextEditingController();
      // var passwordCont = TextEditingController();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('sg_first', firstNameCont.text.toString());
      prefs.setString('sg_last', lastNameCont.text.toString());
      prefs.setString('sg_email', emailCont.text.toString());
      prefs.setString('sg_username', userNameCont.text.toString());
      prefs.setString('sg_password', passwordCont.text.toString());
      prefs.setString('bl_country', _selectedDialogCountry.name.toString());

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
        Text("+${country.phoneCode}",style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),),
        SizedBox(width: 8.0),
        Flexible(child: Text(country.name,style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),))
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
              title: Text('Select your phone code',style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),),
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
      backgroundColor: Colors.white,
      body: StreamProvider<NetworkStatus>(
        initialData: NetworkStatus.Online,
        create: (context) =>
        NetworkStatusService().networkStatusController.stream,
        child: NetworkAwareWidget(
          onlineChild: Stack(
            children: [
              Container(
                  height: 200,
                  width: width,
                  child: Image.asset(sh_upper,fit: BoxFit.fill)
                // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
              ),
              Container(
                height: height,
                width: width,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 36,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: IconButton(onPressed: () {
                                Navigator.pop(context);
                              }, icon: Icon(Icons.keyboard_arrow_left,color: Colors.white,size: 36,)),
                            ),

                            Center(child: Text("Getting Started",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive',fontWeight: FontWeight.normal),))
                          ],
                        ),
                        SizedBox(height: 50,),
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
                                  // labelText: "First name",
                                  // labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                                  filled: true,
                                  fillColor: sh_btn_color,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide:  BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                ),
                                maxLines: 1,
                                style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                              ),
                              SizedBox(height: 16,),
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
                                  // labelText: "Last name",
                                  // labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                                  filled: true,
                                  fillColor: sh_btn_color,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide:  BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                ),
                                maxLines: 1,
                                style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                              ),
                              SizedBox(height: 16,),
                              TextFormField(
                                onEditingComplete: () =>
                                    node.nextFocus(),
                                controller: userNameCont,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please Enter User name';
                                  }
                                  return null;
                                },
                                cursorColor: sh_app_txt_color,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                                  hintText: "User name",
                                  hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                  // labelText: "Last name",
                                  // labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                                  filled: true,
                                  fillColor: sh_btn_color,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide:  BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                ),
                                maxLines: 1,
                                style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                              ),
                              SizedBox(height: 16,),
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
                                  hintText: "Email (Required)",
                                  hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                  // labelText: "Email",
                                  // labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                                  filled: true,
                                  fillColor: sh_btn_color,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide:  BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                ),
                                maxLines: 1,
                                style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                              ),
                              SizedBox(height: 16,),
                              TextFormField(
                                onEditingComplete: () =>
                                    node.nextFocus(),
                                keyboardType: TextInputType.number,
                                controller: _phoneNumberController,
                                // validator: (text) {
                                //   if (text == null || text.isEmpty) {
                                //     return 'Please Enter Number';
                                //   }
                                //   return null;
                                // },
                                cursorColor: sh_app_txt_color,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                                  hintText: "Mobile Number",
                                  hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                  // labelText: "Mobile Number",
                                  // labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                                  filled: true,
                                  fillColor: sh_btn_color,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide:  BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                ),
                                maxLines: 1,
                                style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                              ),
                              SizedBox(height: 16,),
                              TextFormField(
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.deny(RegExp('[&]')),
                                // ],
                                onEditingComplete: () =>
                                    node.nextFocus(),
                                obscureText: !this._showOldPassword,
                                controller: passwordCont,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please Enter Password';
                                  }else if(!validateStructure(text)){
                                    return 'Your password should not contain\nfollowing characters: \n(){}[]|`¬¦ "£%^&*"<>:;#~-+=,';
                                  }

                                  return null;
                                },
                                cursorColor: sh_app_txt_color,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                  // labelText: "Password",
                                  // labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: this._showOldPassword ? sh_colorPrimary2 : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() => this._showOldPassword = !this._showOldPassword);
                                    },
                                  ),
                                  filled: true,
                                  fillColor: sh_btn_color,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide:  BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                ),
                                maxLines: 1,
                                style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                              ),
                              SizedBox(height: 16,),
                              TextFormField(
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.deny(RegExp('[&]')),
                                // ],
                                onEditingComplete: () =>
                                    node.nextFocus(),
                                obscureText: !this._showPassword,
                                controller: confrmpasswordCont,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please Enter Password';
                                  }else
                                  if(text != passwordCont.text) {
                                    return 'Password Do Not Match';
                                  }else if(!validateStructure(text)){
                                    return 'Your password should not contain\nfollowing characters: \n(){}[]|`¬¦ "£%^&*"<>:;#~-+=,';
                                  }
                                  return null;
                                },
                                cursorColor: sh_app_txt_color,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
                                  hintText: "Confirm Password",
                                  hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: this._showPassword ? sh_colorPrimary2 : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() => this._showPassword = !this._showPassword);
                                    },
                                  ),
                                  // labelText: "Confirm Password",
                                  // labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Bold'),
                                  filled: true,
                                  fillColor: sh_btn_color,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide:  BorderSide(color: sh_app_txt_color, width: 0.0),
                                  ),
                                ),
                                maxLines: 1,
                                style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                              ),
                              SizedBox(height: 16,),
                              Container(
                                decoration: boxDecoration(
                                    bgColor: sh_btn_color, radius: 22, showShadow: true),
                                child: Row(
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
                              ),
                              SizedBox(height: 6,),
                              Text("*COUNTRY* is required to allow us to match you with listings in your country. If you travel to another country, it can always be changed in settings. ",style: TextStyle(color: sh_textColorPrimary,fontSize: 11),),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Radio(
                                    value: 2,
                                    groupValue: val,
                                    onChanged: (int? value) {
                                      setState(() {
                                        val = value!;
                                      });
                                    },
                                    activeColor: sh_colorPrimary2,
                                  ),
                                  Text('I agree to the ',style: TextStyle(color: sh_black,fontSize: 13),),
                                  InkWell(onTap: () {
                                    launchScreen(context, TermsConditionScreen.tag);
                                  },
                                      child: Text('Terms & Conditions',style: TextStyle(color: sh_colorPrimary2,fontSize: 13, decoration: TextDecoration.underline,),)),
                                ],
                              ),
                              SizedBox(height: 16,),
                              InkWell(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // TODO submit
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    final bool emailValid =
                                    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(emailCont.text.toString().trim());
                                    if(emailValid){
    if(val==2) {
      if (singleTap) {
        // getCheck();
        getUpdate();
      }
    }else{
      toast("Please agree to the terms & conditions");
    }
                                    }

                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width*.7,
                                  padding: EdgeInsets.only(
                                      top: 6, bottom: 10),
                                  decoration: boxDecoration(
                                      bgColor: sh_btn_color, radius: 10, showShadow: true),
                                  child: text("Continue",
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
                ),
              )
            ],
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
