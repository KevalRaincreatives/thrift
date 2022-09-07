import 'dart:async';
import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/screens/AddressListScreen.dart';
import 'package:thrift/screens/BecameSellerScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/ChangePasswordScreen.dart';
import 'package:thrift/screens/CheckOut.dart';
import 'package:thrift/screens/CreateProductScreen.dart';
import 'package:thrift/screens/CustomerSupportScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/screens/DefaultAddressScreen.dart';
import 'package:thrift/screens/FAQScreen.dart';
import 'package:thrift/screens/ForgotPasswordScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/MyProfileScreen.dart';
import 'package:thrift/screens/NewConfirmScreen.dart';
import 'package:thrift/screens/NewNumberScreen.dart';
import 'package:thrift/screens/NewSignUpScreen.dart';
import 'package:thrift/screens/OrderConfirmScreen.dart';
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
import 'package:thrift/utils/ConnectivityService.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/T3Dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


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

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    // statusBarColor: Colors.red,
      statusBarBrightness: Brightness.light
  ));
  HttpOverrides.global = new MyHttpOverrides();
  // FirebaseCrashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]).then((_) {
  //     runZoned(() {
  //       runApp(MyApp(),
  //       );
  //       configLoading();
  //     }, onError: FirebaseCrashlytics.instance.recordError);
  // });
  runApp(MyApp());
  // runApp( DevicePreview(
  //   enabled: !kReleaseMode,
  //   builder: (context) => MyApp(), // Wrap your app
  // ),);
}

void configLoading() {
  EasyLoading.instance
    // ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = sh_colorPrimary2
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage  (sh_app_logo), context);
    return Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
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
              OrderListScreen.tag: (BuildContext contex) => OrderListScreen(),
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
              NewConfirmScreen.tag: (BuildContext contex) => NewConfirmScreen(),
              SearchScreen.tag: (BuildContext contex) => SearchScreen(),
              WebPaymentScreen.tag: (BuildContext contex) => WebPaymentScreen(),
              BecameSellerScreen.tag: (BuildContext contex) =>
                  BecameSellerScreen(),
              ProductUpdateScreen.tag: (BuildContext contex) =>
                  ProductUpdateScreen(),
              SellerReviewScreen.tag: (BuildContext contex) =>
                  SellerReviewScreen(),
              T3Dialog.tag: (BuildContext context) => T3Dialog(),
              VendorOrderListScreen.tag: (BuildContext context) =>
                  VendorOrderListScreen(),
              VendorOrderDetailScreen.tag: (BuildContext context) =>
                  VendorOrderDetailScreen(),


            },
          );
        }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
class CustomAnimation extends EasyLoadingAnimation {
  CustomAnimation();

  @override
  Widget buildWidget(
      Widget child,
      AnimationController controller,
      AlignmentGeometry alignment,
      ) {
    return Opacity(
      opacity: controller.value,
      child: RotationTransition(
        turns: controller,
        child: child,
      ),
    );
  }
}