import 'dart:async';
import 'dart:convert';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:thrift/model/AddressSuccessModel.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:http/http.dart' as http;

import '../database/CartPro.dart';
import '../database/database_hepler.dart';
import '../model/CartModel.dart';
import '../model/GuestCartModel.dart';
import '../model/ShLoginErrorNewModel.dart';
import '../model/ShLoginModel.dart';
import 'package:http/retry.dart';
import 'package:http/http.dart';

class LoginEmailVerifyScreen extends StatefulWidget {
  const LoginEmailVerifyScreen({Key? key}) : super(key: key);

  @override
  State<LoginEmailVerifyScreen> createState() => _LoginEmailVerifyScreenState();
}

class _LoginEmailVerifyScreenState extends State<LoginEmailVerifyScreen> {
  final dbHelper = DatabaseHelper.instance;
  bool isEmailVerified= false;
  Timer? timer;
  AddressSuccessModel? addressSuccessModel;
  ShLoginModel? catModel;
  ShLoginErrorNewModel? errModel;
  CartModel? cartModel;
  List<CartPro> cartPro = [];
  GuestCartModel? itModel;
  final List<GuestCartModel> itemsModel = [];


  @override
  void initState() {
    super.initState();
    isEmailVerified=FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isEmailVerified){
      sendVerificationEmail();

      timer =Timer.periodic(const Duration(seconds: 3), (timer) {
        checkEmailVerified();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  Future<CartModel?> fetchCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      if (token != null && token != '') {
        String? userCountry = prefs.getString('user_selected_country');

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
                '${Url.BASE_URL}wp-json/wooapp/v3/woocart?country=$userCountry'),
            headers: headers);

        print('LoginScreen woocart Response status2: ${response.statusCode}');
        print('LoginScreen woocart Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);

        cartModel = CartModel.fromJson(jsonResponse);
        if (cartModel!.cart == null) {
          prefs.setInt("cart_count", 0);
          await dbHelper.cleanDatabase();
        }else if (cartModel!.cart!.isEmpty) {
          prefs.setInt("cart_count", 0);
          await dbHelper.cleanDatabase();
        }else{
          prefs.setInt("cart_count", cartModel!.cart!.length);

          await dbHelper.cleanDatabase();
          for (var i = 0; i < cartModel!.cart!.length; i++) {
            Map<String, dynamic> row = {
              DatabaseHelper.columnProductId: cartModel!.cart![i]!.productId.toString(),
              DatabaseHelper.columnProductName: cartModel!.cart![i]!.productName.toString(),
              DatabaseHelper.columnProductImage:
              cartModel!.cart![i]!.productImage!.toString(),
              DatabaseHelper.columnVariationId: "",
              DatabaseHelper.columnVariationName: "",
              DatabaseHelper.columnVariationValue: "",
              DatabaseHelper.columnQuantity: "1",
              DatabaseHelper.columnLine_subtotal: cartModel!.cart![i]!.lineSubtotal.toString(),
              DatabaseHelper.columnLine_total: cartModel!.cart![i]!.lineTotal.toString(),
            };
            CartPro car = CartPro.fromJson(row);
            final id = await dbHelper.insert(car);
          }



        }
      }
// SaveToken();

      return cartModel;
    }  on Exception catch (e) {

      print('caught error $e');
    }
  }

  Future<ShLoginModel?> SaveToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_id');
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({"device_id": deviceId});

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

      return catModel;
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

      if(catModel!.data!.verified=='1'){
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



      return null;
    } on Exception catch (e) {
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
      if(catModel!.data!.verified=='1'){
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


  Future<AddressSuccessModel?> fetchVerify() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? orderUserEmail = prefs.getString('OrderUserEmail');
      // prefs.setString('OrderUserEmail', cat_model!.data!.userEmail!);

      var response = await http.get(
          Uri.parse(
              '${Url.BASE_URL}wp-json/wooapp/v3/firebase_user_approval?email=$orderUserEmail'));

      print('LoginScreen firebase_user_approval Response status2: ${response.statusCode}');
      print('LoginScreen firebase_user_approval Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      EasyLoading.dismiss();
      addressSuccessModel = AddressSuccessModel.fromJson(jsonResponse);
      if(addressSuccessModel!.success!){
        prefs.setString('EmailVerified', "Yes");
        emptyCart();
        // fetchCart();
        // SaveToken();
        // launchScreen(context, DashboardScreen.tag);
      }else{
        toast(addressSuccessModel!.msg!);
      }

      return addressSuccessModel;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
      // return cat_model;
    }
  }

  Future checkEmailVerified()  async{

    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified=FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if(isEmailVerified) {
      timer?.cancel();
      fetchVerify();
    }
  }


  Future sendVerificationEmail()  async{
    try {
      final user = FirebaseAuth.instance.currentUser!;
      // FirebaseDynamicLinks dynamicLinks =
      //     FirebaseDynamicLinks.instance;
      // final DynamicLinkParameters parameters =
      // DynamicLinkParameters(
      //   uriPrefix:
      //   'https://casuarinathrift.page.link',
      //   link: Uri.parse(
      //       'https://casuarinathrift.com/emailVerify?mode=verifyEmail'),
      //   androidParameters:
      //   const AndroidParameters(
      //     packageName: 'com.rc.thrift',
      //     minimumVersion: 0,
      //   ),
      //
      //   iosParameters: const IOSParameters(
      //     bundleId: 'com.rc.cassie',
      //     appStoreId: '6446087879',
      //     minimumVersion: '0',
      //   ),
      // );
      //
      // final Uri dynamicUrl = await dynamicLinks
      //     .buildLink(parameters);
      await user.sendEmailVerification();
    }catch(e){
      print(e.toString());
      toast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return isEmailVerified? DashboardScreen(selectedTab: 0):
    Scaffold(
      backgroundColor: Colors.white,
      body: StreamProvider<NetworkStatus>(
        initialData: NetworkStatus.Online,
        create: (context) =>
        NetworkStatusService().networkStatusController.stream,
        child: NetworkAwareWidget(
          onlineChild: Stack(
            children: [
              SizedBox(
                  height: 200,
                  width: width,
                  child: Image.asset(sh_upper,fit: BoxFit.fill)
                // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
              ),
              SizedBox(
                height: height,
                width: width,
                child: Column(
                  children: [
                    const SizedBox(height: 36,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: IconButton(onPressed: () {
                            Navigator.pop(context);
                          }, icon: const Icon(Icons.keyboard_arrow_left,color: Colors.white,size: 36,)),
                        ),

                        const Center(child: Text("Verify Email",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive',fontWeight: FontWeight.normal),))
                      ],
                    ),
                    const SizedBox(height: 50,),
                    Center(
                      child: SizedBox(
                        width: width*.7,
                        height: height*.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            const Text("A Verification email has been sent to your email.",style: TextStyle(color: sh_textColorPrimary,fontSize: 18),textAlign: TextAlign.center,),
                            const SizedBox(height: 50,),
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                                onPressed: sendVerificationEmail, icon: const Icon(Icons.email,size: 32,color: sh_white,), label: const Text('Resend Email',style: TextStyle(color: sh_white,fontSize: 24)))

                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              )
            ],
          ),
          offlineChild: Center(
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

    );
  }
}
