import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thrift/model/CountryParishModel.dart';
import 'package:thrift/provider/home_product_provider.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class SelectCountryScreen extends StatefulWidget {
  const SelectCountryScreen({Key? key}) : super(key: key);

  @override
  State<SelectCountryScreen> createState() => _SelectCountryScreenState();
}

class _SelectCountryScreenState extends State<SelectCountryScreen> {
  String? user_selected_country = '';
  List<CountryParishModel>? countryModel;
  CountryParishModel? countryNewModel;
  CountryParishModelDataCountries? selectedValue;
  Future<CountryParishModel?>? countrydetail;
  Trace customTrace = FirebasePerformance.instance.newTrace('fetchCountry');


  @override
  void initState() {
    super.initState();
    countrydetail = fetchcountry();
    // fetchaddMain=fetchadd();
  }

  Future<CountryParishModel?> fetchcountry() async {
    await customTrace.start();

    EasyLoading.show(status: 'Please wait...');
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};

      // Response response =
      // await get('http://54.245.123.190//gotspotz//wp-json/v3/woocountries');

      var response = await http
          .get(Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/countries'));

      print(
          'SettingFragment countries Response status2: ${response.statusCode}');
      print('SettingFragment countries Response body2: ${response.body}');
      EasyLoading.dismiss();
      final jsonResponse = json.decode(response.body);
      countryNewModel = new CountryParishModel.fromJson(jsonResponse);
      await customTrace.stop();
      return countryNewModel;
//      return jsonResponse.map((job) => new CountryModel.fromJson(job)).toList();
    } catch (e) {
      await customTrace.stop();
      EasyLoading.dismiss();
      print('Caught error $e');
    }
  }

  void navigationPage() async {
    EasyLoading.dismiss();
    // finish(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(selectedTab: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final node = FocusScope.of(context);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: StreamProvider<NetworkStatus>(
        initialData: NetworkStatus.Online,
        create: (context) =>
            NetworkStatusService().networkStatusController.stream,
        child: NetworkAwareWidget(
          onlineChild: Container(
            height: height,
            width: width,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: height * .55,
                    child: Stack(fit: StackFit.expand, children: [
                      // Image.asset(sh_upper,fit: BoxFit.cover,height: height,),
                      Container(
                          height: height,
                          constraints: BoxConstraints.expand(
                              height: MediaQuery.of(context).size.height),
                          width: double.infinity,
                          child: Image.asset(
                            sh_upper,
                            fit: BoxFit.fill,
                            height: height,
                            width: width,
                          )
                          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
                          ),
                      // Image.asset(sh_splsh2,fit: BoxFit.none,height: height,),
                    ]),
                  ),
                  Container(
                    height: height * .5,
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 30),
                          child: Image.asset(
                            sh_app_logo,
                            width: width * .5,
                            height: width * .6,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: height * .5,
                          ),
                          Container(
                            width: width * .7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "Select Country",
                                  style: TextStyle(
                                      color: sh_colorAccent2,
                                      fontSize: 24,
                                      fontFamily: fontBold),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                FutureBuilder<CountryParishModel?>(
                                  future: countrydetail,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              18.0, 12, 12, 0),
                                          child: Container(
                                            decoration: boxDecoration(
                                                bgColor: sh_btn_color,
                                                radius: 10,
                                                showShadow: true),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16.0, 0, 16, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: DropdownButton<
                                                        CountryParishModelDataCountries?>(
                                                      underline: Container(),
                                                      // decoration: InputDecoration(
                                                      //     labelText: 'Change Country'
                                                      // ),
                                                      isExpanded: true,
                                                      items: countryNewModel!
                                                          .data!.countries!
                                                          .map((item) {
                                                        return new DropdownMenuItem(
                                                          child: Text(
                                                            item!.country!,
                                                            style: TextStyle(
                                                                color:
                                                                    sh_textColorPrimary,
                                                                fontFamily:
                                                                    fontRegular,
                                                                fontSize:
                                                                    textSizeMedium),
                                                          ),
                                                          value: item,
                                                        );
                                                      }).toList(),
                                                      hint: Text(
                                                          'Select Country'),
                                                      value: selectedValue,
                                                      onChanged:
                                                          (CountryParishModelDataCountries?
                                                              newVal) async {
                                                        // SharedPreferences prefs = await SharedPreferences.getInstance();
                                                        // prefs.setString('user_selected_country', newVal!.country!);
                                                        user_selected_country =
                                                            newVal!.country!;
                                                        setState(() {
                                                          selectedValue =
                                                              newVal;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ));
                                    } else if (snapshot.hasError) {
                                      return Text("${snapshot.error}");
                                    }
                                    // By default, show a loading spinner.
                                    return Container(
                                        child:
                                            Center(child: Text("Please Wait")));
                                  },
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                InkWell(
                                  onTap: () async {

                                    if (user_selected_country!.length > 2) {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setString('user_selected_country', user_selected_country!);
                                      prefs.setString('profile_name', 'Guest');
                                      final postMdl = Provider.of<HomeProductListProvider>(context, listen: false);
                                      EasyLoading.show(status: "Please wait..");
                                      await postMdl.getHomeProduct('Newest to Oldest',true);
                                      navigationPage();
                                    } else {
                                      toast("Please Select Country");
                                    }
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .65,
                                    padding:
                                        EdgeInsets.only(top: 6, bottom: 10),
                                    decoration: boxDecoration(
                                        bgColor: sh_btn_color,
                                        radius: 10,
                                        showShadow: true),
                                    child: text("Continue",
                                        fontSize: 24.0,
                                        textColor: sh_app_txt_color,
                                        isCentered: true,
                                        fontFamily: 'Bold'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 40, 20, 20),
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_left,
                          color: Colors.white,
                          size: 40,
                        )),
                  ),
                ],
              ),
            ),
          ),
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
