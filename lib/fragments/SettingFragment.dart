import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/CheckUserModel.dart';
import 'package:thrift/model/CountryParishModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/CustomerSupportScreen.dart';
import 'package:thrift/screens/FAQScreen.dart';
import 'package:thrift/screens/ProfileScreen.dart';
import 'package:thrift/screens/SellerEditProfileScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' ;
import 'package:badges/badges.dart';

class SettingFragment extends StatefulWidget {
  const SettingFragment({Key? key}) : super(key: key);

  @override
  _SettingFragmentState createState() => _SettingFragmentState();
}

class _SettingFragmentState extends State<SettingFragment> {
  bool _isVisible = true;
  bool _isVisible_success = false;
  String? user_selected_country;
  List<CountryParishModel>? countryModel;
  CountryParishModel? countryNewModel;
  CountryParishModelDataCountries? selectedValue;
  Future<CountryParishModel?>? countrydetail;
  CheckUserModel? checkUserModel;
  Future<String?>? fetchaddMain;

  @override
  void initState() {
    super.initState();
    countrydetail = fetchcountry();
    // fetchaddMain=fetchadd();
  }

  Future<String?> fetchadd() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      user_selected_country = prefs.getString('user_selected_country');
      return '';
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<String?> EmptyCart(CountryParishModelDataCountries newVal) async {
    EasyLoading.show(status: 'Please wait...');
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
            Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/empty_cart'),
            headers: headers);

        print('Response status2: ${response.statusCode}');
        print('Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        print('not json $jsonResponse');
      }

      prefs.setInt("cart_count", 0);
      EasyLoading.dismiss();
      setState(() {
        selectedValue = newVal;

      });
      // first2=false;

//      print(cat_model.data);
      return "cat_model";
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
      // return cat_model;
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
      // for (var i = 0; i < countryNewModel!.data!.countries!.length; i++) {
        // if (countryNewModel!.data!.countries![i]!.country == countryname) {
        //   selectedValue = countryNewModel!.data!.countries![0];
        // }
      // }
      print('Caught error ');

