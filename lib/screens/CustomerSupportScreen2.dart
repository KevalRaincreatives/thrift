import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';

class CustomerSupportScreen extends StatefulWidget {
  static String tag='/CustomerSupportScreen';
  const CustomerSupportScreen({Key? key}) : super(key: key);

  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Customer Support",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
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
          child:   Container(
            height: height,
            width: width,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: width*.8,
                    height: height,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text("Denroy Wilson",style: TextStyle(color: sh_colorPrimary2,fontSize: 20,fontFamily: 'Bold')),
                          Text("(Customer Service Manager, JA)",style: TextStyle(color: sh_black,fontSize: 15,fontFamily: 'Regular')),
                          Text("+1 (876) 322-0171",style: TextStyle(color: sh_textColorPrimary,fontSize: 14,fontFamily: 'Regular')),

                          SizedBox(height: 30,),
                          // Text("Charlotte Rajkumar (Customer Service Manager, TT) +1 (868) 752-2398",style: TextStyle(color: sh_app_txt_color,fontSize: 16,fontFamily: 'SemiBold')),
                          Text("Charlotte Rajkumar",style: TextStyle(color: sh_colorPrimary2,fontSize: 20,fontFamily: 'Bold')),
                          Text("(Customer Service Manager, TT)",style: TextStyle(color: sh_black,fontSize: 15,fontFamily: 'Regular')),
                          Text("+1 (868) 752-2398",style: TextStyle(color: sh_textColorPrimary,fontSize: 14,fontFamily: 'Regular')),

                          SizedBox(height: 30,),
                          // Text("Emilie Trotman (Customer Service Manager, BB) +1(246) 289-7104",style: TextStyle(color: sh_app_txt_color,fontSize: 16,fontFamily: 'SemiBold')),
                          Text("Emilie Trotman",style: TextStyle(color: sh_colorPrimary2,fontSize: 20,fontFamily: 'Bold')),
                          Text("(Customer Service Manager, BB)",style: TextStyle(color: sh_black,fontSize: 15,fontFamily: 'Regular')),
                          Text("+1(246) 289-7104",style: TextStyle(color: sh_textColorPrimary,fontSize: 14,fontFamily: 'Regular')),

                          SizedBox(height: 26,),
                        ],
                      ),
                    ),

                  ),
                ),

              ],
            ),
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
                      child: Text("Customer Support",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Cursive'),),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setInt("shiping_index", -2);
                    prefs.setInt("payment_index", -2);
                    launchScreen(context, CartScreen.tag);
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(4, 0, 20, 0),
                    child: Image.asset(
                      sh_new_cart,
                      height: 50,
                      width: 50,
                      color: sh_white,
                    ),
                  ),

                ),
              ],
            ),
          ),
        ),

      ]);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: setUserForm(),
      ),
    );
  }
}
