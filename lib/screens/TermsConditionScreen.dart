import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/ShLoginErrorNewModel.dart';
import 'package:thrift/model/ShLoginModel.dart';
import 'package:thrift/model/SignUpErrorNewModel.dart';
import 'package:thrift/model/SignUpNewModel.dart';
import 'package:thrift/model/TermsModel.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

class TermsConditionScreen extends StatefulWidget {
  static String tag='/TermsConditionScreen';
  final String? country_code,fnlNumber;


  TermsConditionScreen({this.country_code,this.fnlNumber});

  @override
  _TermsConditionScreenState createState() => _TermsConditionScreenState();
}

class _TermsConditionScreenState extends State<TermsConditionScreen> {
TermsModel? termsModel;
int val = 1;
SignUpNewModel? signup_model;
SignUpErrorNewModel? signup_error_model;
ShLoginModel? cat_model;
ShLoginErrorNewModel? err_model;
bool singleTap = true;

  Future<TermsModel?> fetchDetails() async {
//    Dialogs.showLoadingDialog(context, _keyLoader);
    try {



      // Response response = await get(
      //     Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/terms'));

      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.get(
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/terms'));
      } finally {
        client.close();
      }
//      r.raiseForStatus();
//      String body = r.content();
//      print(body);

      final jsonResponse = json.decode(response.body);
      termsModel = new TermsModel.fromJson(jsonResponse);


      print('sucess');
      print('not json $jsonResponse');

      return termsModel;
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
      prefs.setString('vendor_country', cat_model!.data!.country!);

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
      singleTap = true;
      signup_error_model= new SignUpErrorNewModel.fromJson(jsonResponse);
      toast(signup_error_model!.msg);
    }

    return null;
  } catch (e) {
    singleTap = true;
    EasyLoading.dismiss();
//      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    print('caught error $e');
  }
}


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    HtmlText() {
      return Html(
        data: termsModel!.data!.content,
      );
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Terms & Conditions",
          style:
          TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),

      );
      double app_height = appBar.preferredSize.height;
      return Stack(children: <Widget>[
        // Background with gradient
        Container(
            height: 120,
            width: width,
            child: Image.asset(sh_upper2, fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Container(
          height: height,
          width: width,
          color: sh_white,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(spacing_standard_new),
                  child: FutureBuilder<TermsModel?>(
                      future: fetchDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SingleChildScrollView(
                              child: HtmlText()
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        // By default, show a loading spinner.
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                child: CircularProgressIndicator(),
                                height: 50.0,
                                width: 50.0,
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ),
              Expanded(
                flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      Text('Terms & Conditions',style: TextStyle(color: sh_colorPrimary2,fontSize: 13, decoration: TextDecoration.underline,),),
                    ],
                  )),
              Expanded(
                flex: 1,
                  child: InkWell(
                onTap: () async {
                  if(val==2){
                    if (singleTap) {
                      // Do something here
                      getSetting();
                      setState(() {
                        singleTap = false; // update bool
                      });
                    }

                  }else{
                    toast("Please agree to the terms & conditions");
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width*.5,
                  margin: EdgeInsets.only(
                      top: 4.0, bottom: 4.0),
                  padding: EdgeInsets.only(
                      top: spacing_standard, bottom: spacing_standard),
                  decoration: boxDecoration(
                      bgColor: sh_app_background, radius: 10, showShadow: true),
                  child: text("Continue",
                      textColor: sh_app_txt_color,
                      isCentered: true,
                      fontFamily: 'Bold'),
                ),
              )),
              Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () async {
                    },
                    child: Container(
                    ),
                  ))
            ],
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
                      child: Text("Terms & Conditions",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
