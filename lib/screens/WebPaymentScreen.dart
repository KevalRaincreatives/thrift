import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:thrift/screens/OrderSuccessScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../database/database_hepler.dart';
import '../provider/home_product_provider.dart';
import 'OrderFailScreen.dart';

class WebPaymentScreen extends StatefulWidget {
  static String tag='/WebPaymentScreen';
  const WebPaymentScreen({Key? key}) : super(key: key);

  @override
  _WebPaymentScreenState createState() => _WebPaymentScreenState();
}

class _WebPaymentScreenState extends State<WebPaymentScreen> {
  String? weburl;
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  // InAppWebViewController? _webViewController;
  // String url = "";
  double progress = 0;


  Future<String?> fetchType() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      weburl = prefs.getString('weburl');

      return weburl;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }

  @override
  void initState() {
    super.initState();
    startTime();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  startTime() async {
    EasyLoading.show(status: 'Please wait...');
    var _duration = Duration(seconds: 5);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() async{
    EasyLoading.dismiss();
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
      }

      prefs.setInt("cart_count", 0);
      final dbHelper = DatabaseHelper.instance;
      final allRows = await dbHelper.queryAllRows();
      dbHelper.cleanDatabase();
      Provider.of<HomeProductListProvider>(context, listen: false).getLocalCart();

      // first2=false;

//      print(cat_model.data);
      return "cat_model";
    }on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }

  Future<bool> _onWillPop()  async{
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cancel Transaction'),
          content: Text('Are you sure you want to cancel this transaction?'),
          actions: <Widget>[
            TextButton(
              onPressed: () { Navigator.of(context).pop(context);
                toast('Payment Failed');},
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              /*Navigator.of(context).pop(true)*/
              child: Text('No'),
            ),
          ],
        ),
      ) ?? false;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Payment",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),

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
          padding: EdgeInsets.fromLTRB(10,0,10,0),
          child: FutureBuilder<String?>(
              future: fetchType(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Builder(builder: (BuildContext context) {

                    return WebView(
                      initialUrl: weburl,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                      onProgress: (int progress) {
                        print("WebView is loading (progress : $progress%)");
                      },
                      javascriptChannels: <JavascriptChannel>{
                        _toasterJavascriptChannel(context),
                      },
                      onPageStarted: (String url) {
                        print('Page started loading: $url');
                        // if(url.contains("order-received")){
                        //   emptyCart();
                        //   launchScreen(context, OrderSuccessScreen.tag);
                        // }else{
                        //
                        // }
                      },
                      onPageFinished: (String url) {
                        // fetchPayment(url);


                        print('Page finished loading: $url');
                        if(url.contains("status=failed&transaction_id=")){
                          emptyCart();
                          launchScreen(context, OrderFailScreen.tag);
                        }else if(url.contains("status=success&transaction_id=")){
                          emptyCart();
                          launchScreen(context, OrderSuccessScreen.tag);
                        }else{

                        }
                      },
                      navigationDelegate: (NavigationRequest request) {
                        // if (request.url == get.url) {
                        //   return NavigationDecision.navigate;
                        // }
                        return NavigationDecision.navigate;
                      },
                      gestureNavigationEnabled: true,
                    );
      //               return InAppWebView(
      //                 initialUrlRequest: URLRequest(url: Uri.parse(weburl!)),
      //                 initialOptions: InAppWebViewGroupOptions(
      //                   crossPlatform:
      //                   InAppWebViewOptions(useShouldOverrideUrlLoading: true),
      //                 ),
      //                 onWebViewCreated: (InAppWebViewController controller) {
      //                   _webViewController = controller;
      //                 },
      //                 onLoadStart: (InAppWebViewController controller, Uri? url) {
      // if(url.toString().contains("order-received")){
      //       launchScreen(context, OrderSuccessScreen.tag);
      //     }
      //                   // setState(() {
      //                   //   this.weburl = url.toString();
      //                   // });
      //                 },
      //                 onLoadStop: (InAppWebViewController controller, Uri? url) async {
      //                   // setState(() {
      //                   //   this.weburl = url.toString();
      //                   // });
      //                 },
      //                 onConsoleMessage: (controller, consoleMessage) {
      //                   print(consoleMessage);
      //                 },
      //                 // onProgressChanged: (InAppWebViewController controller, int progress) {
      //                 //   setState(() {
      //                 //     this.progress = progress / 100;
      //                 //   });
      //                 // },
      //               );
                  });
                }
                // By default, show a loading spinner.
                return Center(child: CircularProgressIndicator());
              }),
        ),
        // Positioned to take only AppBar size
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10,18,10,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.0,2,6,2),
                      child: IconButton(onPressed: () async{
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Cancel Transaction'),
                            content: Text('Are you sure you want to cancel this transaction?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {   Navigator.of(context).pop(true);
                                Navigator.pop(context);
                                toast('Payment Failed');},
                                child: Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                /*Navigator.of(context).pop(true)*/
                                child: Text('No'),
                              ),
                            ],
                          ),
                        );
                        // Navigator.pop(context);
                      }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 32,)),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,6,6,6.0),
                      child: Text("Payment",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
                    )
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
          onlineChild: WillPopScope(
              onWillPop: () async {
                bool closeDialog =await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Cancel Transaction'),
                    content: Text('Are you sure you want to cancel this transaction?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {   Navigator.of(context).pop(true);
                        toast('Payment Failed');},
                        child: Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        /*Navigator.of(context).pop(true)*/
                        child: Text('No'),
                      ),
                    ],
                  ),
                );
                return closeDialog ?? false; // Handle the dialog dismissal via back button
              },
              child: SafeArea(child: setUserForm())),
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
JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        // ignore: deprecated_member_use
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      });
}
