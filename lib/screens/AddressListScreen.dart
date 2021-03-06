import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/AddressListModel.dart';
import 'package:thrift/model/ShAddress.dart';
import 'package:thrift/screens/AddNewAddressScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';

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
      await get(Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/list_shipping_addres'), headers: headers);

      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      _addressModel = new AddressListModel.fromJson(jsonResponse);
      print(_addressModel!.data);
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
    } catch (e) {
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
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/delete_shipping_addres'),
          headers: headers,
          body: msg);

      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      print('Response body2: ${response.body}');
      // orderDetailModel = new OrderDetailModel.fromJson(jsonResponse);
      toast('Deleted');
      EasyLoading.dismiss();
      setState(() {});

      return _addressModel;
    } catch (e) {
      EasyLoading.dismiss();
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

                padding: EdgeInsets.all(textSizeNormal),
                margin: EdgeInsets.only(
                  right: spacing_standard_new,
                  left: spacing_standard_new,
                ),
                decoration: boxDecoration(
                    radius: 2,
                    showShadow: true,
                    color: sh_white
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
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Regular'),
                              ),

                            ],
                          ),
                          SizedBox(height: 12,),
                          Text(
                            _addressModel!.data![index]!.address! +
                                ", " + _addressModel!.data![index]!.city!+",",
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Regular'),
                          ),
                          SizedBox(height: 8,),
                          Text(
                            _addressModel!.data![index]!.state! +
                                " - " + _addressModel!.data![index]!.postcode!,
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Regular'),
                          ),
                          SizedBox(height: 8,),
                          Text(
                            _addressModel!.data![index]!.country!,
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Regular'),
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

    listView_radio(data) {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
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

                padding: EdgeInsets.all(textSizeNormal),
                margin: EdgeInsets.only(
                  right: spacing_standard_new,
                  left: spacing_standard_new,
                ),
                decoration: boxDecoration(
                    radius: 2,
                    showShadow: true,
                    color: sh_white
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
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Regular'),
                              ),

                            ],
                          ),
                          SizedBox(height: 12,),
                          Text(
                            _addressModel!.data![index]!.address! +
                                ", " + _addressModel!.data![index]!.city!+",",
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Regular'),
                          ),
                          SizedBox(height: 8,),
                          Text(
                            _addressModel!.data![index]!.state! +
                                " - " + _addressModel!.data![index]!.postcode!,
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Regular'),
                          ),
                          SizedBox(height: 8,),
                          Text(
                            _addressModel!.data![index]!.country!,
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Regular'),
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
                    return CircularProgressIndicator();
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
            padding: const EdgeInsets.fromLTRB(0,spacing_middle4,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6.0,2,6,2),
                      child: IconButton(onPressed: () {
                        Navigator.pop(context);
                      }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 36,)),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(   sh_lbl_address_manager,style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Cursive'),),
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

      body: SafeArea(child: setUserForm()),
    );
  }
}
