// import 'dart:convert';
//
// import 'package:figma_project/model/AddressListModel.dart';
// import 'package:figma_project/model/CordinatesModel.dart';
// import 'package:figma_project/model/ShAddress.dart';
// import 'package:figma_project/screens/AddNewAddressScreen.dart';
// import 'package:figma_project/screens/BottomUiScreen.dart';
// import 'package:figma_project/screens/DashboardScreen.dart';
// import 'package:figma_project/screens/PaymentsScreen.dart';
// import 'package:figma_project/screens/ShipmentScreen.dart';
// import 'package:figma_project/utils/ShColors.dart';
// import 'package:figma_project/utils/ShConstant.dart';
// import 'package:figma_project/utils/ShExtension.dart';
// import 'package:figma_project/utils/ShStrings.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:package_info/package_info.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:intl/intl.dart';
//
//
// class AddressListScreen extends StatefulWidget {
//   static String tag = '/AddressListScreen';
//
//   @override
//   _AddressListScreenState createState() => _AddressListScreenState();
// }
//
// class _AddressListScreenState extends State<AddressListScreen> {
//   var addressList = List<ShAddressModel>();
//   var selectedAddressIndex = 0;
//   var primaryColor;
//   var mIsLoading = true;
//   var isLoaded = false;
//   AddressListModel _addressModel;
//   Future<AddressListModel> futureAlbum;
//   double posx = 100.0;
//   double posy = 100.0;
//   ScreenshotController screenshotController = ScreenshotController();
//   List<CordinatesModel> itemsModel = [];
//   CordinatesModel itModel;
//   String base64Enc = '';
//
//   void onTapDown(BuildContext context, TapDownDetails details) {
//     print('${details.globalPosition}');
//     final String formattedDateTime =
//     DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now()).toString();
//     final String formattedDate =
//     DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
//
//     final RenderBox box = context.findRenderObject();
//     final Offset localOffset = box.globalToLocal(details.globalPosition);
//     itModel = CordinatesModel(x_cordinate: localOffset.dx, y_cordinate: localOffset.dy,co_datetime: formattedDateTime,co_date: formattedDate);
//     itemsModel.add(itModel);
//   }
//
//   void onTapUp(BuildContext context, TapUpDetails details) {
//     print('${details.globalPosition}');
//     final String formattedDateTime =
//     DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now()).toString();
//     final String formattedDate =
//     DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
//     final RenderBox box = context.findRenderObject();
//     final Offset localOffset = box.globalToLocal(details.globalPosition);
//     itModel = CordinatesModel(x_cordinate: localOffset.dx, y_cordinate: localOffset.dy,co_datetime: formattedDateTime,co_date: formattedDate);
//     itemsModel.add(itModel);
//
//   }
//
//   void _printTap(BuildContext context, String gesture, TapPosition position) {
//     // print('${details.globalPosition}');
//     final String formattedDateTime =
//     DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now()).toString();
//     final String formattedDate =
//     DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
//     final RenderBox box = context.findRenderObject();
//     final Offset localOffset = box.globalToLocal(position.global);
//     itModel = CordinatesModel(x_cordinate: localOffset.dx, y_cordinate: localOffset.dy,co_datetime: formattedDateTime,co_date: formattedDate);
//     itemsModel.add(itModel);
//     setState(() {
//       itemsModel=itemsModel;
//     });
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     // fetchData();
//     fetchAddress();
//     screenshotController
//         .capture(delay: Duration(milliseconds: 2000))
//         .then((capturedImage) async {
//       String base64Encode(capturedImage) => base64.encode(capturedImage);
//       // print(base64Encode(capturedImage));
//       base64Enc = base64Encode(capturedImage);
//       print("my image"+base64Enc);
//       // ShowCapturedWidget(context, capturedImage);
//     }).catchError((onError) {
//       print(onError);
//     });
//   }
//
//   Future<String> SendAppData() async {
//     try {
//       screenshotController
//           .capture(delay: Duration(milliseconds: 50))
//           .then((capturedImage) async {
//         String base64Encode(capturedImage) => base64.encode(capturedImage);
//         // print(base64Encode(capturedImage));
//         base64Enc = base64Encode(capturedImage);
//         print("my image"+base64Enc);
//         // ShowCapturedWidget(context, capturedImage);
//         final PackageInfo info = await PackageInfo.fromPlatform();
//         String appname = info.appName;
//         print(appname);
//         String packagename = info.packageName;
//         print(packagename);
//         final String formattedDateTime =
//         DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now()).toString();
//         final String formattedDate =
//         DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
//         // var route = ModalRoute.of(context);
//         //
//         // if(route!=null){
//         //   print("current route : "+route.settings.name);
//         // }
//
//         String body = json.encode({
//           "activity_name": "AddressListScreen", //e,
//           "app_name": appname,
//           "fragement_name":"",
//           "app_package": packagename,
//           "app_date": formattedDate,
//           "app_datetime": formattedDateTime,
//           "bitmap_image": base64Enc,
//           "cordinates": itemsModel,
//         });
//
//         // String body2 = json.encode({
//         //   "json": body
//         // });
//
//         print(body);
//
//         Response response = await post(
//             'https://panel.propellez.com/propellez/index.php/wp-json/wp/v2/adddata',
//             body: {
//               "json":body
//             });
//
//         print('Response status2: ${response.statusCode}');
//         print('Response body2: ${response.body}');
//         final jsonResponse = json.decode(response.body);
//
//       }).catchError((onError) {
//         print(onError);
//       });
//
//
//
//       return null;
//     } catch (e) {
// //      return orderListModel;
//       print('caught error $e');
//     }
//   }
//
//
//   Future<AddressListModel> fetchAddress() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // String UserId = prefs.getString('UserId');
//       String token = prefs.getString('token');
//
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//
//
//       Response response =
//       await get('http://wootest.raincreatives.com/wooapp/wp-json/wooapp/v3/list_shipping_addres', headers: headers);
//
//       final jsonResponse = json.decode(response.body);
//       print('not json $jsonResponse');
//       _addressModel = new AddressListModel.fromJson(jsonResponse);
//       print(_addressModel.data);
//       if(_addressModel.data.length>0) {
//         prefs = await SharedPreferences.getInstance();
//         prefs.setString('firstname', _addressModel.data[0].firstName);
//         prefs.setString("lastname", _addressModel.data[0].lastName);
//         prefs.setString("address1", _addressModel.data[0].address);
//         prefs.setString("city", _addressModel.data[0].city);
//         prefs.setString("postcode", _addressModel.data[0].postcode);
//         prefs.setString("country_id", _addressModel.data[0].country);
//         prefs.setString("zone_id", _addressModel.data[0].state);
//         prefs.commit();
//       }
//
//       return _addressModel;
//     } catch (e) {
//       print('caught error $e');
//     }
//   }
//
//   Future<AddressListModel> DeleteAddress(String add_key) async {
//     EasyLoading.show(status: 'Please wait...');
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // String UserId = prefs.getString('UserId');
//       String token = prefs.getString('token');
//
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//
//       final msg = jsonEncode({"address_key": add_key});
//       print(msg);
//
//       Response response = await post(
//           'http://wootest.raincreatives.com/wooapp/wp-json/wooapp/v3/delete_shipping_addres',
//           headers: headers,
//           body: msg);
//
//       final jsonResponse = json.decode(response.body);
//       print('not json $jsonResponse');
//       print('Response body2: ${response.body}');
//       // orderDetailModel = new OrderDetailModel.fromJson(jsonResponse);
//       toast('Deleted');
//       EasyLoading.dismiss();
//       setState(() {});
//
//       return _addressModel;
//     } catch (e) {
//       EasyLoading.dismiss();
//       print('caught error $e');
//     }
//   }
//
//   fetchData() async {
//     setState(() {
//       mIsLoading = true;
//     });
//     var addresses = await loadAddresses();
//     setState(() {
//       addressList.clear();
//       addressList.addAll(addresses);
//       isLoaded = true;
//       mIsLoading = false;
//     });
//   }
//
//   deleteAddress(ShAddressModel model) async {
//     setState(() {
//       addressList.remove(model);
//     });
//   }
//
//   // editAddress(ShAddressModel model) async {
//   //   var bool = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //           builder: (BuildContext context) => AddNewAddressScreen(
//   //             addressModel: model,
//   //           ))) ??
//   //       false;
//   //   if (bool) {
//   //     fetchData();
//   //   }
//   // }
//
//   editAddress(model) async {
//     SendAppData();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('pages',"normal");
//     prefs.setString('from', "address");
//     var bool = await Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (BuildContext context) => AddNewAddressScreen(
//               addressModel: model,
//             ))) ??
//         false;
//     if (bool) {
//       fetchAddress();
//     }
//   }
//
//   Future<List<ShAddressModel>> loadAddresses() async {
//     String jsonString = await loadContentAsset('assets/address.json');
//     final jsonResponse = json.decode(jsonString);
//     return (jsonResponse as List)
//         .map((i) => ShAddressModel.fromJson(i))
//         .toList();
//   }
//
//   Future<bool> _onWillPop() async{
//     SendAppData();
//     Navigator.pushAndRemoveUntil(
//       context,
//       // MaterialPageRoute(
//       //     builder: (BuildContext context) => DashboardScreen()),
//       // ModalRoute.withName('/DashboardScreen'),
//         MaterialPageRoute(
//             builder: (BuildContext context) => BottomUiScreen()),
//         ModalRoute.withName('/BottomUiScreen'),
//
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//
//     NewView(int index5) {
//       if (selectedAddressIndex == index5) {
//         return Column(
//           children: <Widget>[
//             Container(
//               alignment: Alignment.center,
//               child: MaterialButton(
//                 color: food_colorAccent,
//                 elevation: 0,
//                 padding: EdgeInsets.only(
//                     top: spacing_middle, bottom: spacing_middle),
//                 onPressed: ()  async{
//                   SendAppData();
//                   launchScreen(context, ShipmentScreen.tag);
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     text('Deliver to this address',
//                         textColor: sh_white, fontFamily: 'Bold')
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: spacing_standard_new,
//             ),
//             Container(
//               alignment: Alignment.center,
//               child: MaterialButton(
//                 color: sh_light_gray,
//                 elevation: 0,
//                 padding: EdgeInsets.only(
//                     top: spacing_middle, bottom: spacing_middle),
//                 onPressed: () => {editAddress(addressList[index5])},
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     text('Edit address',
//                         textColor: sh_textColorPrimary, fontFamily: 'Bold')
//                   ],
//                 ),
//               ),
//             )
//           ],
//         );
//       } else {
//         return Container();
//       }
//     }
//
//     final listView2 = ListView.builder(
//       physics: BouncingScrollPhysics(),
//       padding: EdgeInsets.only(
//           top: spacing_standard_new, bottom: spacing_standard_new),
//       itemBuilder: (item, index) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: spacing_standard_new),
//           child: InkWell(
//             onTap: () {
//               setState(() {
//                 selectedAddressIndex = index;
//               });
//             },
//             child: Container(
//               padding: EdgeInsets.all(spacing_standard_new),
//               margin: EdgeInsets.only(
//                 right: spacing_standard_new,
//                 left: spacing_standard_new,
//               ),
//               color: sh_white,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Radio(
//                       value: index,
//                       groupValue: selectedAddressIndex,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedAddressIndex = value;
//                         });
//                       },
//                       activeColor: primaryColor),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         text(
//                             addressList[index].first_name +
//                                 " " +
//                                 addressList[index].last_name,
//                             textColor: sh_textColorPrimary,
//                             fontFamily: fontMedium,
//                             fontSize: textSizeLargeMedium),
//                         text(addressList[index].address,
//                             textColor: sh_textColorPrimary,
//                             fontSize: textSizeMedium),
//                         text(
//                             addressList[index].city +
//                                 "," +
//                                 addressList[index].state,
//                             textColor: sh_textColorPrimary,
//                             fontSize: textSizeMedium),
//                         text(
//                             addressList[index].country +
//                                 "," +
//                                 addressList[index].pinCode,
//                             textColor: sh_textColorPrimary,
//                             fontSize: textSizeMedium),
//                         SizedBox(
//                           height: spacing_standard_new,
//                         ),
//                         text(addressList[index].phone_number,
//                             textColor: sh_textColorPrimary,
//                             fontSize: textSizeMedium),
//                         SizedBox(
//                           height: spacing_standard_new,
//                         ),
//                         NewView(index),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//       shrinkWrap: true,
//       itemCount: addressList.length,
//     );
//
//     void _printTap2(BuildContext context, String gesture, TapPosition position,int index) {
//       // print('${details.globalPosition}');
//       final String formattedDateTime =
//       DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now()).toString();
//       final String formattedDate =
//       DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
//       final RenderBox box = context.findRenderObject();
//       final Offset localOffset = box.globalToLocal(position.global);
//       itModel = CordinatesModel(x_cordinate: localOffset.dx, y_cordinate: localOffset.dy,co_datetime: formattedDateTime,co_date: formattedDate);
//       itemsModel.add(itModel);
//       setState(() {
//         itemsModel=itemsModel;
//       });
//       editAddress(_addressModel.data[index]);
//     }
//
//     listView(data) {
//       return ListView.builder(
//         scrollDirection: Axis.vertical,
//         physics: NeverScrollableScrollPhysics(),
//         padding: EdgeInsets.only(
//             top: spacing_standard_new, bottom: spacing_standard_new),
//         itemBuilder: (item, index) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: spacing_standard_new),
//             child: InkWell(
//               onTap: () {
//                 setState(() {
//                   selectedAddressIndex = index;
//                 });
//               },
//               child: Container(
//
//                 padding: EdgeInsets.all(textSizeNormal),
//                 margin: EdgeInsets.only(
//                   right: spacing_standard_new,
//                   left: spacing_standard_new,
//                 ),
//                 decoration: boxDecoration(
//                     radius: 2,
//                     showShadow: true,
//                     color: sh_white
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Row(
//                             children: [
//                               Text(
//                                 _addressModel.data[index].firstName +
//                                     " " +
//                                     _addressModel.data[index].lastName,
//                                 style: TextStyle(
//                                     color: sh_textColorPrimary,
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: 'Regular'),
//                               ),
//
//                             ],
//                           ),
//                           SizedBox(height: 12,),
//                           Text(
//                             _addressModel.data[index].address +
//                                 ", " + _addressModel.data[index].city+",",
//                             style: TextStyle(
//                                 color: sh_app_black,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.normal,
//                                 fontFamily: 'Regular'),
//                           ),
//                           SizedBox(height: 8,),
//                           Text(
//                             _addressModel.data[index].state +
//                                 " - " + _addressModel.data[index].postcode,
//                             style: TextStyle(
//                                 color: sh_app_black,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.normal,
//                                 fontFamily: 'Regular'),
//                           ),
//                           SizedBox(height: 8,),
//                           Text(
//                             _addressModel.data[index].country,
//                             style: TextStyle(
//                                 color: sh_app_black,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.normal,
//                                 fontFamily: 'Regular'),
//                           ),
//                           SizedBox(height: 12,),
//                           Row(
//                             children: [
//                               PositionedTapDetector2(
//                                 onTap: (position) => _printTap2(context,'Single tap', position,index),
//                                 onDoubleTap: (position) => _printTap2(context,'Double tap', position,index),
//                                 onLongPress: (position) => _printTap2(context,'Long press', position,index),
//                                 child: Expanded(
//                                   flex: 4,
//                                   child: Container(
//                                     padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
//                                     decoration: BoxDecoration(
//                                         color: sh_view_color,
//                                         borderRadius: BorderRadius.all(Radius.circular(2))),
//                                     child: Center(
//                                       child: Text("EDIT",
//                                         style: TextStyle(
//                                             color: sh_app_black,
//                                             fontSize: 14,
//                                             fontFamily: 'Regular'),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(flex: 2,child: Container(),),
//                               Expanded(
//                                 flex: 4,
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     showDialog<void>(
//                                       context: context,
//                                       barrierDismissible: false, // user must tap button for close dialog!
//                                       builder: (BuildContext context) {
//                                         return AlertDialog(
//                                           title: Text('Alert!'),
//                                           content: Text("Do you want to delete this address?"),
//                                           actions: [
//                                             TextButton(
//                                               child: const Text('No'),
//                                               onPressed: () {
//                                                 Navigator.of(context).pop(ConfirmAction.CANCEL);
//                                               },
//                                             ),
//                                             TextButton(
//                                               child: const Text('Yes'),
//                                               onPressed: () {
//                                                 Navigator.of(context).pop(ConfirmAction.CANCEL);
// //                    launchScreen(context, ShCartScreen.tag);
// DeleteAddress(_addressModel.data[index].key);
//                                               },
//                                             )
//                                           ],
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: Container(
//                                     padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
//                                     decoration: BoxDecoration(
//                                         color: sh_view_color,
//                                         borderRadius: BorderRadius.all(Radius.circular(2))),
//                                     child: Center(
//                                       child: Text("DELETE",
//                                         style: TextStyle(
//                                             color: sh_app_black,
//                                             fontSize: 14,
//                                             fontFamily: 'Regular'),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],)
//
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//         shrinkWrap: true,
//         itemCount: _addressModel.data.length,
//       );
//     }
//
//     ListValidation(){
//       if(_addressModel.data.length == 0){
//         return Container(
//           height: height,
//           alignment: Alignment.center,
//           child: Center(
//             child: Text(
//               'No Address Found',
//               style: TextStyle(
//                   fontSize: 20,
//                   color: sh_app_blue,
//                   fontFamily: 'Bold',
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//         );
//       }else{
//         return listView(_addressModel.data);
//       }
//     }
//
//     return PositionedTapDetector2(
//       onTap: (position) => _printTap(context,'Single tap', position),
//       onDoubleTap: (position) => _printTap(context,'Double tap', position),
//       onLongPress: (position) => _printTap(context,'Long press', position),
//       child: Screenshot(
//         controller: screenshotController,
//         child: Scaffold(
//           appBar: AppBar(
//             actions: <Widget>[
//               IconButton(
//                   color: sh_app_black,
//                   icon: Icon(Icons.add),
//                   onPressed: () async {
//                     SendAppData();
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     prefs.setString('from', "address");
//
//                     var bool = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddNewAddressScreen())) ?? false;
//                     if (bool) {
//                       fetchData();
//                     }
//                   })
//             ],
//             iconTheme: IconThemeData(color: sh_textColorPrimary),
//             title: text(sh_lbl_address_manager,
//                 textColor: sh_textColorPrimary,
//                 fontSize: textSizeNormal,
//                 fontFamily: 'Bold'),
//             backgroundColor: sh_white,
//           ),
//           body: WillPopScope(
//             onWillPop: _onWillPop,
//             child: Container(
//               color: sh_item_background,
//               child: Center(
//                 child: FutureBuilder<AddressListModel>(
//                   future: fetchAddress(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       return Container(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: <Widget>[
//                             Expanded(
//                               child: SingleChildScrollView(
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(bottom: 70.0),
//                                   child: Column(
//                                     children: <Widget>[
//                                       ListValidation()
//                                       // listView(_addressModel.data)
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     } else if (snapshot.hasError) {
//                       return Text("${snapshot.error}");
//                     }
//                     // By default, show a loading spinner.
//                     return CircularProgressIndicator();
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