      return countryNewModel;
//      return jsonResponse.map((job) => new CountryModel.fromJson(job)).toList();
    } catch (e) {
      print('Caught error $e');
    }
  }

  void _openCustomDialog3(CountryParishModelDataCountries newVal) {
    showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Center(child: Text('Are you sure you want to change the country?',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16,),
                    InkWell(
                      onTap: () async {
                        // BecameSeller();
                        Navigator.of(context, rootNavigator: true).pop();
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString('user_selected_country', newVal.country!);
                        toast(newVal.country);
                        EmptyCart(newVal);

                        // setState(() {
                        //   selectedValue = newVal;
                        //
                        // });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*.7,
                        padding: EdgeInsets.only(
                            top: 6, bottom: 10),
                        decoration: boxDecoration(
                            bgColor: sh_colorPrimary2, radius: 10, showShadow: true),
                        child: text("Confirm",
                            fontSize: 16.0,
                            textColor: sh_white,
                            isCentered: true,
                            fontFamily: 'Bold'),
                      ),
                    ),
                    SizedBox(height: 10,),
                    InkWell(
                      onTap: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*.7,
                        padding: EdgeInsets.only(
                            top: 6, bottom: 10),
                        decoration: boxDecoration(
                            bgColor: sh_btn_color, radius: 10, showShadow: true),
                        child: text("Cancel",
                            fontSize: 16.0,
                            textColor: sh_colorPrimary2,
                            isCentered: true,
                            fontFamily: 'Bold'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  void _openCustomDialog() {
    showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Center(child: Text('Are you sure you want to Delete your account?',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16,),
                    InkWell(
                      onTap: () async {
                        // BecameSeller();
                        Navigator.of(context, rootNavigator: true).pop();
                        _openCustomDialog2();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*.7,
                        padding: EdgeInsets.only(
                            top: 6, bottom: 10),
                        decoration: boxDecoration(
                            bgColor: sh_colorPrimary2, radius: 10, showShadow: true),
                        child: text("Confirm",
                            fontSize: 16.0,
                            textColor: sh_white,
                            isCentered: true,
                            fontFamily: 'Bold'),
                      ),
                    ),
                    SizedBox(height: 10,),
                    InkWell(
                      onTap: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*.7,
                        padding: EdgeInsets.only(
                            top: 6, bottom: 10),
                        decoration: boxDecoration(
                            bgColor: sh_btn_color, radius: 10, showShadow: true),
                        child: text("Cancel",
                            fontSize: 16.0,
                            textColor: sh_colorPrimary2,
                            isCentered: true,
                            fontFamily: 'Bold'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
      return Container();
        });
  }

  void _openCustomDialog2() {
    showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Center(child: Text('Are you sure you want to Delete your account?',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8,),
                    InkWell(
                      onTap: () async {
                        // BecameSeller();
                        Navigator.of(context, rootNavigator: true).pop();
                        setState(() {
                          _isVisible = false;
                          _isVisible_success = true;
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*.7,
                        padding: EdgeInsets.only(
                            top: 6, bottom: 10),
                        decoration: boxDecoration(
                            bgColor: sh_colorPrimary2, radius: 10, showShadow: true),
                        child: text("Confirm",
                            fontSize: 16.0,
                            textColor: sh_white,
                            isCentered: true,
                            fontFamily: 'Bold'),
                      ),
                    ),
                    SizedBox(height: 16,),
                    Center(child: Text('Why are you Leaving?',style: TextStyle(color: sh_colorPrimary2,fontSize: 15,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                    SizedBox(height: 16,),
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: TextFormField(
                        maxLines: 5,
                        style: TextStyle(
                            color: sh_colorPrimary2,
                            fontSize: textSizeMedium,
                            fontFamily: "Bold"),
                        decoration: InputDecoration(
                          filled: true,
hintMaxLines: 5,
                          fillColor: sh_text_back,
                          contentPadding:
                          EdgeInsets.fromLTRB(16, 16, 16, 16),
                          hintText: "Type Feedback",
                          hintStyle:
                          TextStyle(color: sh_colorPrimary2),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: sh_transparent, width: 0.7),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: sh_transparent, width: 0.7),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16,),

                  ],
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  Future<CheckUserModel?> fetchUserStatus() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(Uri.parse(
        "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/check_seller_status?user_id=$UserId",)
          ,headers: headers);

      final jsonResponse = json.decode(response.body);
      checkUserModel = new CheckUserModel.fromJson(jsonResponse);
      prefs.setString('is_store_owner', checkUserModel!.is_store_owner.toString());
      EasyLoading.dismiss();
      if(checkUserModel!.is_store_owner==0){
        launchScreen(context, ProfileScreen.tag);
      } else if (checkUserModel!.is_store_owner==1) {
        launchScreen(context, SellerEditProfileScreen.tag);
      } else if (checkUserModel!.is_store_owner==2) {
        launchScreen(context, ProfileScreen.tag);
      }

      print('sucess');
      print('not json $jsonResponse');

      return checkUserModel;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
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
    final node = FocusScope.of(context);

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
          "Settings",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
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

        // Background with gradient
        Container(
            height: 120,
            width: width,
            child: Image.asset(sh_upper2, fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Visibility(
          visible: _isVisible,
          child: Container(
            height: height,
            width: width,
            color: sh_white,
            margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
            child: Container(
              height: height,
              width: width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: width,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InkWell(
                            onTap: () async{
                              fetchUserStatus();
                              // SharedPreferences prefs = await SharedPreferences.getInstance();
                              // if (prefs.getString("is_store_owner") == '0') {
                              //   launchScreen(context, ProfileScreen.tag);
                              // } else if (prefs.getString("is_store_owner") == '1') {
                              //   launchScreen(context, SellerEditProfileScreen.tag);
                              //
                              // } else if (prefs.getString("is_store_owner") == '2') {
                              //   launchScreen(context, ProfileScreen.tag);
                              //
                              // }

                            },
                            child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(18.0,12,12,12),
                                  child: Text("My Account",style: TextStyle(color: sh_colorPrimary2,fontSize: 20,fontFamily: fontSemibold),),
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              launchScreen(context, FAQScreen.tag);
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18.0,12,12,12),
                              child: Text("FAQ's",style: TextStyle(color: sh_colorPrimary2,fontSize: 20,fontFamily: fontSemibold),),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              launchScreen(context, CustomerSupportScreen.tag);
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18.0,12,12,12),
                              child: Text("Customer Support",style: TextStyle(color: sh_colorPrimary2,fontSize: 20,fontFamily: fontSemibold),),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _openCustomDialog();
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18.0,12,12,12),
                              child: Text("Delete my Account",style: TextStyle(color: sh_colorPrimary2,fontSize: 20,fontFamily: fontSemibold),),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // _openCustomDialog();
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18.0,12,12,0),
                              child: Text("Current Country: ",style: TextStyle(color: sh_textColorPrimary,fontSize: 16,fontFamily: fontSemibold),),
                            ),
                          ),
                          FutureBuilder<String?>(
                            future: fetchadd(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(18.0,6,12,6),
                                  child: Text(user_selected_country!,style: TextStyle(color: sh_colorPrimary2,fontSize: 20,fontFamily: fontSemibold),),
                                );
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }
                              // By default, show a loading spinner.
                              return CircularProgressIndicator();
                            },
                          ),
                          SizedBox(height: 12,),
                          FutureBuilder<CountryParishModel?>(
                            future: countrydetail,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(18.0,12,12,0),
                                  child: Container(
                                    decoration: boxDecoration(
                                        bgColor: sh_btn_color, radius: 22, showShadow: true),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16.0,0,16,0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            child: DropdownButton<CountryParishModelDataCountries?>(
                                              underline: Container(),
                                              // decoration: InputDecoration(
                                              //     labelText: 'Change Country'
                                              // ),
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
                                              onChanged: (CountryParishModelDataCountries? newVal) async{
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                // prefs.setString('user_selected_country', newVal.country!);
                                                if(prefs.getString('user_selected_country')==newVal!.country){
                                                  setState(() {
                                                    selectedValue = newVal;

                                                  });
                                                }else {
                                                  _openCustomDialog3(newVal);
                                                }
                                                // setState(() {
                                                //   selectedValue = newVal;
                                                //
                                                // });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                )
                                  ;
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }
                              // By default, show a loading spinner.
                              return Container(
                                  child: Center(child: Text("Please Wait"))
                                  );
                            },
                          ),


                        ],
                      ),

                    ),

                  ],
                ),
              ),
            ),
          ),
        ),

        Visibility(
            visible: _isVisible_success,
            child: Container(
              height: height,
              width: width,
              margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              color: sh_white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: sh_colorPrimary2,
                        size: 30,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Account deleted!",
                        style: TextStyle(
                            color: sh_colorPrimary2,
                            fontSize: 24,
                            fontFamily: "Bold"),
                      )
                    ],
                  ),

                ],
              ),
            )),
        // Positioned to take only AppBar size
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child:
          Container(
            padding: const EdgeInsets.fromLTRB(30,18,10,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(1.0,0,6,0),
                    //   child: IconButton(onPressed: () {
                    //     // Navigator.pop(context);
                    //   }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 32,)),
                    // ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,6,6,6.0),
                      child: Text("Settings",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
      body: SafeArea(child: setUserForm()),
    );
  }
}
