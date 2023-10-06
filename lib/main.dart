import 'dart:async';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/provider/cart_provider.dart';
import 'package:thrift/provider/pro_det_provider.dart';
import 'package:thrift/provider/profile_provider.dart';
import 'package:thrift/provider/prolist_provider.dart';
import 'package:thrift/provider/search_provider.dart';
import 'package:thrift/provider/seller_profile_provider.dart';
import 'package:thrift/screens/AddressListScreen.dart';
import 'package:thrift/screens/BecameSellerScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/ChangePasswordScreen.dart';
import 'package:thrift/screens/CheckOut.dart';
import 'package:thrift/screens/CreateProductScreen.dart';
import 'package:thrift/screens/CustomerSupportScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/DefaultAddressScreen.dart';
import 'package:thrift/screens/EmailExistVerifyScreen.dart';
import 'package:thrift/screens/FAQScreen.dart';
import 'package:thrift/screens/ForgotPasswordScreen.dart';
import 'package:thrift/screens/LoginEmailVerifyScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/MyProfileScreen.dart';
import 'package:thrift/screens/NewConfirmScreen.dart';
import 'package:thrift/screens/NewNumberScreen.dart';
import 'package:thrift/screens/NewSignUpScreen.dart';
import 'package:thrift/screens/OrderConfirmScreen.dart';
import 'package:thrift/screens/OrderFailScreen.dart';
import 'package:thrift/screens/OrderListScreen.dart';
import 'package:thrift/screens/OrderSuccessScreen.dart';
import 'package:thrift/screens/OtpNewScreen.dart';
import 'package:thrift/screens/OtpScreen.dart';
import 'package:thrift/screens/PaymentOptionScreen.dart';
import 'package:thrift/screens/PaymentScreen.dart';
import 'package:thrift/screens/ProductDetailScreen.dart';
import 'package:thrift/screens/ProductUpdateScreen.dart';
import 'package:thrift/screens/ProductlistScreen.dart';
import 'package:thrift/screens/ProfileScreen.dart';
import 'package:thrift/screens/ResetPasswordScreen.dart';
import 'package:thrift/screens/SearchScreen.dart';
import 'package:thrift/screens/SelectPaymentScreen.dart';
import 'package:thrift/screens/SellerEditProfileScreen.dart';
import 'package:thrift/screens/SellerProfileScreen.dart';
import 'package:thrift/screens/SellerReviewScreen.dart';
import 'package:thrift/screens/ShipmentScreen.dart';
import 'package:thrift/screens/SignUpScreen.dart';
import 'package:thrift/screens/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:thrift/screens/TermsConditionScreen.dart';
import 'package:thrift/screens/VendorOrderDetailScreen.dart';
import 'package:thrift/screens/VendorOrderListScreen.dart';
import 'package:thrift/screens/VerificationScreen.dart';
import 'package:thrift/screens/WebPaymentScreen.dart';
import 'package:thrift/screens/EulaScreen.dart';

