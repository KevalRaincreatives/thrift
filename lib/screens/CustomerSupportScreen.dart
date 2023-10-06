import 'dart:convert';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/TermsModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:url_launcher/url_launcher.dart';


class CustomerSupportScreen extends StatefulWidget {
  static String tag='/CustomerSupportScreen';
  const CustomerSupportScreen({Key? key}) : super(key: key);

  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  TermsModel? termsModel;
  int? cart_count;
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

  Future<TermsModel?> fetchDetails() async {
//    Dialogs.showLoadingDialog(context, _keyLoader);
    try {



      // Response response = await get(
      //     Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/terms'));

      final client = RetryClient(http.Client());
      var response;
      try {
        response=await client.get(
            Uri.parse(
                '${Url.BASE_URL}wp-json/wooapp/v3/customer_service'));
      } finally {
        client.close();
      }
      final jsonResponse = json.decode(response.body);
      termsModel = new TermsModel.fromJson(jsonResponse);

      print('CustomerSupportScreen customer_service Response status2: ${response.statusCode}');
      print('CustomerSupportScreen customer_service Response body2: ${response.body}');



      return termsModel;
    } on Exception catch (e) {
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Reload",
        desc: e.toString(),
        buttons: [
          DialogButton(
            child: const Text(
              "Reload",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            color: sh_colorPrimary2,
          ),
        ],
      ).show().then((value) {setState(() {

      });} );
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    BadgeCount(){
      if(cart_count==0){
        return Image.asset(
          sh_new_cart,
          height: 44,
          width: 44,
          fit: BoxFit.fill,
          color: sh_white,
        );
      }else{
        return Badge(
          position: BadgePosition.topEnd(top: 4, end: 6),
          badgeContent: Text(cart_count.toString(),style: TextStyle(color: sh_white,fontSize: 8),),
          child: Image.asset(
            sh_new_cart,
            height: 44,
            width: 44,
            fit: BoxFit.fill,
            color: sh_white,
          ),
        );
      }
    }

    HtmlText() {
      return Html(
        data: termsModel!.data!.content,
          onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element) {
          print(url);
          List<String> parts = url!.split(':');
          String result = parts.length > 1 ? parts[1] : '';
          print(result); // Output: "after the semicolon"
            //open URL in webview, or launch URL in browser, or any other logic here
            launchUrl( Uri(
              scheme: 'mailto',
              path: result,
            ));
          }
      );
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Customer Support",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
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
          child:   Container(
            height: height,
            width: width,
            padding: EdgeInsets.fromLTRB(26, 0, 26, 0),
            child: FutureBuilder<TermsModel?>(
                future: fetchDetails(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                        child: HtmlText()
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  // By default, show a loading spinner.
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    direction: ShimmerDirection.ltr,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(12,12,50,12),
                      child: Column(
                        children: [
                          Container(
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      18.0, 12, 12, 12),
                                  child:                             Container(
                                    width: double.infinity,
                                    height: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                          SizedBox(height: 10,),
                          Container(
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      18.0, 12, 12, 12),
                                  child:                             Container(
                                    width: double.infinity,
                                    height: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                          SizedBox(height: 10,),
                          Container(
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      18.0, 12, 12, 12),
                                  child:                             Container(
                                    width: double.infinity,
                                    height: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                          SizedBox(height: 10,),
                          Container(
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      18.0, 12, 12, 12),
                                  child:                             Container(
                                    width: double.infinity,
                                    height: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                          SizedBox(height: 10,),
                          Container(
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      18.0, 12, 12, 12),
                                  child:                             Container(
                                    width: double.infinity,
                                    height: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                        ],
                      ),

                    ),
                  );
                }),
          ),
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
                      child: Text("Customer Support",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
                    )
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? UserId = prefs.getString('UserId');
                        String? token = prefs.getString('token');
                        if (UserId != null && UserId != '') {
                          prefs.setInt("shiping_index", -2);
                          prefs.setInt("payment_index", -2);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CartScreen()),).then((value) {   setState(() {
                            // refresh state
                          });});
                        }else{
                          prefs.setInt("shiping_index", -2);
                          prefs.setInt("payment_index", -2);
                          // launchScreen(context, CartScreen.tag);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartScreen()),
                          ).then((value) {
                            setState(() {
                              // refresh state
                            });
                          });
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => LoginScreen(),
                          //   ),
                          // );
                        }
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
                  ],
                ),
              ],
            ),
          ),
        ),

      ]);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
