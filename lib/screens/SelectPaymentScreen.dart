import 'dart:convert';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/screens/OrderConfirmScreen.dart';
import 'package:thrift/screens/PaymentModel.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';

class SelectPaymentScreen extends StatefulWidget {
  static String tag='/SelectPaymentScreen';
  const SelectPaymentScreen({Key? key}) : super(key: key);

  @override
  _SelectPaymentScreenState createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen> {
  PaymentModel? paymentModel;
  Future<PaymentModel>? futureAlbum;
  var scrollController = new ScrollController();
  var errorMsg = '';
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  var selectedAddressIndex = 0;
  var primaryColor;

  Future<PaymentModel?> fetchAlbum() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Response response = await get(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/list_payment_method'),
          headers: headers);
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      paymentModel = new PaymentModel.fromJson(jsonResponse);
      print(paymentModel!.data);
      return paymentModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    listView() {
      return ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
            top: spacing_standard_new, bottom: spacing_standard_new),
        itemBuilder: (item, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: spacing_standard_new),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedAddressIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.all(spacing_standard_new),
                margin: EdgeInsets.only(
                  right: spacing_standard_new,
                  left: spacing_standard_new,
                ),
                color: sh_white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Radio(
                        value: index,
                        groupValue: selectedAddressIndex,
                        onChanged: (int? value) {
                          setState(() {
                            selectedAddressIndex = value!;
                          });
                        },
                        activeColor: primaryColor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(paymentModel!.data![index]!.title,
                              textColor: sh_textColorPrimary,
                              fontFamily: fontMedium,
                              fontSize: textSizeLargeMedium),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        shrinkWrap: true,
        itemCount: paymentModel!.data!.length,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sh_app_bar,
        title: text("Select Payment",
            textColor: sh_textColorPrimary,
            fontSize: textSizeNormal,
            fontFamily: fontBold),
        iconTheme: IconThemeData(color: sh_textColorPrimary),
      ),
      body: Container(
        height: height,
        child: Center(
          child: FutureBuilder<PaymentModel?>(
            future: fetchAlbum(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      listView(),
                      SizedBox(
                        width: double.infinity,
                        child: MaterialButton(
                          color: sh_colorPrimary,
                          elevation: 0,
                          padding: EdgeInsets.all(spacing_standard_new),
                          child: text(sh_lbl_continue,
                              textColor: sh_white,
                              fontFamily: fontMedium,
                              fontSize: textSizeLargeMedium),
                          onPressed: () async {
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            prefs.setString('payment_method',
                                paymentModel!.data![selectedAddressIndex]!.id!);
                            prefs.setString('payment_type',
                                paymentModel!.data![selectedAddressIndex]!.title!);
                            prefs.setString('publish_key',
                                paymentModel!.data![selectedAddressIndex]!.publishableKey!);
                            prefs.setString('secret_key',
                                paymentModel!.data![selectedAddressIndex]!.secretKey!);
                            if(paymentModel!.data![selectedAddressIndex]!.testmode!) {
                              prefs.setString('testmode',"True");
                            }else{
                              prefs.setString('testmode',"False");
                            }

                            launchScreen(context, OrderConfirmScreen.tag);


                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     listView,
        //     SizedBox(
        //       width: double.infinity,
        //       child: MaterialButton(
        //         color: sh_colorPrimary,
        //         elevation: 0,
        //         padding: EdgeInsets.all(spacing_standard_new),
        //         child: text("Continue", textColor: sh_white, fontFamily: fontMedium, fontSize: textSizeLargeMedium),
        //         onPressed: () async{
        //          launchScreen(context, PaymentsScreen.tag);
        //         },
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
