import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/AddressListModel.dart';
import 'package:thrift/screens/AddNewAddressScreen.dart';
import 'package:thrift/screens/ShipmentScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';

class DefaultAddressScreen extends StatefulWidget {
  static String tag='/DefaultAddressScreen';

  const DefaultAddressScreen({Key? key}) : super(key: key);

  @override
  _DefaultAddressScreenState createState() => _DefaultAddressScreenState();
}

class _DefaultAddressScreenState extends State<DefaultAddressScreen> {
  var selectedAddressIndex = 0;
  var primaryColor;
  var mIsLoading = true;
  var isLoaded = false;
  AddressListModel? _addressModel;

  Future<AddressListModel?> fetchAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      // Map<String, String> headers = {
      //   'Content-Type': 'application/json',
      //   'Accept': 'application/json',
      //   'Authorization': 'Bearer $token',
      // };
      //
      //
      // Response response = await get('https://encros.rcstaging.co.in/wp-json/wooapp/v3/list_shipping_addres', headers: headers);
      // print('https://encros.rcstaging.co.in/wp-json/wooapp/v3/list_shipping_addres $token');
      //
      // final jsonResponse = json.decode(response.body);
      // print('not json address$jsonResponse');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      print(token);

      Response response = await get(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/list_shipping_addres'),
          headers: headers);
      print("https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/list_shipping_addres");

      print('DefaultAddressScreen list_shipping_addres Response status2: ${response.statusCode}');
      print('DefaultAddressScreen list_shipping_addres Response body2: ${response.body}');

      final jsonResponse = json.decode(response.body);



      _addressModel = new AddressListModel.fromJson(jsonResponse);
      print(_addressModel!.data);

      return _addressModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    NewView(int index5) {
      if (selectedAddressIndex == index5) {
        return Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: MaterialButton(
                color: sh_colorPrimary,
                elevation: 0,
                padding: EdgeInsets.only(
                    top: spacing_middle, bottom: spacing_middle),
                onPressed: ()  async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('firstname', _addressModel!.data![index5]!.firstName!);
                  prefs.setString("lastname", _addressModel!.data![index5]!.lastName!);
                  prefs.setString("address1", _addressModel!.data![index5]!.address!);
                  prefs.setString("city", _addressModel!.data![index5]!.city!);
                  prefs.setString("postcode", _addressModel!.data![index5]!.postcode!);
                  prefs.setString("country_id", _addressModel!.data![index5]!.country!);
                  prefs.setString("zone_id", _addressModel!.data![index5]!.state!);


                  prefs.setString('shipment_title',
                      "free_shipping");
                  prefs.setString('shipment_method',
                      "Free shipping");

                  prefs.setString("shipping_charge", "0");
                  // prefs.setString("total_amnt", addShipModel!.total.toString());


                  prefs.commit();
                  launchScreen(context, ShipmentScreen.tag);

                  // launchScreen(context, SelectPaymentScreen.tag);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    text("Deliver to this address",
                        textColor: sh_white, fontFamily: 'Bold')
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        return Container();
      }
    }

    listView(data) {
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
                          text(
                              _addressModel!.data![index]!.firstName! +
                                  " " +
                                  _addressModel!.data![index]!.lastName!,
                              textColor: sh_textColorPrimary,
                              fontFamily: fontMedium,
                              fontSize: textSizeLargeMedium),
                          text(_addressModel!.data![index]!.address!,
                              textColor: sh_textColorPrimary,
                              fontSize: textSizeMedium),
                          text(
                              _addressModel!.data![index]!.city! +
                                  "," +
                                  _addressModel!.data![index]!.state!,
                              textColor: sh_textColorPrimary,
                              fontSize: textSizeMedium),
                          text(
                              _addressModel!.data![index]!.country! +
                                  "," +
                                  _addressModel!.data![index]!.postcode!,
                              textColor: sh_textColorPrimary,
                              fontSize: textSizeMedium),
                          SizedBox(
                            height: spacing_standard_new,
                          ),
                          NewView(index),
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
        itemCount: _addressModel!.data!.length,
      );
    }

    ListValidation(){
      if(_addressModel!.data!.length == 0){
        return Container(
          height: height,
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  'No Address Found',
                  style: TextStyle(
                      fontSize: 20,
                      color: sh_app_blue,
                      fontFamily: 'Bold',
                      fontWeight: FontWeight.bold),

                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: MaterialButton(
                    height: 50,
                    minWidth: double.infinity,
                    shape:
                    RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0)),
                    onPressed: () async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('from', "default");
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddNewAddressScreen()));
                    },
                    color: sh_colorPrimary,
                    child: text("Add New Address",
                        fontFamily: 'Bold',
                        fontSize: textSizeLargeMedium,
                        textColor: sh_white),
                  ),
                )
              ],
            ),
          ),
        );
      }else{
        return listView(_addressModel!.data);
      }
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: sh_app_bar,
        title: Text(
          "Delivery Address",
          style: TextStyle(color: sh_app_black),
        ),
        iconTheme: IconThemeData(color: sh_app_black),
        actionsIconTheme: IconThemeData(color: sh_app_black),
      ),
      body: Container(
        child: Center(
          child: FutureBuilder<AddressListModel?>(
            future: fetchAddress(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 70.0),
                            child: Column(
                              children: <Widget>[
                                ListValidation()
                                // listView(_addressModel.data)
                              ],
                            ),
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
      ),
    );
  }
}
