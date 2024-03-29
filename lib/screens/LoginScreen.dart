import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/database/CartPro.dart';
import 'package:thrift/database/database_hepler.dart';
import 'package:thrift/model/CartModel.dart';
import 'package:thrift/model/GuestCartModel.dart';
import 'package:thrift/model/ShLoginErrorNewModel.dart';
import 'package:thrift/model/ShLoginModel.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/ForgotPasswordScreen.dart';
import 'package:thrift/screens/NewSignUpScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart' ;
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' ;
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:thrift/utils/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thrift/screens/LoginEmailVerifyScreen.dart';

import '../provider/home_product_provider.dart';
import '../provider/pro_det_provider.dart';

class LoginScreen extends StatefulWidget {
  static String tag='/LoginScreen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<CartPro> cartPro = [];
  GuestCartModel? itModel;
  final List<GuestCartModel> itemsModel = [];


  var emailCont = TextEditingController();
  var passwordCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  ShLoginModel? cat_model;
  ShLoginErrorNewModel? err_model;
  CartModel? cart_model;
  // @override
  // void initState() {
  //   super.initState();
  //   isEmailVerified=FirebaseAuth.instance.currentUser!.emailVerified;
  //
  //  toast(isEmailVerified.toString());
  // }

  Future<String?> CreateOrder() async {
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

      // final msg = jsonEncode({
      //   "product_id": pro_id,
      //   "variation_id":var_id
      // });
      Map msg = {
        'cart_data': itemsModel
      };




      var body = json.encode({
        "cart_data": itemsModel
      });

      // String body = json.encode(msg);
      print(body);

      var response;

      response = await http
          .post(Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/add_cart_data'), body: body,headers: headers);

      EasyLoading.dismiss();

      print('LoginScreen add_cart_data Response status2: ${response.statusCode}');
      print('LoginScreen add_cart_data Response body2: ${response.body}');

      final jsonResponse = json.decode(response.body);


      final allRows = await dbHelper.queryAllRows();
      cartPro.clear();
      allRows.forEach((row) => cartPro.add(CartPro.fromJson(row)));
      dbHelper.cleanDatabase();
      cartPro.clear();
      // for (int i = 0; i < cartPro.length; i++) {
      //   final rowsDeleted = await dbHelper.delete(cartPro[i].id!);
      // }

      if(cat_model!.data!.verified=='1'){
        prefs.setString('EmailVerified', "Yes");
        EasyLoading.dismiss();
        fetchCart();
        SaveToken();
        // launchScreen(context, DashboardScreen.tag);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DashboardScreen(selectedTab: 0,)),
          ModalRoute.withName('/DashboardScreen'),
        );
        Provider.of<HomeProductListProvider>(context, listen: false).getLocalCart();
      }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginEmailVerifyScreen()),);
        // await _auth.signInWithEmailAndPassword2(emailCont.text, "12345678").then((
        //     result) async {
        //   EasyLoading.dismiss();
        //   if (result is String) {
        //     // logToFile(printFileLogs());
        //     if (result.contains("user-not-found")) {
        //       toast("user-not-found");
        //       await _auth.registerWithEmailAndPassword(
        //           emailCont.text, "12345678")
        //           .then((result) async {
        //         // logToFile(result);
        //         if (result != null) {
        //           User? _user;
        //           _user = await FirebaseAuth.instance.currentUser;
        //           if (_user != null && !_user.emailVerified) {
        //             // await user.sendEmailVerification();
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) =>
        //                       LoginEmailVerifyScreen()),);
        //           }
        //
        //
        //           // launchScreen(context, DashboardScreen.tag);
        //         } else {
        //           EasyLoading.dismiss();
        //           prefs.setString('UserId', "");
        //           setState(() {
        //             // error = 'Error while registering the user!';
        //             // _isLoading = false;
        //           });
        //         }
        //       });
        //     }
        //     else {
        //       toast("Something went wrong");
        //     }
        //   }
        //   else {
        //     EasyLoading.dismiss();
        //     isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        //     if (isEmailVerified) {
        //       // toast("Verified");
        //       SharedPreferences prefs = await SharedPreferences.getInstance();
        //       prefs.setString('EmailVerified', "Yes");
        //       fetchVerify();
        //       fetchCart();
        //       SaveToken();
        //       launchScreen(context, DashboardScreen.tag);
        //     } else {
        //       // toast("Not Verified");
        //       prefs.setString('EmailVerified', "No");
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) =>
        //                 LoginEmailVerifyScreen()),);
        //     }
        //   }
        // });
      }
      // launchScreen(context, DashboardScreen.tag);



      return null;
    } on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }

  Future<CartModel?> fetchCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      if (token != null && token != '') {
        String? user_country = prefs.getString('user_selected_country');

        print(token);
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

        // Response response = await get(
        //     Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/woocart'),
        //     headers: headers);
        var response = await http.get(
            Uri.parse(
                '${Url.BASE_URL}wp-json/wooapp/v3/woocart?country=$user_country'),
            headers: headers);

        print('LoginScreen woocart Response status2: ${response.statusCode}');
        print('LoginScreen woocart Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);

        cart_model = new CartModel.fromJson(jsonResponse);
        if (cart_model!.cart == null) {
          prefs.setInt("cart_count", 0);
          await dbHelper.cleanDatabase();
        }else if (cart_model!.cart!.length == 0) {
          prefs.setInt("cart_count", 0);
          await dbHelper.cleanDatabase();
        }else{
          prefs.setInt("cart_count", cart_model!.cart!.length);

          await dbHelper.cleanDatabase();
          for (var i = 0; i < cart_model!.cart!.length; i++) {
            Map<String, dynamic> row = {
              DatabaseHelper.columnProductId: cart_model!.cart![i]!.productId.toString(),
              DatabaseHelper.columnProductName: cart_model!.cart![i]!.productName.toString(),
              DatabaseHelper.columnProductImage:
              cart_model!.cart![i]!.productImage!.toString(),
              DatabaseHelper.columnVariationId: "",
              DatabaseHelper.columnVariationName: "",
              DatabaseHelper.columnVariationValue: "",
              DatabaseHelper.columnQuantity: "1",
              DatabaseHelper.columnLine_subtotal: cart_model!.cart![i]!.lineSubtotal.toString(),
              DatabaseHelper.columnLine_total: cart_model!.cart![i]!.lineTotal.toString(),
            };
            CartPro car = CartPro.fromJson(row);
            final id = await dbHelper.insert(car);
          }
          Provider.of<HomeProductListProvider>(context, listen: false).getLocalCart();


        }
      }
// SaveToken();

      return cart_model;
    }  on Exception catch (e) {

      print('caught error $e');
    }
  }

  Future<String?> fetchVerify() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? OrderUserEmail = prefs.getString('OrderUserEmail');

        var response = await http.get(
            Uri.parse(
                '${Url.BASE_URL}wp-json/wooapp/v3/firebase_user_approval?email=$OrderUserEmail'));

        print('LoginScreen firebase_user_approval Response status2: ${response.statusCode}');
        print('LoginScreen firebase_user_approval Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
      emptyCart();
      return 'cart_model';
    }  on Exception catch (e) {

      print('caught error $e');
    }
  }

  Future<String?> emptyCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      print(token);
      if (token != null && token != '') {
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

        Response response = await get(
            Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/empty_cart'),
            headers: headers);


        print('SettingFragment empty_cart Response status2: ${response.statusCode}');
        print('SettingFragment empty_cart Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
      }

      prefs.setInt("cart_count", 0);
      _queryAll();

      // first2=false;

//      print(cat_model.data);
      return "cat_model";
    }on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }


  Future<List<CartPro>> _queryAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final allRows = await dbHelper.queryAllRows();
    cartPro.clear();
    allRows.forEach((row) => cartPro.add(CartPro.fromJson(row)));
    // _showMessageInScaffold('Query done.');
    print(cartPro.length.toString());

    if (cartPro.length > 0) {
      for (int i = 0; i < cartPro.length; i++) {

          itModel = GuestCartModel(
              product_id: cartPro[i].product_id.toString(),
              variation_id: cartPro[i].variation_id.toString(),
              variation: cartPro[i].variation_name.toString(),
              quantity: cartPro[i].quantity.toString(),
              line_subtotal: cartPro[i].line_total.toString(),
              line_total: cartPro[i].line_total.toString());
          itemsModel.add(itModel!);

      }

      CreateOrder();

    } else {
      EasyLoading.dismiss();
      // if (widget.screen_name == 'ProfileScreen') {
      //   launchScreen(context, ProfileScreen.tag);
      // }else if (widget.screen_name == 'OrderListScreen') {
      //   launchScreen(context, OrderListScreen.tag);
      // }else if (widget.screen_name == 'AddressListScreen') {
      //   launchScreen(context, AddressListScreen.tag);
      // }else{
      if(cat_model!.data!.verified=='1'){
        prefs.setString('EmailVerified', "Yes");
        EasyLoading.dismiss();
        fetchCart();
        SaveToken();
        // launchScreen(context, DashboardScreen.tag);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => DashboardScreen(selectedTab: 0,)),
          ModalRoute.withName('/DashboardScreen'),
        );
      }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginEmailVerifyScreen()),);
        // await _auth.signInWithEmailAndPassword2(emailCont.text, "12345678").then((
        //     result) async {
        //   EasyLoading.dismiss();
        //   if (result is String) {
        //     // logToFile(printFileLogs());
        //     if (result.contains("user-not-found")) {
        //       toast("user-not-found");
        //       await _auth.registerWithEmailAndPassword(
        //           emailCont.text, "12345678")
        //           .then((result) async {
        //         // logToFile(result);
        //         if (result != null) {
        //           User? _user;
        //           _user = await FirebaseAuth.instance.currentUser;
        //           if (_user != null && !_user.emailVerified) {
        //             // await user.sendEmailVerification();
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) =>
        //                       LoginEmailVerifyScreen()),);
        //           }
        //
        //
        //           // launchScreen(context, DashboardScreen.tag);
        //         } else {
        //           EasyLoading.dismiss();
        //           prefs.setString('UserId', "");
        //           setState(() {
        //             // error = 'Error while registering the user!';
        //             // _isLoading = false;
        //           });
        //         }
        //       });
        //     }
        //     else {
        //       toast("Something went wrong");
        //     }
        //   }
        //   else {
        //     EasyLoading.dismiss();
        //     isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        //     if (isEmailVerified) {
        //       // toast("Verified");
        //       SharedPreferences prefs = await SharedPreferences.getInstance();
        //       prefs.setString('EmailVerified', "Yes");
        //       fetchVerify();
        //       fetchCart();
        //       SaveToken();
        //       launchScreen(context, DashboardScreen.tag);
        //     } else {
        //       // toast("Not Verified");
        //       prefs.setString('EmailVerified', "No");
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) =>
        //                 LoginEmailVerifyScreen()),);
        //     }
        //   }
        // });
      }
      // launchScreen(context, DashboardScreen.tag);
      // }
    }

    return cartPro;
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
      print('LoginScreen add_device Response status2: ${response.statusCode}');
      print('LoginScreen add_device Response body2: ${response.body}');


      // EasyLoading.dismiss();
      // launchScreen(context, DashboardScreen.tag);
      // launchScreen(context, DashboardScreen.tag);

      return cat_model;
    }  on Exception catch (e) {

      print('caught error $e');
    }
  }

  bool isEmailVerified= false;
  final AuthService _auth = AuthService();

  Future<ShLoginModel?> getLogin() async {

    EasyLoading.show(status: 'Please wait...');
    try {
      String username = emailCont.text;
      String password = passwordCont.text;

      Map data = {
        'username': username,
        'password': password,
      };
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final msg = jsonEncode({"username": username, "password": password});

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
      print('LoginScreen login Response status2: ${response.statusCode}');
      print('LoginScreen login Response body2: ${response.body}');

      if (response.statusCode == 200) {

        cat_model = new ShLoginModel.fromJson(jsonResponse);


        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', cat_model!.data!.token.toString());
        prefs.setString('UserId', cat_model!.ID.toString());
        prefs.setString('is_store_owner', cat_model!.data!.is_store_owner.toString());
        prefs.setString('user_default_country', cat_model!.data!.country!);
        prefs.setString('user_selected_country', cat_model!.data!.country!);
        prefs.setString('vendor_country', cat_model!.data!.country!);


        prefs.setString('profile_name',cat_model!.data!.userNicename!);


        prefs.setString('OrderUserName', cat_model!.data!.displayName!);
        // prefs.setString('OrderFirstName', cat_model!.data!.first_name!);
        // prefs.setString('OrderLastName', cat_model!.data!.last_name!);
        prefs.setString('OrderUserEmail', cat_model!.data!.userEmail!);
        prefs.setString('login_email', cat_model!.data!.userEmail!);
        prefs.commit();
        Provider.of<ProductDetailProvider>(context, listen: false).setLoggedInStatus(true);


        if(cat_model!.data!.verified=='1'){
          prefs.setString('EmailVerified', "Yes");
          emptyCart();

        }
        else {
          await _auth.signInWithEmailAndPassword2(emailCont.text, "12345678").then((
              result) async {
            EasyLoading.dismiss();
            if (result is String) {
              // logToFile(printFileLogs());
              if (result.contains("user-not-found")) {
                toast("user-not-found");
                await _auth.registerWithEmailAndPassword(
                    username, "12345678")
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
                                LoginEmailVerifyScreen()),);
                    }


                    // launchScreen(context, DashboardScreen.tag);
                  } else {
                    EasyLoading.dismiss();
                    prefs.setString('UserId', "");
                    setState(() {
                      // error = 'Error while registering the user!';
                      // _isLoading = false;
                    });
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
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('EmailVerified', "Yes");
                fetchVerify();
                // fetchCart();
                // SaveToken();
                // launchScreen(context, DashboardScreen.tag);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => DashboardScreen(selectedTab: 0,)),
                  ModalRoute.withName('/DashboardScreen'),
                );

              } else {
                // toast("Not Verified");
                prefs.setString('EmailVerified', "No");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginEmailVerifyScreen()),);
              }
            }
          });
        }


      } else {
        EasyLoading.dismiss();
        err_model = new ShLoginErrorNewModel.fromJson(jsonResponse);
        Provider.of<ProductDetailProvider>(context, listen: false).setLoggedInStatus(false);
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


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final node = FocusScope.of(context);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: StreamProvider<NetworkStatus>(
        initialData: NetworkStatus.Online,
        create: (context) =>
        NetworkStatusService().networkStatusController.stream,
        child: NetworkAwareWidget(
          onlineChild: Container(
            height: height,
            width: width,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: height*.55,
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
                        ] ),
                  ),
                  Container(
                    height: height*.5,
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0,4,8,30),
                          child: Image.asset(sh_app_logo,width: width*.6,fit: BoxFit.fill,),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Column(

                        children: [
                          Container(height: height*.5,),
                          Container(
                            width: width*.7,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    onEditingComplete: () =>
                                        node.nextFocus(),
                                    controller: emailCont,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Please Enter Username';
                                      }
                                      return null;
                                    },
                                    cursorColor: sh_app_txt_color,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                                      hintText: "Email/Username",
                                      hintStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                      labelText: "Email/Username",
                                      labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: sh_app_txt_color, width: 1.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:  BorderSide(color: sh_app_txt_color, width: 1.0),
                                      ),
                                    ),
                                    maxLines: 1,
                                    style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                  ),
                                  SizedBox(height: 26,),
                                  TextFormField(
                                    // inputFormatters: [
                                    //   FilteringTextInputFormatter.deny(RegExp('[&]')),
                                    // ],
                                    onEditingComplete: () =>
                                        node.nextFocus(),
                                    obscureText: !this._showPassword,
                                    controller: passwordCont,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Please Enter Password';
                                      }
                                      // else if(!validateStructure(text)){
                                      //   return 'Your password should not contain following\ncharacters: (){}[]|`¬¦ "£%^&*"<>:;#~-+=,';
                                      // }
                                      return null;
                                    },
                                    cursorColor: sh_app_txt_color,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                                      hintText: "Password",
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
                                      labelText: "Password",
                                      labelStyle: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: sh_app_txt_color, width: 1.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:  BorderSide(color: sh_app_txt_color, width: 1.0),
                                      ),
                                    ),
                                    maxLines: 1,
                                    style: TextStyle(color: sh_app_txt_color,fontFamily: 'Regular'),
                                  ),
                                  SizedBox(height: 12,),
                                  InkWell(
                                      onTap: () async{
                                        launchScreen(context,
                                            ForgotPasswordScreen.tag);
                                      },
                                      child: text("Forgot your password?", textColor: sh_textColorPrimary,fontSize: 14.0,fontFamily: 'Regular')),
                                  SizedBox(height: 22,),
                                  InkWell(
                                    onTap: () async {

                                      if (_formKey.currentState!.validate()) {
                                        // TODO submit
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        getLogin();
                                        // await _auth.registerWithEmailAndPassword(
                                        //     emailCont.text, "12345678")
                                        //     .then((result) async {
                                        //   // logToFile(result);
                                        //   if (result != null) {
                                        //     User? _user;
                                        //     _user = await FirebaseAuth.instance.currentUser;
                                        //     if (_user != null && !_user.emailVerified) {
                                        //       // await user.sendEmailVerification();
                                        //       Navigator.push(
                                        //         context,
                                        //         MaterialPageRoute(
                                        //             builder: (context) =>
                                        //                 LoginEmailVerifyScreen()),);
                                        //     }
                                        //
                                        //
                                        //     // launchScreen(context, DashboardScreen.tag);
                                        //   } else {
                                        //     EasyLoading.dismiss();
                                        //     // prefs.setString('UserId', "");
                                        //     setState(() {
                                        //       // error = 'Error while registering the user!';
                                        //       // _isLoading = false;
                                        //     });
                                        //   }
                                        // });
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*.7,
                                      padding: EdgeInsets.only(
                                          top: 6, bottom: 10),
                                      decoration: boxDecoration(
                                          bgColor: sh_btn_color, radius: 10, showShadow: true),
                                      child: text("Log In",
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
                                      text("Don't have an account?", textColor: sh_textColorSecondary,fontSize: 14.0),
                                      Container(
                                        margin: EdgeInsets.only(left: 4),
                                        child: GestureDetector(

                                            child: Text("Sign Up",
                                                style: TextStyle(
                                                    fontSize: textSizeLargeMedium,
                                                    decoration: TextDecoration.underline,
                                                    color: sh_app_txt_color,
                                                    fontFamily: 'Bold'
                                                )),
                                            onTap: () {
                                              launchScreen(context, NewSignUpScreen.tag);
                                            }),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0,40,20,20),
                    child: IconButton(onPressed: () {
                      Navigator.pop(context);
                    }, icon: Icon(Icons.keyboard_arrow_left,color: Colors.white,size: 40,)),
                  ),
                ],
              ),
            ),
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

