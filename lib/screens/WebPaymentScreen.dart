import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/screens/OrderSuccessScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

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
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
                    // return Container();
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
                        if(url.contains("order-received")){
                          launchScreen(context, OrderSuccessScreen.tag);
                        }
                      },
                      onPageFinished: (String url) {
                        // fetchPayment(url);


                        print('Page finished loading: $url');
                      },
                      gestureNavigationEnabled: true,
                    );
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
                      child: IconButton(onPressed: () {
                        Navigator.pop(context);
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
JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        // ignore: deprecated_member_use
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      });
}
