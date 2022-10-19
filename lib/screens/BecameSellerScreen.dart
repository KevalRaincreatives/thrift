import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';
import 'package:thrift/model/BecameSellerModel.dart';
import 'package:thrift/model/CountryParishModel.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';


class BecameSellerScreen extends StatefulWidget {
  static String tag='/BecameSellerScreen';
  const BecameSellerScreen({Key? key}) : super(key: key);

  @override
  _BecameSellerScreenState createState() => _BecameSellerScreenState();
}

class _BecameSellerScreenState extends State<BecameSellerScreen> {
  final _formKey = GlobalKey<FormState>();
  var ShopNameCont= TextEditingController();
  var firstNameCont = TextEditingController();
  var lastNameCont = TextEditingController();
  var pinCodeCont = TextEditingController();
  var cityCont = TextEditingController();
  var stateCont = TextEditingController();
  var emailCont = TextEditingController();
  var addressCont = TextEditingController();
  var phoneNumberCont = TextEditingController();
  var countryCont = TextEditingController();
  var parishCont = TextEditingController();
  var accountNameCont = TextEditingController();
  var accountNumberCont = TextEditingController();
  var bankNameCont = TextEditingController();
  var otherCont = TextEditingController();

  bool singleTap = true;
  int val = 1;



  Future<CountryParishModel?>? countrydetail;
  List<CountryParishModel>? countryModel;
  CountryParishModel? countryNewModel;
  CountryParishModelDataCountries? selectedValue;
  var selectedStateValue;
  var statename = "Christ Church";
  var countryname = "Barbados";
  bool _visible_drop = false;
  bool _visible_text = false;
  int parish_size = 0;
  BecameSellerModel? becameSellerModel;
  ProfileModel? profileModel;

  @override
  void initState() {
    super.initState();
    countrydetail = fetchcountry();
    fetchDetails();

  }

  Future<ProfileModel?> fetchDetails() async {
//    Dialogs.showLoadingDialog(context, _keyLoader);
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      print('Token : ${token}');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Response response = await get(
      //   'https://encros.rcstaging.co.in/wp-json/wooapp/v3/profile',
      //   headers: headers
      // );

      var response =await http.get(Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/profile"),
          headers: headers);

      final jsonResponse = json.decode(response.body);
      print('BecameSellerScreen profile Response status2: ${response.statusCode}');
      print('BecameSellerScreen profile Response body2: ${response.body}');
      EasyLoading.dismiss();

      profileModel = new ProfileModel.fromJson(jsonResponse);
      // if (new_car == 0) {
      firstNameCont.text = profileModel!.data!.firstName!;
      lastNameCont.text = profileModel!.data!.lastName!;
      emailCont.text = profileModel!.data!.userEmail!;
      phoneNumberCont.text= profileModel!.data!.phone!;



      return profileModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<BecameSellerModel?> BecameSeller() async {
    EasyLoading.show(status: 'Please wait...');
    try {

      // String email = emailCont.text;
      // String firstname = firstNameCont.text;
      // String lastname = lastNameCont.text;
      // String phone = profileModel!.data!.phone.toString();
      // String country_code = profileModel!.data!.phoneCode.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      if (!_visible_drop) {
        statename = parishCont.text;
      }

      // final msg = jsonEncode({
      //   "shop_name": "Happy",
      //   "billing_first_name":"keval2",
      //   "billing_last_name":"Panchal2",
      //   "billing_email": "keval@gmail.com",
      //   "billing_phone": "7878392120",
      //   "billing_address_1": "Hill Colony",
      //   "billing_city":"Surat",
      //   "billing_state":"Gujarat",
      //   "billing_postcode":"393430",
      //   "billing_country":"India",
      //   "shipping_first_name":"keval2",
      //   "shipping_last_name":"Panchal2",
      //   "shipping_email": "keval@gmail.com",
      //   "shipping_phone": "7878392120",
      //   "shipping_address_1": "Hill Colony",
      //   "shipping_city":"Surat",
      //   "shipping_state":"Gujarat",
      //   "shipping_postcode":"393430",
      //   "shipping_country":"India",
      // });

      final msg = jsonEncode({
        // "shop_name": ShopNameCont.text.toString(),
        "billing_first_name":firstNameCont.text.toString(),
        "billing_last_name":lastNameCont.text.toString(),
        "billing_email": emailCont.text.toString(),
        "billing_phone": phoneNumberCont.text.toString(),
        "billing_address_1": addressCont.text.toString(),
        "billing_city":cityCont.text.toString(),
        "billing_state":statename,
        "billing_postcode":pinCodeCont.text.toString(),
        "billing_country":countryname,
        "shipping_first_name":firstNameCont.text.toString(),
        "shipping_last_name":lastNameCont.text.toString(),
        "shipping_email": emailCont.text.toString(),
        "shipping_phone": phoneNumberCont.text.toString(),
        "shipping_address_1": addressCont.text.toString(),
        "shipping_city":cityCont.text.toString(),
        "shipping_state":statename,
        "shipping_postcode":pinCodeCont.text.toString(),
        "shipping_country":countryname,
        "name_of_account":accountNameCont.text.toString(),
        "account_number":accountNumberCont.text.toString(),
        "name_of_bank":bankNameCont.text.toString(),
        "other_details":otherCont.text.toString()
      });


      // String body = json.encode(data2);

      http.Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/become_a_seller'),
          headers: headers,
          body: msg);

//
      final jsonResponse = json.decode(response.body);
      EasyLoading.dismiss();

      print('BecameSellerScreen become_a_seller Response status2: ${response.statusCode}');
      print('BecameSellerScreen become_a_seller Response body2: ${response.body}');

      becameSellerModel = new BecameSellerModel.fromJson(jsonResponse);


if(becameSellerModel!.success!) {
  toast(becameSellerModel!.msg);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          DashboardScreen(selectedTab: 0),
    ),
  );
}else{
  toast(becameSellerModel!.msg);
}

