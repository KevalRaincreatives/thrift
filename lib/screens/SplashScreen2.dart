import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/retry.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/CartModel.dart';
import 'package:thrift/model/SettingModel.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/LandingScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart' hide finish;
import 'package:http/http.dart' as http;
import 'package:thrift/utils/delayed_animation.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;


class SplashScreen extends StatefulWidget {
  static String tag='/SplashScreen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  final int delayedAmount=500;
  double? _scale;
  AnimationController? _controller;

  Future<SettingModel>? futuredetail;
  SettingModel? setting_model;
  CartModel? cat_model;
  FirebaseMessaging? messaging;


  @override
  void initState() {
    // startTime();
    _controller=AnimationController(
      vsync: this,
      duration: Duration(microseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1
    )..addListener(() {setState(() {

    });}
    );
    initializeFlutterFire();
    messaging = FirebaseMessaging.instance;
    messaging!.getToken().then((value){
      print("my token : "+value!);

      _addToken(value);
    });

    setupInteractedMessage();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      // print("message recieved2"+event.data.toString());
      print("message title5"+event.notification!.title!);
      print("message body5"+event.notification!.body!);
      // print("message activity5"+event.data["activity"]);
      // print("message activity_id5"+event.data["activity_id"]);
      // toast(event.notification!.body);

    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async{
      print('Message clicked!');
      // print("message title6"+message.notification!.title!);
      // print("message body6"+message.notification!.body!);
      // print("message activity6"+message.data["activity"]);
      // print("message activity_id6"+message.data["activity_id"]);
      // toast("eventstt");
    });

    fetchDetail2();
    super.initState();


  }



  Future<SettingModel?> fetchDetail2() async {

    // EasyLoading.show(status: 'loading...');
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');

      // Response response = await get(
      //     'https://encros.rcstaging.co.in/wp-json/wooapp/v3/woosettings/');
      // var response = await http.get(
      //     Uri.parse("https://encros.rcstaging.co.in//wp-json/wooapp/v3/woosettings/")
      // );

      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.get(
          // "https://encros.rcstaging.co.in/wp-json/wooapp/v3/woosettings/",
            Uri.parse("https://encros.rcstaging.co.in//wp-json/wooapp/v3/woosettings/")
        );
      } finally {
        client.close();
      }

      final jsonResponse = json.decode(response.body);
      print('not json woosettings$jsonResponse');
      setting_model = new SettingModel.fromJson(jsonResponse);
      // String gfg=setting_model!.woosettings!.currencySymbol;
      // new String.fromCharCodes(new Runes('\u+$gfg'));

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('WPLANG',
          setting_model!.woosettings!.WPLANG.toString());
      prefs.setString('privacy_policy',
          setting_model!.woosettings!.wpPageForPrivacyPolicy.toString());
      prefs.setString('store_address',
          setting_model!.woosettings!.woocommerceStoreAddress.toString());
      prefs.setString('store_city',
          setting_model!.woosettings!.woocommerceStoreCity.toString());
      prefs.setString('default_country',
          setting_model!.woosettings!.woocommerceDefaultCountry.toString());
      prefs.setString('store_postcode',
          setting_model!.woosettings!.woocommerceStorePostcode.toString());
      prefs.setString('currency', "\$");
      prefs.setString('currency_pos',
          setting_model!.woosettings!.woocommerceCurrencyPos.toString());
      prefs.setString('price_thousand_sep',
          setting_model!.woosettings!.woocommercePriceThousandSep.toString());
      prefs.setString('price_decimal_sep',
          setting_model!.woosettings!.woocommercePriceDecimalSep.toString());
      prefs.setString('price_num_decimals', setting_model!.woosettings!.woocommerce_price_num_decimals.toString());
      prefs.setString('weight_unit',
          setting_model!.woosettings!.woocommerceWeightUnit.toString());
      prefs.setString('dimension_unit',
          setting_model!.woosettings!.woocommerceDimensionUnit.toString());
      prefs.setString('enable_reviews',
          setting_model!.woosettings!.woocommerceEnableReviews.toString());
      prefs.setString('enable_guest_checkout',
          setting_model!.woosettings!.woocommerceEnableGuestCheckout.toString());
      prefs.setString(
          'registration_generate_username',
          setting_model!.woosettings!.woocommerceRegistrationGenerateUsername
              .toString());
      prefs.setString('email_from_name',
          setting_model!.woosettings!.woocommerceEmailFromName.toString());
      prefs.setString('email_from_address',
          setting_model!.woosettings!.woocommerceEmailFromAddress.toString());
      prefs.setString('terms_page_id',
          setting_model!.woosettings!.woocommerceTermsPageId.toString());
      // prefs.setString('currency_symbol', setting_model!.woosettings!.currencySymbol
      //     .toString());
      // prefs.setString('currency_symbol', "\$");
      if(setting_model!.woosettings!.woocommerceCurrency=='EUR'){
        prefs.setString('currency_symbol', "\€");
      }else{
        prefs.setString('currency_symbol', "\$");
      }
      prefs.setString('phone_no', setting_model!.woosettings!.phoneNo.toString());
      prefs.setString("adv_image", "0");
      // prefs.setString('apps_logo', setting_model!.woosettings!.log.toString());

