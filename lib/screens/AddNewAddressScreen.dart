import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/AddressListModel.dart';
import 'package:thrift/model/AddressSuccessModel.dart';
import 'package:thrift/model/CountryParishModel.dart';
import 'package:thrift/model/CouponErrorModel.dart';
import 'package:thrift/model/CouponModel.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:thrift/screens/AddressListScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/DefaultAddressScreen.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';


class AddNewAddressScreen extends StatefulWidget {
  static String tag='/AddNewAddressScreen';
  dynamic addressModel = AddressListModel();

  AddNewAddressScreen({this.addressModel});

  @override
  _AddNewAddressScreenState createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  var primaryColor;
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

  // LocationData _currentPosition;
  // String _address,_dateTime;
  // Location location = Location();

  AddressSuccessModel? addressSuccessModel;
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
  CouponModel? couponModel;
  CouponErrorModel? couponErrorModel;
  ProfileModel? profileModel;
  // Future<String?>? fetchtotalMain;

  @override
  void initState() {
    super.initState();
    init();
    // fetchtotalMain=fetchtotal();

  }

  init() async {
    if (widget.addressModel != null) {
      pinCodeCont.text = widget.addressModel.postcode;
      addressCont.text = widget.addressModel.address;
      cityCont.text = widget.addressModel.city;
      stateCont.text = widget.addressModel.state;
      countryCont.text = widget.addressModel.country;
      firstNameCont.text = widget.addressModel.firstName;
      lastNameCont.text = widget.addressModel.lastName;

      parishCont.text = widget.addressModel.state;

      countryname = widget.addressModel.country;
      statename = widget.addressModel.state;
      countrydetail = fetchcountry();
    } else {
      fetchDetails();
      countrydetail = fetchcountry();
    }
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
      print('not json $jsonResponse');
      EasyLoading.dismiss();

      profileModel = new ProfileModel.fromJson(jsonResponse);
      // if (new_car == 0) {
      firstNameCont.text = profileModel!.data!.firstName!;
      lastNameCont.text = profileModel!.data!.lastName!;
      emailCont.text = profileModel!.data!.userEmail!;

      print('sucess');

      return profileModel;
    } catch (e) {
      print('caught error $e');
    }
  }


  Future<AddressSuccessModel?> SaveAddress() async {
    String email = emailCont.text;
    String first = firstNameCont.text;
    String last = lastNameCont.text;
    String phone = phoneNumberCont.text;
    String city = cityCont.text;
    String pincode = pinCodeCont.text;
    String address1 = addressCont.text;
    if (!_visible_drop) {
      statename = parishCont.text;
    }

    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');

      print(token);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        "first_name": first,
        "last_name": last,
        "address": address1,
        "city": city,
        "state": statename,
        "postcode": pincode,
        "country": countryname
      });

      print(body);

      // Response response = await post(
      //   'https://encros.rcstaging.co.in/wp-json/wooapp/v3/add_shipping_address',
      //   headers: headers,
      //   body: body,
      // );

      var response = await http.post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/add_shipping_address'),
          body: body,
          headers: headers);

      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      EasyLoading.dismiss();
      addressSuccessModel = new AddressSuccessModel.fromJson(jsonResponse);
      if (addressSuccessModel!.success!) {
        toast("Address Added Successfully");
        if (prefs.getString("from") == 'address') {
          Route route =
          MaterialPageRoute(builder: (context) => AddressListScreen());
          Navigator.pushReplacement(context, route);
        }else if (prefs.getString("from") == 'default2') {
          Route route =
          MaterialPageRoute(builder: (context) => AddressListScreen());
          Navigator.pushReplacement(context, route);
        } else if (prefs.getString("from") == 'default'){
          prefs.setString('address_pos', "0");
          Route route =
          MaterialPageRoute(builder: (context) => CartScreen());
          Navigator.pushReplacement(context, route);
        }
      } else {
        couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
        toast(couponErrorModel!.error);
      }
//      saveAddressModel = new SaveAddressModel.fromJson(jsonResponse);

