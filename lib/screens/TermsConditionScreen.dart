import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/TermsModel.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';

class TermsConditionScreen extends StatefulWidget {
  static String tag='/TermsConditionScreen';
  const TermsConditionScreen({Key? key}) : super(key: key);

  @override
  _TermsConditionScreenState createState() => _TermsConditionScreenState();
}

class _TermsConditionScreenState extends State<TermsConditionScreen> {
TermsModel? termsModel;
int val = 1;
  Future<TermsModel?> fetchDetails() async {
//    Dialogs.showLoadingDialog(context, _keyLoader);
    try {

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',

      };

      Response response = await get(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/terms'));

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
          child: appBar,
        ),
      ]);
    }

    return Scaffold(

      body: SafeArea(child: setUserForm()),
    );
  }
}