      fetchCart();
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      return setting_model;
    } catch (e) {
      // EasyLoading.dismiss();
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print('caught error $e');
    }
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async{

  }



  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  _addToken(String fcm_token) async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('device_id',fcm_token);
    } catch (e) {

    }
  }

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();

      if (_kTestingCrashlytics) {
        // Force enable crashlytics collection enabled if we're testing it.
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      } else {
        // Else only enable it in non-debug builds.
        // You could additionally extend this to allow users to opt-in.
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(!kDebugMode);
      }

      if (_kShouldTestAsyncErrorOnInit) {
        await _testAsyncErrorOnInit();
      }
    } catch (e) {
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
        //     Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/woocart'),
        //     headers: headers);
        var response = await http.get(
            Uri.parse(
                'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/woocart?country=$user_country'),
            headers: headers);

        print('Response status2: ${response.statusCode}');
        print('Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        print('not json $jsonResponse');
        cat_model = new CartModel.fromJson(jsonResponse);
        if (cat_model!.cart == null) {
          prefs.setInt("cart_count", 0);
        }else if (cat_model!.cart!.length == 0) {
          prefs.setInt("cart_count", 0);
        }else{
          prefs.setInt("cart_count", cat_model!.cart!.length);
        }
      }
      // EasyLoading.dismiss();
      navigationPage();

      return cat_model;
    } catch (e) {
      print('caught error $e');
      // return cat_model;
    }
  }

  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() async{
    // finish(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? final_token = prefs.getString('token');
    if (final_token != null && final_token != '') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DashboardScreen(selectedTab: 0,),
        ),
      );
    }else{
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LandingScreen(),
        ),
      );
      // launchScreen(context, LoginScreen.tag);

    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    _scale=1-_controller!.value;

    return Scaffold(
      backgroundColor: sh_colorPrimary2,
      body: StreamProvider<NetworkStatus>(
        initialData: NetworkStatus.Online,
        create: (context) =>
        NetworkStatusService().networkStatusController.stream,
        child: NetworkAwareWidget(
          onlineChild: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text("Cassie",style: TextStyle(color: sh_white,fontFamily: "Cursive",fontSize: 90),),
              // Text("BY",style: TextStyle(color: sh_white,fontFamily: "Bold",fontSize: 14)),
              DelayedAnimation(delay: delayedAmount+600, child: Text("Cassie",style: TextStyle(color: sh_white,fontFamily: "Cursive",fontSize: 90),),),
              DelayedAnimation(delay: delayedAmount+800, child: Text("BY",style: TextStyle(color: sh_white,fontFamily: "Bold",fontSize: 14)),),
              DelayedAnimation(delay: delayedAmount+1000,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0,8,8,0),
                    child: Image.asset(sh_app_logo,width: width*.35,fit: BoxFit.fill,),
                  ))
              //   Padding(
              //     padding: const EdgeInsets.fromLTRB(8.0,8,8,0),
              //     child: Image.asset(sh_app_logo,width: width*.35,fit: BoxFit.fill,),
              //   )
            ],
          ),),
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

      ;
  }
}