      // prefs.setString('login_name', firstname);

      return becameSellerModel;
    } catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }

  Future<CountryParishModel?> fetchcountry() async {
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};

      // Response response =
      // await get('http://54.245.123.190//gotspotz//wp-json/v3/woocountries');

      var response = await http
          .get(Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/countries'));

      final jsonResponse = json.decode(response.body);

      countryNewModel = new CountryParishModel.fromJson(jsonResponse);
      for (var i = 0; i < countryNewModel!.data!.countries!.length; i++) {
        if (countryNewModel!.data!.countries![i]!.country == countryname) {
          selectedValue = countryNewModel!.data!.countries![i];

          if (countryNewModel!.data!.countries![i]!.parishes!.length > 0) {
            _visible_drop = true;
            _visible_text = false;
          } else {
            _visible_drop = false;
            _visible_text = true;
          }

          for (var j = 0;
          j < countryNewModel!.data!.countries![i]!.parishes!.length;
          j++) {
            if (countryNewModel!.data!.countries![i]!.parishes![j]!.name == statename) {
              selectedStateValue = countryNewModel!.data!.countries![i]!.parishes![j];
            }
          }
        }
      }


      return countryNewModel;
//      return jsonResponse.map((job) => new CountryModel.fromJson(job)).toList();
    } catch (e) {
      print('Caught error $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final node = FocusScope.of(context);

    countryList() {
      return Padding(
          padding: const EdgeInsets.fromLTRB(0.0,12,0,0),
          child: Container(
            decoration: boxDecoration(
                bgColor: sh_btn_color, radius: 22, showShadow: true),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: DropdownButton<CountryParishModelDataCountries?>(
                    underline: SizedBox(),
                    isExpanded: true,
                    items: countryNewModel!.data!.countries!.map((item) {
                      return new DropdownMenuItem(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12.0,0,0,0),
                          child: Text(
                            item!.country!,
                            style: TextStyle(
                                color: sh_textColorPrimary,
                                fontFamily: fontRegular,
                                fontSize: textSizeMedium),
                          ),
                        ),
                        value: item,
                      );
                    }).toList(),
                    hint: Text('Select Country'),
                    value: selectedValue,
                    onChanged: (CountryParishModelDataCountries? newVal) {
                      setState(() {
                        selectedValue = newVal;
                        countryname = newVal!.country!;

                        parish_size = newVal.parishes!.length;
                        if (newVal.parishes!.length > 0) {
                          selectedStateValue = newVal.parishes![0];
                          _visible_drop = true;
                          _visible_text = false;
                        } else {
                          _visible_drop = false;
                          _visible_text = true;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          )
      )
        ;
    }

    stateList() {
      if (_visible_drop) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(0.0,12,0,0),
            child: Container(
              decoration: boxDecoration(
                  bgColor: sh_btn_color, radius: 22, showShadow: true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: DropdownButton<CountryParishModelDataCountriesParishes>(
                      underline: SizedBox(),
                      isExpanded: true,
                      items: selectedValue!.parishes!.map((item) {
                        return new DropdownMenuItem(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12.0,0,0,0),
                            child: Text(
                              item!.name!,
                              style: TextStyle(
                                  color: sh_textColorPrimary,
                                  fontFamily: fontRegular,
                                  fontSize: textSizeMedium),
                            ),
                          ),
                          value: item,
                        );
                      }).toList(),
                      hint: Text('Select Parish'),
                      value: selectedStateValue,
                      onChanged: (CountryParishModelDataCountriesParishes? newVal) {
                        setState(() {
                          selectedStateValue = newVal;
                          statename = newVal!.name!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
        )
          ;
      } else {
        return TextFormField(
          maxLines: 1,
          controller: parishCont,
          keyboardType: TextInputType.text,
          onEditingComplete: () => node.nextFocus(),
          style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
          cursorColor: sh_app_txt_color,

          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
            hintText: sh_hint_parish,
            hintStyle: TextStyle(color: sh_app_txt_color),
            filled: true,
            fillColor: sh_white,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: sh_view_color, width: 1.0)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: sh_view_color, width: 1.0)),
          ),
        )
          ;
      }
    }


    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Add Details",
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
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26,spacing_standard_new,26,spacing_standard_new),
                child: Container(
                  color: sh_white,
                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // text(" Shop Name", textColor: sh_app_txt_color,fontFamily: "Bold"),
                      // editTextStyle("Shop Name", ShopNameCont, node,
                      //     "Please Enter Shop Name", sh_white, sh_view_color, 1),
                      //
                      // SizedBox(
                      //   height: spacing_middle,
                      // ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    text(" First Name", textColor: sh_app_txt_color,fontFamily: "Bold"),
                                    text("*", textColor: sh_red, fontFamily: "Bold"),
                                  ],
                                ),

                                editTextStyle("First Name", firstNameCont, node,
                                    "Please Enter First Name", sh_white, sh_view_color, 1),
                              ],
                            ),
                          ),
                          SizedBox(width: 12,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    text(" Last Name", textColor: sh_app_txt_color,fontFamily: "Bold"),
                                    text("*", textColor: sh_red, fontFamily: "Bold"),
                                  ],
                                ),
                                editTextStyle("Last Name", lastNameCont, node,
                                    "Please Enter Last Name", sh_white, sh_view_color, 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Row(
                        children: [
                          text(" Email", textColor: sh_app_txt_color,fontFamily: "Bold"),
                          text("*", textColor: sh_red, fontFamily: "Bold"),
                        ],
                      ),

                      editTextStyle("Enter Email", emailCont, node,
                          "Please Enter Email", sh_white, sh_view_color, 1),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Row(
                        children: [
                          text(" Phone", textColor: sh_app_txt_color,fontFamily: "Bold"),
                          text("*", textColor: sh_red, fontFamily: "Bold"),
                        ],
                      ),
                      editTextStyle2("Enter Phone", phoneNumberCont, node,
                          "Please Enter Phone", sh_white, sh_view_color, 1),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Row(
                        children: [
                          text(" Address", textColor: sh_app_txt_color,fontFamily: "Bold"),
                          text("*", textColor: sh_red, fontFamily: "Bold"),
                        ],
                      ),
                      editTextStyle("Enter Address", addressCont, node,
                          "Please Enter Address", sh_white, sh_view_color, 1),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Row(
                        children: [
                          text(" City", textColor: sh_app_txt_color,fontFamily: "Bold"),
                          text("*", textColor: sh_red, fontFamily: "Bold"),
                        ],
                      ),
                      editTextStyle("Enter City", cityCont, node,
                          "Please Enter City", sh_white, sh_view_color, 1),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Row(
                        children: [
                          text(" Zipcode", textColor: sh_app_txt_color,fontFamily: "Bold"),
                          text("*", textColor: sh_red, fontFamily: "Bold"),
                        ],
                      ),
                      editTextStyle("Enter Zipcode", pinCodeCont, node,
                          "Please Enter Zipcode", sh_white, sh_view_color, 1),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      text(" Select Country & State", textColor: sh_app_txt_color,fontFamily: "Bold"),
                      FutureBuilder<CountryParishModel?>(
                        future: countrydetail,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: <Widget>[
                                countryList(),
                                SizedBox(
                                  height: 12,
                                ),
                                stateList()
                              ],
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      ),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10,left: 14,right: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: sh_colorPrimary2),
                          color: sh_white,
                          borderRadius: BorderRadius.circular(10.0),
                          // boxShadow: true
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              text("Banking Information",fontSize: 18.0, textColor: sh_app_txt_color,fontFamily: "Bold"),
                            ],),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                text(" Name of account",fontSize: 15.0, textColor: sh_app_txt_color,fontFamily: "Bold"),
                                text("*",fontSize: 15.0, textColor: sh_red, fontFamily: "Bold"),
                              ],
                            ),
                            editTextStyle5("Name of account", accountNameCont, node,
                                "Please Enter Name of account", sh_white, sh_view_color, 1),
                            SizedBox(
                              height: spacing_middle,
                            ),
                            Row(
                              children: [
                                text(" Account number",fontSize: 15.0, textColor: sh_app_txt_color,fontFamily: "Bold"),
                                text("*",fontSize: 15.0, textColor: sh_red, fontFamily: "Bold"),
                              ],
                            ),
                            editTextStyle5("Account number", accountNumberCont, node,
                                "Please Enter Account number", sh_white, sh_view_color, 1),
                            SizedBox(
                              height: spacing_middle,
                            ),
                            Row(
                              children: [
                                text(" Name of Bank",fontSize: 15.0, textColor: sh_app_txt_color,fontFamily: "Bold"),
                                text("*",fontSize: 15.0, textColor: sh_red, fontFamily: "Bold"),
                              ],
                            ),
                            editTextStyle5("Name of Bank", bankNameCont, node,
                                "Please Enter Name of Bank", sh_white, sh_view_color, 1),
                            SizedBox(
                              height: spacing_middle,
                            ),
                            text(" Other Details",fontSize: 15.0, textColor: sh_app_txt_color,fontFamily: "Bold"),
                            editTextStyle3("Other Details", otherCont, node,
                                "Please Enter Other Details", sh_white, sh_view_color, 4),
                          ],),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 2,
                            groupValue: val,
                            onChanged: (int? value) {
                              setState(() {
                                val = value!;
                              });
                            },
                            activeColor: sh_colorPrimary2,
                          ),
                          Text('I agree to the ',style: TextStyle(color: sh_black,fontSize: 13),),
                          Text('Terms & Conditions',style: TextStyle(color: sh_colorPrimary2,fontSize: 13, decoration: TextDecoration.underline,),),
                        ],
                      ),