//      toast(saveAddressModel.msg);

    } catch (e) {
      print('caught error $e');
    }
  }

  Future<AddressSuccessModel?> UpdateAddress() async {
    String email = emailCont.text;
    String first = firstNameCont.text;
    String last = lastNameCont.text;
    String phone = phoneNumberCont.text;
    String city = cityCont.text;
    String pincode = pinCodeCont.text;
    String address1 = addressCont.text;
    String address_key = widget.addressModel.key;

    if (!_visible_drop) {
      statename = parishCont.text;
    }

    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');

      print(token);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'address_key': address_key,
        'first_name': first,
        'last_name': last,
        'address': address1,
        'city': city,
        'state': statename,
        'postcode': pincode,
        'country': countryname,
        // 'email': email,
        // 'phone': phone,
      });

      print(body);

      // Response response = await post(
      //   'https://encros.rcstaging.co.in/wp-json/wooapp/v3/update_shipping_addres',
      //   headers: headers,
      //   body: body,
      // );

      var response = await http.post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/update_shipping_addres'),
          body: body,
          headers: headers);

      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      EasyLoading.dismiss();
      couponModel = new CouponModel.fromJson(jsonResponse);
      if (couponModel!.success!) {
        toast("Address Updated Successfully");
        Route route =
        MaterialPageRoute(builder: (context) => AddressListScreen());
        Navigator.pushReplacement(context, route);
      } else {
        couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
        toast(couponErrorModel!.error);
      }
//      saveAddressModel = new SaveAddressModel.fromJson(jsonResponse);

//      toast(saveAddressModel.msg);

    } catch (e) {
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? user_country = prefs.getString('user_selected_country');

      if (widget.addressModel != null) {
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
              if (countryNewModel!.data!.countries![i]!.parishes![j]!.name ==
                  statename) {
                selectedStateValue =
                countryNewModel!.data!.countries![i]!.parishes![j];
              }
            }
          }
        }
      }else{
        for (var i = 0; i < countryNewModel!.data!.countries!.length; i++) {
          if (countryNewModel!.data!.countries![i]!.country == user_country) {
            selectedValue = countryNewModel!.data!.countries![i];

            if (countryNewModel!.data!.countries![i]!.parishes!.length > 0) {
              _visible_drop = true;
              _visible_text = false;
            } else {
              _visible_drop = false;
              _visible_text = true;
            }


          }
        }
      }
      print('Caught error ');

      return countryNewModel;
