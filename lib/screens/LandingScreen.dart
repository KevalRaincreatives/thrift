import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/NewSignUpScreen.dart';
import 'package:thrift/screens/TermsConditionScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';

class LandingScreen extends StatefulWidget {
  static String tag='/LandingScreen';
  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        color: Colors.white,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
              Expanded(flex: 7,
              child: Stack(
                  fit: StackFit.expand,
                  children:[
                // Image.asset(sh_upper,fit: BoxFit.cover,height: height,),
                Container(
                  height: height,
                    constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
                    width: double.infinity,
                    child: Image.asset(sh_upper,fit: BoxFit.fill,height: height,width: width,)
                    // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
),
                // Image.asset(sh_splsh2,fit: BoxFit.none,height: height,),
] ),),


              Expanded(
                flex: 4,
                  child: Container())
            ],),
            Column(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(

                  )),
              // Expanded(
              //     flex: 2,
              //     child: Container(
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.end,
              //         children: [
              //       //     Text("Cassie",style: TextStyle(color: sh_white,fontFamily: "Cursive",fontSize: 90),),
              //       // Text("BY",style: TextStyle(color: sh_white,fontFamily: "Bold",fontSize: 14))
              //         ],
              //       ),
              //     )),

              Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,8,8,0),
                    child: Image.asset(sh_app_logo,width: width*.6,fit: BoxFit.fill,),
                  )),
              Expanded(
                  flex: 4,
                  child: Container()),
              Expanded(
                  flex: 4,
                  child: Column(children: [
                    InkWell(
                      onTap: () async {
                        launchScreen(context, NewSignUpScreen.tag);
                        // launchScreen(context, TermsConditionScreen.tag);
                        // if (_formKey.currentState!.validate()) {
                        //   // TODO submit
                        //   FocusScope.of(context).requestFocus(FocusNode());
                        // toast(selectedReportList.join(" , "));
                        // for (var i = 0; i < selectedReportList.length; i++) {
                        //   addProCatModel.add(new AddProCategoryModel(id: selectedReportList[i]));
                        // }
                        // toast(itemsModel.length.toString());
                        // AddProduct();
                        // }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*.6,
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
                        text("Already have an account?", textColor: sh_textColorSecondary,fontSize: 16.0),
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          child: GestureDetector(

                              child: Text("Log In",
                                  style: TextStyle(
                                      fontSize: textSizeLargeMedium,
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
                  ],))
            ],
          )],

        ),
      ),
    );
  }
}