SizedBox(height: 16,),
                      InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            //   // TODO submit
                            FocusScope.of(context).requestFocus(FocusNode());
                            BecameSeller();

                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(
                              top: spacing_middle, bottom: spacing_middle),
                          decoration: boxDecoration(
                              bgColor: sh_app_background, radius: 10, showShadow: true),
                          child: text("SUBMIT",
                              textColor: sh_colorPrimary2,
                              isCentered: true,
                              fontFamily: 'Bold'),
                        ),
                      ),
                    ],
                  ),
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
                      child: Text("Become a Seller",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setInt("shiping_index", -2);
                    prefs.setInt("payment_index", -2);
                    launchScreen(context, CartScreen.tag);
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(4, 0, 20, 0),
                    child: Image.asset(
                      sh_new_cart,
                      height: 50,
                      width: 50,
                      color: sh_white,
                    ),
                  ),

                ),
              ],
            ),
          ),
        ),

      ]);
    }

    return Sizer(
      builder: (context, orientation, deviceType) {
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
      },
    );

  }
}
Padding editTextStyle(var hintText, var cn, final node, String alert,
    Color sh_white, Color sh_view_color, int min_lne) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      maxLines: min_lne,
      controller: cn,
      onEditingComplete: () => node.nextFocus(),
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      validator: (text) {
        if (text == null || text.isEmpty) {
          return alert;
        }
        return null;
      },
      cursorColor: sh_app_txt_color,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        hintText: hintText,
        hintStyle: TextStyle(color: sh_app_txt_color),
        filled: true,
        fillColor: sh_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
      ),
    ),
  );
}

