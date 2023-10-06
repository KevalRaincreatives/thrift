import 'dart:async';
import 'dart:convert';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      //     Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/terms'));

      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.get(
            Uri.parse(
                '${Url.BASE_URL}wp-json/wooapp/v3/terms'));
      } finally {
        client.close();
      }
//      r.raiseForStatus();
//      String body = r.content();
//      print(body);

      final jsonResponse = json.decode(response.body);
      termsModel = new TermsModel.fromJson(jsonResponse);


      print('TermsConditionScreen terms Response status2: ${response.statusCode}');
      print('TermsConditionScreen terms Response body2: ${response.body}');

      return termsModel;
    }  on Exception catch (e) {

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
              // Expanded(
              //   flex: 1,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: <Widget>[
              //         Radio(
              //           value: 2,
              //           groupValue: val,
              //           onChanged: (int? value) {
              //             setState(() {
              //               val = value!;
              //             });
              //           },
              //           activeColor: sh_colorPrimary2,
              //         ),
              //         Text('I agree to the ',style: TextStyle(color: sh_black,fontSize: 13),),
              //         Text('Terms & Conditions',style: TextStyle(color: sh_colorPrimary2,fontSize: 13, decoration: TextDecoration.underline,),),
              //       ],
              //     )),
              // Expanded(
              //   flex: 1,
              //     child: InkWell(
              //   onTap: () async {
              //     if(val==2){
              //       if (singleTap) {
              //         // Do something here
              //         getSetting();
              //         setState(() {
              //           singleTap = false; // update bool
              //         });
              //       }
              //
              //     }else{
              //       toast("Please agree to the terms & conditions");
              //     }
              //   },
              //   child: Container(
              //     width: MediaQuery.of(context).size.width*.5,
              //     margin: EdgeInsets.only(
              //         top: 4.0, bottom: 4.0),
              //     padding: EdgeInsets.only(
              //         top: spacing_standard, bottom: spacing_standard),
              //     decoration: boxDecoration(
              //         bgColor: sh_app_background, radius: 10, showShadow: true),
              //     child: text("Continue",
              //         textColor: sh_app_txt_color,
              //         isCentered: true,
              //         fontFamily: 'Bold'),
              //   ),
              // )),
              // Expanded(
              //     flex: 1,
              //     child: InkWell(
              //       onTap: () async {
              //       },
              //       child: Container(
              //       ),
              //     ))
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