//      return jsonResponse.map((job) => new CountryModel.fromJson(job)).toList();
    } catch (e) {
      print('Caught error $e');
    }
  }

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




  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    void onSaveClicked() async {
      if (widget.addressModel != null) {
        UpdateAddress();
      } else {
        SaveAddress();
      }
    }

    firstName() {
      return TextFormField(
        controller: firstNameCont,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        cursorColor: sh_colorPrimary2,
        style: TextStyle(fontFamily: fontRegular, fontSize: textSizeMedium),
        autofocus: false,
        onFieldSubmitted: (term) {
          FocusScope.of(context).nextFocus();
        },
        decoration: formFieldDecoration(sh_hint_first_name, sh_colorPrimary),
      );
    }

    lastName() {
      return TextFormField(
        controller: lastNameCont,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(fontFamily: fontRegular, fontSize: textSizeMedium),
        autofocus: false,
        onFieldSubmitted: (term) {
          FocusScope.of(context).nextFocus();
        },
        decoration: formFieldDecoration(sh_hint_last_name, sh_colorPrimary),
      );
    }

    pinCode () {
      return TextFormField(
        controller: pinCodeCont,
        keyboardType: TextInputType.text,
        maxLength: 6,
        autofocus: false,
        onFieldSubmitted: (term) {
          FocusScope.of(context).nextFocus();
        },
        textInputAction: TextInputAction.next,
        style: TextStyle(fontFamily: fontRegular, fontSize: textSizeMedium),
        decoration: formFieldDecoration(sh_hint_pin_code, sh_colorPrimary),
      );
    }

    city () {
      return TextFormField(
        controller: cityCont,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(fontFamily: fontRegular, fontSize: textSizeMedium),
        onFieldSubmitted: (term) {
          FocusScope.of(context).nextFocus();
        },
        textInputAction: TextInputAction.next,
        autofocus: false,
        decoration: formFieldDecoration(sh_hint_city, sh_colorPrimary),
      );
    }

    address () {
      return TextFormField(
        controller: addressCont,
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        onFieldSubmitted: (term) {
          FocusScope.of(context).nextFocus();
        },
        autofocus: false,
        style: TextStyle(fontFamily: fontRegular, fontSize: textSizeMedium),
        decoration: formFieldDecoration(sh_hint_address, sh_colorPrimary),
      );
    }

    countryList() {
      return DropdownButton<CountryParishModelDataCountries?>(
        underline: SizedBox(),
        isExpanded: true,
        items: countryNewModel!.data!.countries!.map((item) {
          return new DropdownMenuItem(
            child: Text(
              item!.country!,
              style: TextStyle(
                  color: sh_textColorPrimary,
                  fontFamily: fontRegular,
                  fontSize: textSizeMedium),
            ),
            value: item,
          );
        }).toList(),
        hint: Text('Select Country'),
        value: selectedValue,
        onChanged: null,
        // onChanged: (CountryParishModelDataCountries? newVal) {
        //   setState(() {
        //     selectedValue = newVal;
        //     countryname = newVal!.country!;
        //
        //     parish_size = newVal.parishes!.length;
        //     if (newVal.parishes!.length > 0) {
        //       selectedStateValue = newVal.parishes![0];
        //       _visible_drop = true;
        //       _visible_text = false;
        //     } else {
        //       _visible_drop = false;
        //       _visible_text = true;
        //     }
        //   });
        // },
      );
    }

    stateList() {
      if (_visible_drop) {
        return DropdownButton<CountryParishModelDataCountriesParishes>(
          underline: SizedBox(),
          isExpanded: true,
          items: selectedValue!.parishes!.map((item) {
            return new DropdownMenuItem(
              child: Text(
                item!.name!,
                style: TextStyle(
                    color: sh_textColorPrimary,
                    fontFamily: fontRegular,
                    fontSize: textSizeMedium),
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
        );
      } else {
        return TextFormField(
          controller: parishCont,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(fontFamily: fontRegular, fontSize: textSizeMedium),
          onFieldSubmitted: (term) {
            FocusScope.of(context).nextFocus();
          },
          textInputAction: TextInputAction.next,
          autofocus: false,
          decoration: formFieldDecoration(sh_hint_parish,sh_colorPrimary),
        );
      }
    }

    mainList() {
      return FutureBuilder<CountryParishModel?>(
          future: countrydetail,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return CupertinoActivityIndicator(
                animating: true,
              );
            return Column(
              children: <Widget>[
                countryList(),
                SizedBox(
                  height: 12,
                ),
                stateList()
              ],
            );
          });
    }

    saveButton () {
      return MaterialButton(
        height: 50,
        minWidth: double.infinity,
        shape:
        RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(12.0)),
        onPressed: () {
          if (firstNameCont.text.isEmpty) {
            toast("First name required");
          } else if (lastNameCont.text.isEmpty) {
            toast("Last name required");
          }
          // else if (phoneNumberCont.text.isEmpty) {
          //   toast("Phone Number required");
          // } else if (emailCont.text.isEmpty) {
          //   toast("Email required");
          // }
          else if (addressCont.text.isEmpty) {
            toast("Address required");
          } else if (cityCont.text.isEmpty) {
            toast("City name required");
          } else if (pinCodeCont.text.isEmpty) {
            toast("Pincode required");
          } else {
            onSaveClicked();
          }
        },
        color: sh_btn_color,
        child: text(sh_lbl_save_address,
            fontFamily: 'Bold',
            fontSize: textSizeLargeMedium,
            textColor: sh_colorPrimary2),
      );
    }

    body() {
      return Wrap(runSpacing: spacing_standard_new, children: <Widget>[
        // useCurrentLocation,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(child: Container(child: firstName(),)),
            SizedBox(
              width: spacing_standard_new,
            ),
            Expanded(child: Container(child: lastName(),)),
          ],
        ),
        // phoneNumber,
        // email,
        Container(child: address(),),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(child: Container(child: city(),)),
            SizedBox(
              width: spacing_standard_new,
            ),
            Expanded(child: Container(child: pinCode(),)),
          ],
        ),
        mainList(),
        Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
          child: saveButton(),
        ),
      ]);
    }

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

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
            widget.addressModel == null
                ? sh_lbl_add_new_address
                : sh_lbl_edit_address,
          style:
          TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          GestureDetector(
            onTap: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt("shiping_index", -2);
              prefs.setInt("payment_index", -2);
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
            child: Image.asset(sh_upper2, fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Container(
          height: height,
          width: width,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          color: sh_white,
          child: Container(
              width: double.infinity,
              child: SingleChildScrollView(child: body()),
              margin: EdgeInsets.fromLTRB(26,10,26,10)),
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
                      child: Text(   widget.addressModel == null
                          ? sh_lbl_add_address
                          : sh_lbl_edit_address,style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
                    )
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setInt("shiping_index", -2);
                        prefs.setInt("payment_index", -2);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CartScreen()),).then((value) {   setState(() {
                          // refresh state
                        });});
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
                    // SizedBox(width: 16,)
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

InputDecoration formFieldDecoration(String hint_text,Color sh_colorPrimary) {
  return InputDecoration(
    labelText: hint_text,
    labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Bold'),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
    ),
    counterText: "",
    contentPadding: new EdgeInsets.only(bottom: 2.0),
  );
}
