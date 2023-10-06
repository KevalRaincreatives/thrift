import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/AddressListModel.dart';
import 'package:thrift/model/ShAddress.dart';
import 'package:thrift/screens/AddNewAddressScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:thrift/utils/error_dialogue.dart';

class AddressListScreen extends StatefulWidget {
  static String tag = '/AddressListScreen';
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}


class _AddressListScreenState extends State<AddressListScreen> {
  var selectedAddressIndex = 0;
  var primaryColor;
  var mIsLoading = true;
  var isLoaded = false;
  AddressListModel? _addressModel;
  Future<AddressListModel>? futureAlbum;
  String? add_from;
  Future<AddressListModel?>? fetchAddressMain;

  @override
  void initState() {
    super.initState();
    fetchAddressMain=fetchAddress();

  }


  Future<AddressListModel?> fetchAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      add_from=prefs.getString("from");

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };


      Response response =
      await get(Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/list_shipping_addres'), headers: headers);

      final jsonResponse = json.decode(response.body);
      print('AddressListScreen list_shipping_addres Response status2: ${response.statusCode}');
      print('AddressListScreen list_shipping_addres Response body2: ${response.body}');
      _addressModel = new AddressListModel.fromJson(jsonResponse);

      if(_addressModel!.data!.length>0) {
        prefs = await SharedPreferences.getInstance();
        prefs.setString('firstname', _addressModel!.data![0]!.firstName!);
        prefs.setString("lastname", _addressModel!.data![0]!.lastName!);
        prefs.setString("address1", _addressModel!.data![0]!.address!);
        prefs.setString("city", _addressModel!.data![0]!.city!);
        prefs.setString("postcode", _addressModel!.data![0]!.postcode!);
        prefs.setString("country_id", _addressModel!.data![0]!.country!);
        prefs.setString("zone_id", _addressModel!.data![0]!.state!);
        prefs.commit();
      }

      return _addressModel;
    } on Exception catch (e) {
      // errorDialogue(context,e.toString());
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
              setState(() {
                fetchAddressMain=fetchAddress();
              });
            },
            color: sh_colorPrimary2,
          ),
        ],
      ).show();
      print('caught error $e');
    }
  }

  Future<AddressListModel?> DeleteAddress(String add_key) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({"address_key": add_key});
      print(msg);

      Response response = await post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/delete_shipping_addres'),
          headers: headers,
          body: msg);

      final jsonResponse = json.decode(response.body);

      print('AddressListScreen delete_shipping_addres Response status2: ${response.statusCode}');
      print('AddressListScreen delete_shipping_addres Response body2: ${response.body}');
      // orderDetailModel = new OrderDetailModel.fromJson(jsonResponse);
      toast('Deleted');
      EasyLoading.dismiss();
      setState(() {});

      return _addressModel;
    }on Exception catch (e) {
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
      ).show().then((value) {
        setState(() {
          fetchAddressMain=fetchAddress();
        });
      });
      print('caught error $e');
    }
  }





  editAddress(model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pages',"normal");
    prefs.setString('from', "address");
    var bool = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AddNewAddressScreen(
              addressModel: model,
            ))) ??
        false;
    if (bool) {
      fetchAddress();
    }
  }

  Future<List<ShAddressModel>> loadAddresses() async {
    String jsonString = await loadContentAsset('assets/address.json');
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse as List)
        .map((i) => ShAddressModel.fromJson(i))
        .toList();
  }

  Future<bool> _onWillPop() async{
    Navigator.pushAndRemoveUntil(
      context,
      // MaterialPageRoute(
      //     builder: (BuildContext context) => DashboardScreen()),
      // ModalRoute.withName('/DashboardScreen'),
      MaterialPageRoute(
          builder: (BuildContext context) => DashboardScreen(selectedTab: 0,)),
      ModalRoute.withName('/DashboardScreen'),
    );
    return false;
  }




  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    listView(data) {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            top: spacing_standard_new, bottom: spacing_standard_new,left: 16,right: 16),
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

                padding: EdgeInsets.all(textSizeNormal),
                margin: EdgeInsets.only(
                  right: spacing_standard_new,
                  left: spacing_standard_new,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: sh_colorPrimary2),
                  color: sh_white,
                  borderRadius: BorderRadius.circular(10.0),
                  // boxShadow: true
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                _addressModel!.data![index]!.firstName! +
                                    " " +
                                    _addressModel!.data![index]!.lastName!,
                                style: TextStyle(
                                    color: sh_textColorPrimary,
                                    fontSize: 16,
                                    fontFamily: fontBold),
                              ),

                            ],
                          ),
                          SizedBox(height: 8,),
                          Text(
                            _addressModel!.data![index]!.address! +
                                ", " + _addressModel!.data![index]!.city!+",",
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 14,
                                fontFamily: fontRegular),
                          ),
                          SizedBox(height: 6,),
                          Text(
                            _addressModel!.data![index]!.state! +
                                " - " + _addressModel!.data![index]!.postcode!,
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 14,
                                fontFamily: fontRegular),
                          ),
                          SizedBox(height: 6,),
                          Text(
                            _addressModel!.data![index]!.country!,
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 14,
                                fontFamily: fontRegular),
                          ),
                          SizedBox(height: 12,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () async{
                                  editAddress(_addressModel!.data![index]);
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  decoration: boxDecoration(
                                      bgColor: sh_btn_color,
                                      radius: 6,
                                      showShadow: true),
                                  child: text("EDIT",
                                      textColor: sh_colorPrimary2,
                                      isCentered: true,
                                      fontSize: 12.0,
                                      fontFamily: 'Bold'),
                                ),
                              ),
                              InkWell(
                                onTap: () async{
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false, // user must tap button for close dialog!
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Alert!'),
                                        content: Text("Do you want to delete this address?"),
                                        actions: [
                                          TextButton(
                                            child: const Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop(ConfirmAction.CANCEL);
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Yes'),
                                            onPressed: () {
                                              Navigator.of(context).pop(ConfirmAction.CANCEL);
//                    launchScreen(context, ShCartScreen.tag);
                                              DeleteAddress(_addressModel!.data![index]!.key!);
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  decoration: boxDecoration(
                                      bgColor: sh_btn_color,
                                      radius: 6,
                                      showShadow: true),
                                  child: text("DELETE",
                                      textColor: sh_colorPrimary2,
                                      isCentered: true,
                                      fontSize: 12.0,
                                      fontFamily: 'Bold'),
                                ),
                              ),
                            ],)

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

    NewView(int index5) {
      if (selectedAddressIndex == index5) {
        return Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: MaterialButton(
                color: sh_colorPrimary2,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(8.0) ),
                elevation: 0,
                padding: EdgeInsets.only(
                    top: spacing_middle, bottom: spacing_middle),
                onPressed: ()  async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('address_pos', index5.toString());
                  // prefs.setString("lastname", _addressModel!.data![index5]!.lastName!);
                  // prefs.setString("address1", _addressModel!.data![index5]!.address!);
                  // prefs.setString("city", _addressModel!.data![index5]!.city!);
                  // prefs.setString("postcode", _addressModel!.data![index5]!.postcode!);
                  // prefs.setString("country_id", _addressModel!.data![index5]!.country!);
                  // prefs.setString("zone_id", _addressModel!.data![index5]!.state!);
                  //
                  //
                  // prefs.setString('shipment_title',
                  //     "free_shipping");
                  // prefs.setString('shipment_method',
                  //     "Free shipping");
                  //
                  // prefs.setString("shipping_charge", "0");
                  // prefs.setString("total_amnt", addShipModel!.total.toString());


                  prefs.commit();
                  Route route =
                  MaterialPageRoute(builder: (context) => CartScreen());
                  Navigator.pushReplacement(context, route);

                  // launchScreen(context, SelectPaymentScreen.tag);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    text("Deliver to this address",
                        textColor: sh_white, fontFamily: 'Bold',fontSize: 17.0)
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

    listView_radio(data) {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            top: spacing_standard_new, bottom: spacing_standard_new,left: 16,right: 16),
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

                padding: EdgeInsets.fromLTRB(10,20,20,20),
                margin: EdgeInsets.only(
                  right: spacing_standard_new,
                  left: spacing_standard_new,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: sh_colorPrimary2),
                  color: sh_white,
                  borderRadius: BorderRadius.circular(10.0),
                  // boxShadow: true
                ),
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
                        activeColor: sh_colorPrimary2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                _addressModel!.data![index]!.firstName! +
                                    " " +
                                    _addressModel!.data![index]!.lastName!,
                                style: TextStyle(
                                    color: sh_textColorPrimary,
                                    fontSize: 16,
                                    fontFamily: fontBold),
                              ),

                            ],
                          ),
                          SizedBox(height: 10,),
                          Text(
                            _addressModel!.data![index]!.address! +
                                ", " + _addressModel!.data![index]!.city!+",",
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 14,
                                fontFamily: fontRegular),
                          ),
                          SizedBox(height: 6,),
                          Text(
                            _addressModel!.data![index]!.state! +
                                " - " + _addressModel!.data![index]!.postcode!,
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 14,
                                fontFamily: fontRegular),
                          ),
                          SizedBox(height: 6,),
                          Text(
                            _addressModel!.data![index]!.country!,
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 14,
                                fontFamily: fontRegular),
                          ),
                          SizedBox(height: 12,),

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
          height: height-130,
          alignment: Alignment.center,
          child: Center(
            child: Text(
              'No Address Found',
              style: TextStyle(
                  fontSize: 20,
                  color: sh_colorPrimary2,
                  fontFamily: 'Bold',
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      else{
      if(add_from=="address") {
        return listView(_addressModel!.data);
      }else{
    return listView_radio(_addressModel!.data);
      }
      }
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          sh_lbl_address_manager,
          style:
          TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          IconButton(
              color: sh_white,
              icon: Icon(Icons.add),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('from', "address");

                var bool = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddNewAddressScreen())) ?? false;
                // if (bool) {
                //   fetchData();
                // }
              }),
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
            child: Image.asset(sh_upper2, fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Container(
          height: height,
          width: width,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          color: sh_white,
          child: WillPopScope(
            onWillPop: _onWillPop,
            child: Container(
              color: sh_white,
              child: Center(
                child: FutureBuilder<AddressListModel?>(
                  future: fetchAddressMain,
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
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: 10.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: double.infinity,
                                height: 10.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 40.0,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 40.0,
                                height: 8.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        itemCount: 6,
                      ),
                    );
                  },
                ),
              ),
            ),
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
                      child: Text(   sh_lbl_address_manager,style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
                    )
                  ],
                ),
      IconButton(
      color: sh_white,
      icon: Icon(Icons.add),
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("from") == 'address') {
        prefs.setString('from', "address");
      }else{
        prefs.setString('from', "default2");
      }
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('from', "address");

      var bool = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddNewAddressScreen())) ?? false;
      // if (bool) {
      //   fetchData();
      // }
      }),
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
