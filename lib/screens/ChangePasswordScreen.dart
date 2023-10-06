import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/CouponErrorModel.dart';
import 'package:thrift/model/CouponModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';


class ChangePasswordScreen extends StatefulWidget {
  static String tag='/ChangePasswordScreen';
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var oldpasswordCont = TextEditingController();
  var passwordCont = TextEditingController();
  var confirmPasswordCont = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool _showOldPassword = false;
  bool _showPassword = false;
  bool _showCnfrmPassword = false;
  // ShLoginModel cat_model;
  final _formKey = GlobalKey<FormState>();
  // ChangePassModel changePassModel;
  CouponModel? couponModel;
  CouponErrorModel? couponErrorModel;
  int? cart_count;

  @override
  void initState() {
    super.initState();
  }

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


  Future<String?> getChange() async {
    String password = passwordCont.text;
    String oldpassword=oldpasswordCont.text;

    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');

      print(token);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };


      final body = jsonEncode({
        'old_password': oldpassword,
        'new_password': password
      });


      print(body);

      Response response = await post(
        Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/wooapp_change_password'),
        headers: headers,
        body: body,
      );

      final jsonResponse = json.decode(response.body);

      print('ChangePasswordScreen wooapp_change_password Response status2: ${response.statusCode}');
      print('ChangePasswordScreen wooapp_change_password Response body2: ${response.body}');
      EasyLoading.dismiss();
      couponModel = new CouponModel.fromJson(jsonResponse);
      if (couponModel!.success!) {
        toast("Password Change Successfully");
        Route route = MaterialPageRoute(builder: (context) => DashboardScreen(selectedTab: 0,));
        Navigator.pushReplacement(context, route);
      } else {
        couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
        toast(couponErrorModel!.error!);
      }

    } catch (e) {
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final node = FocusScope.of(context);

    BadgeCount(){
      if(cart_count==0){
        return Image.asset(
          sh_new_cart,
          height: 50,
          width: 50,
          fit: BoxFit.fill,
          color: sh_white,
        );
      }else{
        return Badge(
          position: BadgePosition.topEnd(top: 4, end: 6),
          badgeContent: Text(cart_count.toString(),style: TextStyle(color: sh_white),),
          child: Image.asset(
            sh_new_cart,
            height: 50,
            width: 50,
            fit: BoxFit.fill,
            color: sh_white,
          ),
        );
      }
    }

    viewOrderDetail() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: spacing_standard_new),
          Center(
              child: Text(
                'Your new password must be different from previous used password',
                style: TextStyle(
                    color: sh_colorPrimary2,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            // inputFormatters: [
            //   FilteringTextInputFormatter.deny(RegExp('[&]')),
            // ],
            autofocus: false,
            obscureText: !this._showOldPassword,
            controller: oldpasswordCont,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
                color: sh_textColorPrimary,
                fontFamily: fontRegular,
                fontSize: textSizeMedium),
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Please Enter Password';
              }else if(!validateStructure(text)){
                return 'Your password should not contain following\ncharacters: (){}[]|`¬¦ "£%^&*"<>:;#~-+=,';
              }
              return null;
            },
            decoration: InputDecoration(
                filled: false,
                hintText: sh_hint_current_password,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: this._showOldPassword ? sh_colorPrimary2 : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => this._showOldPassword = !this._showOldPassword);
                  },
                ),
                hintStyle: TextStyle(
                    color: sh_textColorSecondary,
                    fontFamily: fontRegular,
                    fontSize: textSizeMedium),
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 0.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 0))),
          ),
          SizedBox(
            height: 16,
          ),
          TextFormField(
            // inputFormatters: [
            //   FilteringTextInputFormatter.deny(RegExp('[&]')),
            // ],
            autofocus: false,
            obscureText: !this._showPassword,
            controller: passwordCont,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
                color: sh_textColorPrimary,
                fontFamily: fontRegular,
                fontSize: textSizeMedium),
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Please Enter Password';
              }else if(!validateStructure(text)){
                return 'Your password should not contain following\ncharacters: (){}[]|`¬¦ "£%^&*"<>:;#~-+=,';
              }
              return null;
            },
            decoration: InputDecoration(
                filled: false,
                hintText: sh_hint_new_password,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: this._showPassword ? sh_colorPrimary2 : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => this._showPassword = !this._showPassword);
                  },
                ),
                hintStyle: TextStyle(
                    color: sh_textColorSecondary,
                    fontFamily: fontRegular,
                    fontSize: textSizeMedium),
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 0.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 0))),
          ),
          SizedBox(
            height: 16,
          ),
          TextFormField(
            // inputFormatters: [
            //   FilteringTextInputFormatter.deny(RegExp('[&]')),
            // ],
            autofocus: false,
            obscureText: !this._showCnfrmPassword,
            controller: confirmPasswordCont,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
                color: sh_textColorPrimary,
                fontFamily: fontRegular,
                fontSize: textSizeMedium),
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Please Enter Confirm Password';
              }else
              if (text != passwordCont.text) {
                return 'Password Do Not Match';
              }else if(!validateStructure(text)){
                return 'Your password should not contain following\ncharacters: (){}[]|`¬¦ "£%^&*"<>:;#~-+=,';
              }
              return null;
            },
            decoration: InputDecoration(
                filled: false,
                hintText: sh_hint_confirm_password,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: this._showCnfrmPassword ? sh_colorPrimary2 : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() =>
                    this._showCnfrmPassword = !this._showCnfrmPassword);
                  },
                ),
                hintStyle: TextStyle(
                    color: sh_textColorSecondary,
                    fontFamily: fontRegular,
                    fontSize: textSizeMedium),
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 0.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 0))),
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            // height: double.infinity,
            child: MaterialButton(
              padding: EdgeInsets.all(spacing_standard),
              child: text(sh_lbl_update_pswd,
                  fontSize: textSizeNormal,
                  fontFamily: fontMedium,
                  textColor: sh_white),
              textColor: sh_white,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(40.0)),
              color: sh_colorPrimary2,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TODO submit
                  FocusScope.of(context).requestFocus(FocusNode());
                  getChange();
                }
              },
            ),
          ),
        ],
      );
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "My Account",
          style: TextStyle(color: sh_white,fontFamily: 'TitleCursive',fontSize: 24),
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
          child:  Container(
            height: height,
            width: width,
            color: sh_white,
            child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(spacing_standard_new),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          viewOrderDetail(),
                          SizedBox(
                            height: 40,
                          )
                        ],
                      ),
                    ),
                  )),
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
                      child: Text("Change Password",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
                    SizedBox(width: 16,)
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