import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'provider/home_product_provider.dart';
import 'provider/order_provider.dart';
import 'package:flutter/services.dart';
Future<void>  main() async {
  bool isInDebugMode = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_messageHandler);

  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );



  // FlutterStatusbarcolor.setStatusBarColor(Colors.lightGreen, animate: true);
  HttpOverrides.global = new MyHttpOverrides();
  // FirebaseCrashlytics.instance.enableInDevMode = true;
  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]).then((_) {
  //     runZoned(() {
  //       runApp(MyApp(),
  //       );
  //       configLoading();
  //     }, onError: FirebaseCrashlytics.instance.recordError);
  // });
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
  // runApp(MyApp());
  // runApp( DevicePreview(
  //   enabled: !kReleaseMode,
  //   builder: (context) => MyApp(), // Wrap your app
  // ),);
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  initState() {
    super.initState();
    // initFirebase();
  }

  Future<void> initFirebase() async {
    print("Initial Firebase");
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // await Future.delayed(Duration(seconds: 3));
    initDynamicLinks();
  }
  Future<void> initDynamicLinks() async {
    print("Initial DynamicLinks");
    final PendingDynamicLinkData? data =
    await FirebaseDynamicLinks.instance.getInitialLink();

    if (data?.link != null) {
      final Uri link = data!.link;
      final String action = link.pathSegments.last;

      // Handle the action here
      toast(action);
      final queryParams = link.queryParameters;
      if (queryParams.isNotEmpty) {
        print("Incoming Link :" + link.toString());
        //  your code here
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginEmailVerifyScreen()),);
      } else {
        print("No Current Links");
        // your code here
      }
    }

    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;


    // Incoming Links Listener
    dynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri uri = dynamicLinkData.link;
      final queryParams = uri.queryParameters;
      if (queryParams.isNotEmpty) {
        print("Incoming Link2 :" + uri.toString());
        //  your code here
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginEmailVerifyScreen()),);
      } else {
        print("No Current Links");
        // your code here
      }
    });

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
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage  (sh_app_logo), context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProductListProvider()),
        ChangeNotifierProvider(create: (context) => ProductDetailProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => SellerProfileProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => ProductListProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
      ],
      child: Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Cassie by Casuarina',
              theme: ThemeData(
                primarySwatch: Colors.lightBlue,
                unselectedWidgetColor: sh_app_background,
                disabledColor: sh_colorPrimary2,

              ),
              initialRoute: SplashScreen.tag,
              // navigatorObservers: [MyRouteObserver()],
              builder: EasyLoading.init(),
              // builder: (context, child) {
              //   return StreamBuilder<bool>(
              //       stream: ConnectivityService().connectionChangeController.stream,
              //       builder: (context, snapshot) {
              //         final conenctivityResult = snapshot.data;
              //         if (conenctivityResult == ConnectivityResult.none || conenctivityResult == null) return FAQScreen();
              //
              //           EasyLoading.init();
              //           return FAQScreen();
              //       }
              //   );
              // },
              routes: {
                LoginScreen.tag: (BuildContext contex) => LoginScreen(),
                SignUpScreen.tag: (BuildContext contex) => SignUpScreen(),
                VerificationScreen.tag: (BuildContext contex) =>
                    VerificationScreen(),
                ChangePasswordScreen.tag: (BuildContext contex) =>
                    ChangePasswordScreen(),
                NewNumberScreen.tag: (BuildContext contex) => NewNumberScreen(),
                OtpScreen.tag: (BuildContext contex) => OtpScreen(),
                OtpNewScreen.tag: (BuildContext contex) => OtpNewScreen(),
                // // SCCreatePasswordScreen.tag: (BuildContext contex) => SCCreatePasswordScreen(),
                DashboardScreen.tag: (BuildContext contex) =>
                    DashboardScreen(selectedTab: 0,),
                ProductlistScreen.tag: (BuildContext contex) =>
                    ProductlistScreen(),
                CartScreen.tag: (BuildContext contex) => CartScreen(),
                ProductDetailScreen.tag: (BuildContext contex) =>
                    ProductDetailScreen(),
                SplashScreen.tag: (BuildContext contex) => SplashScreen(),
                AddressListScreen.tag: (BuildContext contex) =>
                    AddressListScreen(),
                SelectPaymentScreen.tag: (BuildContext contex) =>
                    SelectPaymentScreen(),
                ShipmentScreen.tag: (BuildContext contex) => ShipmentScreen(),
                DefaultAddressScreen.tag: (BuildContext contex) =>
                    DefaultAddressScreen(),
                ForgotPasswordScreen.tag: (BuildContext contex) =>
                    ForgotPasswordScreen(),
                ResetPasswordScreen.tag: (BuildContext contex) =>
                    ResetPasswordScreen(),
                OrderConfirmScreen.tag: (BuildContext contex) =>
                    OrderConfirmScreen(),
                // AddCardScreen.tag: (BuildContext contex) => AddCardScreen(),
                CheckOut.tag: (BuildContext contex) => CheckOut(),
                OrderListScreen.tag: (BuildContext contex) => const OrderListScreen(),
                // OrderDetailScreen.tag: (BuildContext contex) => OrderDetailScreen(),
                // SearchScreen.tag: (BuildContext contex) => SearchScreen(),
                MyProfileScreen.tag: (BuildContext contex) => MyProfileScreen(),
                TermsConditionScreen.tag: (BuildContext contex) =>
                    TermsConditionScreen(),

                NewSignUpScreen.tag: (BuildContext contex) => NewSignUpScreen(),
                CreateProductScreen.tag: (BuildContext contex) =>
                    CreateProductScreen(),
                FAQScreen.tag: (BuildContext contex) => FAQScreen(),
                CustomerSupportScreen.tag: (BuildContext contex) =>
                    CustomerSupportScreen(),
                ProfileScreen.tag: (BuildContext contex) => ProfileScreen(),
                PaymentOptionScreen.tag: (BuildContext contex) =>
                    PaymentOptionScreen(),
                SellerProfileScreen.tag: (BuildContext contex) =>
                    SellerProfileScreen(),
                SellerEditProfileScreen.tag: (BuildContext contex) =>
                    SellerEditProfileScreen(),
                PaymentScreen.tag: (BuildContext contex) => PaymentScreen(),
                OrderSuccessScreen.tag: (BuildContext contex) =>
                    OrderSuccessScreen(),
                OrderFailScreen.tag: (BuildContext contex) =>
                    OrderFailScreen(),
                NewConfirmScreen.tag: (BuildContext contex) => NewConfirmScreen(),
                SearchScreen.tag: (BuildContext contex) => SearchScreen(),
                WebPaymentScreen.tag: (BuildContext contex) => WebPaymentScreen(),
                BecameSellerScreen.tag: (BuildContext contex) =>
                    BecameSellerScreen(),
                ProductUpdateScreen.tag: (BuildContext contex) =>
                    ProductUpdateScreen(),
                SellerReviewScreen.tag: (BuildContext contex) =>
                    SellerReviewScreen(),
                VendorOrderListScreen.tag: (BuildContext context) =>
                    VendorOrderListScreen(),
                VendorOrderDetailScreen.tag: (BuildContext context) =>
                    VendorOrderDetailScreen(),
                EulaScreen.tag: (BuildContext context) =>
                    EulaScreen(),
                EmailExistVerifyScreen.tag: (BuildContext context) =>
                    EmailExistVerifyScreen(),


              },
            );
          }
      ),
    );
  }
}