Padding editTextStyle3(var hintText, var cn, final node, String alert,
    Color sh_white, Color sh_view_color, int min_lne) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      maxLines: min_lne,
      controller: cn,
      onEditingComplete: () => node.nextFocus(),
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      cursorColor: sh_app_txt_color,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(18, 10, 18, 10),
        hintText: hintText,
        hintStyle: TextStyle(color: sh_app_txt_color),
        filled: true,
        fillColor: sh_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
      ),
    ),
  );
}

Padding editTextStyle2(var hintText, var cn, final node, String alert,
    Color sh_white, Color sh_view_color, int min_lne) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      maxLines: min_lne,
      controller: cn,
        keyboardType: TextInputType.number,
      onEditingComplete: () => node.nextFocus(),
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      cursorColor: sh_app_txt_color,
      validator: (text) {
        if (text == null || text.isEmpty) {
          return alert;
        }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        hintText: hintText,
        hintStyle: TextStyle(color: sh_app_txt_color),
        filled: true,
        fillColor: sh_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
      ),
    ),
  );
}

Padding editTextStyle5(var hintText, var cn, final node, String alert,
    Color sh_white, Color sh_view_color, int min_lne) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      maxLines: min_lne,
      controller: cn,
      onEditingComplete: () => node.nextFocus(),
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      validator: (text) {
        if (text == null || text.isEmpty) {
          return alert;
        }
        return null;
      },
      cursorColor: sh_app_txt_color,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(18, 10, 18, 10),
        hintText: hintText,
        hintStyle: TextStyle(color: sh_app_txt_color,fontSize: textSizeMedium),
        filled: true,
        fillColor: sh_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
      ),
    ),
  );
}
