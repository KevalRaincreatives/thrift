import 'dart:async';
import 'dart:convert';
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
import '../model/ShLoginErrorNewModel.dart';
import '../model/ShLoginModel.dart';
import 'package:http/retry.dart';

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
  ShLoginModel? cat_model;
  ShLoginErrorNewModel? err_model;
  CartModel? cart_model;


  @override
  void initState() {
    super.initState();
    isEmailVerified=FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isEmailVerified){
      sendVerificationEmail();

      timer =Timer.periodic(Duration(seconds: 3), (timer) {
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



        }
      }
// SaveToken();

      return cart_model;
    }  on Exception catch (e) {

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

  Future<AddressSuccessModel?> fetchVerify() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? OrderUserEmail = prefs.getString('OrderUserEmail');
      // prefs.setString('OrderUserEmail', cat_model!.data!.userEmail!);

      var response = await http.get(
          Uri.parse(
              '${Url.BASE_URL}wp-json/wooapp/v3/firebase_user_approval?email=$OrderUserEmail'));

      print('LoginScreen firebase_user_approval Response status2: ${response.statusCode}');
      print('LoginScreen firebase_user_approval Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      EasyLoading.dismiss();
      addressSuccessModel = new AddressSuccessModel.fromJson(jsonResponse);
      if(addressSuccessModel!.success!){
        prefs.setString('EmailVerified', "Yes");
        fetchCart();
        SaveToken();
        launchScreen(context, DashboardScreen.tag);
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
              Container(
                  height: 200,
                  width: width,
                  child: Image.asset(sh_upper,fit: BoxFit.fill)
                // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
              ),
              Container(
                height: height,
                width: width,
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

                        Center(child: Text("Verify Email",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive',fontWeight: FontWeight.normal),))
                      ],
                    ),
                    SizedBox(height: 50,),
                    Center(
                      child: Container(
                        width: width*.7,
                        height: height*.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text("A Verification email has been sent to your email.",style: TextStyle(color: sh_textColorPrimary,fontSize: 18),textAlign: TextAlign.center,),
                            SizedBox(height: 50,),
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
                                onPressed: sendVerificationEmail, icon: Icon(Icons.email,size: 32,color: sh_white,), label: Text('Resend Email',style: TextStyle(color: sh_white,fontSize: 24)))

                          ],
                        ),
                      ),
                    ),

                  ],
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
