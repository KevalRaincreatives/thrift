import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/CartModel.dart';
import 'package:thrift/model/SettingModel.dart';
import 'package:thrift/provider/home_product_provider.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/EmailVerifyScreen.dart';
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
import 'package:thrift/screens/SelectCountryScreen.dart';

import '../model/AddressSuccessModel.dart';
import '../model/ShLoginModel.dart';
import '../provider/pro_det_provider.dart';
import '../utils/auth_service.dart';
import 'LoginEmailVerifyScreen.dart';

const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final int delayedAmount = 500;
  double? _scale;
  AnimationController? _controller;

  Future<SettingModel>? futuredetail;
  SettingModel? setting_model;
  CartModel? cat_model;
  FirebaseMessaging? messaging;
  AddressSuccessModel? addressSuccessModel;

  @override
  void initState() {

    internetCheck();
    // fetchDetail2();
    super.initState();
  }


  internetCheck()async{
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // I am not connected to any network.
      // _showToastMessage("Offline");
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {return AlertDialog(
            title: const Text('No Internet Connection'),
            content:  const Text('Please check your internet connection and try again.'),
            actions: <Widget>[
              TextButton(
                child: const Text("RETRY"),
                onPressed: () {
                  Navigator.of(context).pop(ConfirmAction.CANCEL);
                  internetCheck();
                },
              ),
            ],
          );}
      );

    }else{
      Provider.of<ProductDetailProvider>(context, listen: false)
          .getUserLoggedInStatus();
      Provider.of<HomeProductListProvider>(context, listen: false).getLocalCart();
      initializeFlutterFire();
      messaging = FirebaseMessaging.instance;
      messaging!.getToken().then((value) {
        print("my token : " + value!);

        _addToken(value);
      });
      initDynamicLinks();
      setupInteractedMessage();

      FirebaseMessaging.onMessage.listen((RemoteMessage event) {
        print("message recieved");
        // print("message recieved2"+event.data.toString());
        print("message title5" + event.notification!.title!);
        print("message body5" + event.notification!.body!);
        // print("message activity5"+event.data["activity"]);
        // print("message activity_id5"+event.data["activity_id"]);
        // toast(event.notification!.body);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        print('Message clicked!');
        // print("message title6"+message.notification!.title!);
        // print("message body6"+message.notification!.body!);
        // print("message activity6"+message.data["activity"]);
        // print("message activity_id6"+message.data["activity_id"]);
        // toast("eventstt");
      });

    }
  }

  Future<void> initDynamicLinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Initial DynamicLinks");
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (data?.link != null) {
      final Uri link = data!.link;
      final String action = link.pathSegments.last;

      // Handle the action here
      // toast(action);
      final queryParams = link.queryParameters;
      if (queryParams.isNotEmpty) {
        print("Incoming Link :" + link.toString());
        //  your code here
        var auth = FirebaseAuth.instance;
// Retrieve the email from wherever you stored it
        String emailAuth = prefs.getString('login_email').toString().trim();
// Confirm the link is a sign-in with email link.
//         toast(emailAuth.trim());
        final AuthService _auth = AuthService();
        await _auth
            .signInWithEmailAndPassword2(emailAuth, "12345678")
            .then((result) async {
          if (result is String) {
            // logToFile(printFileLogs());
            if (result.contains("user-not-found")) {
              toast("user-not-found");
              await _auth
                  .registerWithEmailAndPassword(emailAuth, "12345678")
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
                          builder: (context) => LoginEmailVerifyScreen()),
                    );
                  }

                  // launchScreen(context, DashboardScreen.tag);
                } else {
                  // EasyLoading.dismiss();
                  prefs.setString('UserId', "");
                  setState(() {
                    // error = 'Error while registering the user!';
                    // _isLoading = false;
                  });
                }
              });
            } else {
              toast("Something went wrong");
            }
          } else {
            // EasyLoading.dismiss();
            // isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
            if (FirebaseAuth.instance.currentUser!.emailVerified) {
              // toast("Verified");
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('EmailVerified', "Yes");
              fetchVerify();
              // fetchCart();
              // SaveToken();
              // launchScreen(context, DashboardScreen.tag);
            } else {
              // toast("Not Verified");
              prefs.setString('EmailVerified', "No");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmailVerifyScreen()),
              );
            }
          }
        });
        // Navigator.of(context).push(
        //     MaterialPageRoute(builder: (context) => EmailVerifyScreen())
        // );
        // if (auth!.emailVerified) {
        // The client SDK will parse the code from the link for you.
        // auth.signInWithEmailLink(email: emailAuth.trim(), emailLink: link.toString())
        //     .then((value) {
        //   // You can access the new user via value.user
        //   // Additional user info profile *not* available via:
        //   // value.additionalUserInfo.profile == null
        //   // You can check if the user is new or existing:
        //
        //   bool newUser = value.additionalUserInfo!.isNewUser;
        //   print(newUser.toString());
        //   var userEmail = value.user;
        //   print(userEmail.toString());
        //   print('Successfully signed in with email link!');
        //   toast('Email Verified Successfully');
        //
        //
        //   fetchVerify();
        // }).catchError((onError) {
        //   print('Error signing in with email link $onError');
        //   toast('Error signing in with email link $onError');
        // });
        //   fetchVerify();
        // }
        // navigationPage2();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) =>
        //           LoginEmailVerifyScreen()),);
      } else {
        print("No Current Links");
        // your code here
      }
    } else {
      startTime();
    }

    // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    //
    //
    // // Incoming Links Listener
    // dynamicLinks.onLink.listen((dynamicLinkData) {
    //   final Uri uri = dynamicLinkData.link;
    //   final queryParams = uri.queryParameters;
    //   if (queryParams.isNotEmpty) {
    //     print("Incoming Link2 :" + uri.toString());
    //     //  your code here
    //
    //       Navigator.pushNamed(
    //         context,
    //         dynamicLinkData.link.path);
    //     navigationPage();
    //
    //   } else {
    //     print("No Current Links");
    //     // your code here
    //   }
    // });

    // FirebaseDynamicLinks.instance.onLink.listen(
    //       (pendingDynamicLinkData) {
    //     // Set up the `onLink` event listener next as it may be received here
    //     if (pendingDynamicLinkData != null) {
    //       final Uri deepLink = pendingDynamicLinkData.link;
    //       toast(deepLink.toString());
    //
    //
    //       // Example of using the dynamic link to push the user to a different screen
    //       // Navigator.pushNamed(context, deepLink.path);
    //     }
    //   },
    // );
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
        response = await client.get(
            // "https://encros.rcstaging.co.in/wp-json/wooapp/v3/woosettings/",
            Uri.parse(
                "https://encros.rcstaging.co.in//wp-json/wooapp/v3/woosettings/"));
      } finally {
        client.close();
      }

      final jsonResponse = json.decode(response.body);
      print(
          'SplashScreen woosettings Response status2: ${response.statusCode}');
      print('SplashScreen woosettings Response body2: ${response.body}');
      setting_model = new SettingModel.fromJson(jsonResponse);
      // String gfg=setting_model!.woosettings!.currencySymbol;
      // new String.fromCharCodes(new Runes('\u+$gfg'));

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('currency', "\$");
      prefs.setString('currency_pos', "l");
      prefs.setString('price_decimal_sep', ":");
      prefs.setString(
          'price_num_decimals',
          setting_model!.woosettings!.woocommerce_price_num_decimals
              .toString());
      prefs.setString('currency_symbol', "\$");
      prefs.setString("adv_image", "0");
      // prefs.setString('apps_logo', setting_model!.woosettings!.log.toString());

      fetchCart();
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      return setting_model;
    } on Exception catch (e) {
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

  void _handleMessage(RemoteMessage message) async {}

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      // print(list[100]);
    });
  }

  _addToken(String fcm_token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('device_id', fcm_token);
    } catch (e) {}
  }

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();

      if (_kTestingCrashlytics) {
        // Force enable crashlytics collection enabled if we're testing it.
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      } else {
        // Else only enable it in non-debug builds.
        // You could additionally extend this to allow users to opt-in.
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      }

      if (_kShouldTestAsyncErrorOnInit) {
        await _testAsyncErrorOnInit();
      }
    } catch (e) {}
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

        print('SplashScreen woocart Response status2: ${response.statusCode}');
        print('SplashScreen woocart Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);

        cat_model = new CartModel.fromJson(jsonResponse);
        if (cat_model!.cart == null) {
          prefs.setInt("cart_count", 0);
        } else if (cat_model!.cart!.length == 0) {
          prefs.setInt("cart_count", 0);
        } else {
          prefs.setInt("cart_count", cat_model!.cart!.length);
        }
      }
      // EasyLoading.dismiss();
      // navigationPage();

      return cat_model;
    } on Exception catch (e) {
      print('caught error $e');
    }
  }

  Future<String?> SaveToken() async {
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
        response = await client.post(
            Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/add_device'),
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

      return 'cat_model';
    } on Exception catch (e) {
      print('caught error $e');
    }
  }

  Future<AddressSuccessModel?> fetchVerify() async {
    // EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? OrderUserEmail = prefs.getString('login_email');
      // prefs.setString('OrderUserEmail', cat_model!.data!.userEmail!);

      var response = await http.get(Uri.parse(
          '${Url.BASE_URL}wp-json/wooapp/v3/firebase_user_approval?email=$OrderUserEmail'));

      print(
          'SplashScreen firebase_user_approval Response status2: ${response.statusCode}');
      print(
          'SplashScreen firebase_user_approval Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      EasyLoading.dismiss();
      addressSuccessModel = new AddressSuccessModel.fromJson(jsonResponse);
      if (addressSuccessModel!.success!) {
        prefs.setString('EmailVerified', "Yes");
        if (prefs.getString('UserId') != null &&
            prefs.getString('UserId') != '') {
          final postMdl =
              Provider.of<HomeProductListProvider>(context, listen: false);
          postMdl.fetchCategory();
          postMdl.getCountry();
          // postMdl.fetchAttribute();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          startTime();
        }
      } else {
        toast(addressSuccessModel!.msg!);
      }

      return addressSuccessModel;
    } catch (e) {
      // EasyLoading.dismiss();
      print('caught error $e');
      // return cat_model;
    }
  }
  NetworkStatus _getNetworkStatus(ConnectivityResult status) {
    return status == ConnectivityResult.mobile || status == ConnectivityResult.wifi ? NetworkStatus.Online : NetworkStatus.Offline;
  }
  startTime() async {

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // I am not connected to any network.
      print('cttc'+'offline');
    }else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? user_selected_country = prefs.getString('user_selected_country');
      if (user_selected_country != null && user_selected_country != '') {
        final postMdl =
        Provider.of<HomeProductListProvider>(context, listen: false);
        await postMdl.getHomeProduct('Newest to Oldest', true);
        navigationPage();
        postMdl.fetchCategory();
        postMdl.getCountry();
        // var _duration = Duration(seconds: 3);
        // return Timer(_duration, navigationPage);

      } else {
        final postMdl =
        Provider.of<HomeProductListProvider>(context, listen: false);
        postMdl.fetchCategory();
        postMdl.getCountry();
        var _duration = Duration(milliseconds: 1000);
        return Timer(_duration, navigationPage);
      }
    }


  }

  void navigationPage2() async {
    // finish(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginEmailVerifyScreen(),
      ),
    );
  }

  void navigationPage() async {
    // finish(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? final_token = prefs.getString('token');
    String? EmailVerified = prefs.getString('EmailVerified');
    prefs.setString('currency', "\$");
    prefs.setString('currency_pos', "l");
    prefs.setString('price_decimal_sep', ":");
    prefs.setString('price_num_decimals', '');
    prefs.setString('currency_symbol', "\$");
    prefs.setString("adv_image", "0");
    if (final_token != null && final_token != '') {
      if (EmailVerified == 'Yes') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              selectedTab: 0,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LandingScreen(),
          ),
        );
      }
    } else {
      if (prefs.getString('user_selected_country') != null &&
          prefs.getString('user_selected_country') != '') {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         DashboardScreen(selectedTab: 0),
        //   ),
        // );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SelectCountryScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SelectCountryScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    // _scale=1-_controller!.value;

    return Scaffold(
      // backgroundColor: sh_colorPrimary2,
      body: StreamProvider<NetworkStatus>(
        initialData: NetworkStatus.Online,
        create: (context) =>
            NetworkStatusService().networkStatusController.stream,
        child: NetworkAwareWidget(
          onlineChild: Container(
            height: height,
            color: sh_colorPrimary2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text("Cassie",style: TextStyle(color: sh_white,fontFamily: "Cursive",fontSize: 90),),
                  // Text("BY",style: TextStyle(color: sh_white,fontFamily: "Bold",fontSize: 14)),
                  // DelayedAnimation(delay: delayedAmount+600, child: Text("Cassie",style: TextStyle(color: sh_white,fontFamily: "Cursive",fontSize: 90),),),
                  // DelayedAnimation(delay: delayedAmount+800, child: Text("BY",style: TextStyle(color: sh_white,fontFamily: "Bold",fontSize: 14)),),
                  // DelayedAnimation(delay: delayedAmount+1000,
                  //     child: Padding(
                  //       padding: const EdgeInsets.fromLTRB(8.0,8,8,0),
                  //       child: Image.asset(sh_app_logo,width: width*.35,fit: BoxFit.fill,),
                  //     ))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
                    child: Image.asset(
                      sh_app_logo,
                      width: width * .6,
                      fit: BoxFit.fill,
                    ),
                  )
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
