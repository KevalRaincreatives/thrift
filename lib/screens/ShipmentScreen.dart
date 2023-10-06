import 'dart:convert';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/AddShipModel.dart';
import 'package:thrift/model/ShipmentModel.dart';
import 'package:thrift/screens/SelectPaymentScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';

class ShipmentScreen extends StatefulWidget {
  static String tag = '/ShipmentScreen';
  const ShipmentScreen({Key? key}) : super(key: key);

  @override
  _ShipmentScreenState createState() => _ShipmentScreenState();
}

class _ShipmentScreenState extends State<ShipmentScreen> {
  var selectedAddressIndex = 0;

  var primaryColor;
  var mIsLoading = true;
  var isLoaded = false;
  List<ShipmentModel> shipmentModel = [];
  Map<String, Object>? opSelected;
  Future<ShipmentModel>? futureAlbum;
  AddShipModel? addShipModel;

  Future<List<ShipmentModel>?> fetchState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Response response = await get(
          Uri.parse('${Url.BASE_URL}wp-json/wc/v3/shipping_methods'),
          headers: headers);
      final jsonResponse = json.decode(response.body);
      print('ShipmentScreen shipping_methods Response status2: ${response.statusCode}');
      print('ShipmentScreen shipping_methods Response body2: ${response.body}');
      shipmentModel.clear();
      for (Map i in jsonResponse) {
        shipmentModel.add(ShipmentModel.fromJson(i));
//        orderListModel = new OrderListModel2.fromJson(i);
      }

      return shipmentModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<AddShipModel?> GetShip(String ship_id) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
//      print

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({
        "shipping_method": ship_id,
        "country_code":"IN"
      });
      print(msg);

      Response response = await post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/add_shipping_charge'),
          headers: headers,
          body: msg);
      EasyLoading.dismiss();
      print('ShipmentScreen add_shipping_charge Response status2: ${response.statusCode}');
      print('ShipmentScreen add_shipping_charge Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);


      addShipModel = new AddShipModel.fromJson(jsonResponse);
      prefs.setString("shipping_charge", addShipModel!.shippingCharge!.toString());
      prefs.setString("total_amnt", addShipModel!.total.toString());
      launchScreen(context, SelectPaymentScreen.tag);


//      print(cat_model.data);
      return addShipModel;
    } catch (e) {
      print('caught error $e');
      // return cat_model;
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
                          text(shipmentModel[index].title,
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
        itemCount: shipmentModel.length,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sh_app_bar,
        title: text("Select Shipment",
            textColor: sh_textColorPrimary,
            fontSize: textSizeNormal,
            fontFamily: fontBold),
        iconTheme: IconThemeData(color: sh_textColorPrimary),
      ),
      body: Container(
        height: height,
        child: Center(
          child: FutureBuilder<List<ShipmentModel>?>(
            future: fetchState(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                          child: listView()),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: double.infinity,
                          child: MaterialButton(
                            color: sh_colorPrimary,
                            elevation: 0,
                            padding: EdgeInsets.all(spacing_standard_new),
                            child: text("Continue",
                                textColor: sh_white,
                                fontFamily: fontMedium,
                                fontSize: textSizeLargeMedium),
                            onPressed: () async {
                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              prefs.setString('shipment_title',
                                  shipmentModel[selectedAddressIndex].id!);
                              prefs.setString('shipment_method',
                                  shipmentModel[selectedAddressIndex].title!);
                              GetShip(shipmentModel[selectedAddressIndex].id!);
                            },
                          ),
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
