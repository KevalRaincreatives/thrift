// import 'dart:async';
// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:thrift/api_service/Url.dart';
// import 'dart:math';
// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:nb_utils/nb_utils.dart' hide lightGrey;
// import 'package:photo_view/photo_view.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:thrift/database/CartPro.dart';
// import 'package:thrift/database/database_hepler.dart';
// import 'package:thrift/model/AddCartModel.dart';
// import 'package:thrift/model/CartModel.dart';
// import 'package:thrift/model/EstPriceModel.dart';
// import 'package:thrift/model/GetVariantModel.dart';
// import 'package:thrift/model/MyVariant.dart';
// import 'package:thrift/model/ProductDetailModel.dart';
// import 'package:thrift/model/ProductListModel.dart';
// import 'package:thrift/model/ReportProductModel.dart';
// import 'package:http/http.dart' as http;
// import 'package:thrift/model/ProductSellerModel.dart';
// import 'package:thrift/provider/pro_det_provider.dart';
// import 'package:thrift/screens/CartScreen.dart';
// import 'package:thrift/screens/LoginScreen.dart';
// import 'package:thrift/screens/SellerProfileScreen.dart';
// import 'package:thrift/utils/ShColors.dart';
// import 'package:thrift/utils/ShConstant.dart';
// import 'package:thrift/utils/ShExtension.dart';
// import 'package:badges/badges.dart';
// import 'package:provider/provider.dart';
// import 'package:thrift/utils/network_status_service.dart';
// import 'package:thrift/utils/NetworkAwareWidget.dart';
//
// class ProductDetailScreen extends StatefulWidget {
//   static String tag = '/ProductDetailScreen';
//   List<String>? proImage;
//   final String? proName, proPrice;
//
//   // ProductListModel? product;
//
//   ProductDetailScreen({this.proName, this.proPrice, this.proImage});
//
//   @override
//   _ProductDetailScreenState createState() => _ProductDetailScreenState();
// }
//
// class _ProductDetailScreenState extends State<ProductDetailScreen> {
//   dynamic yMin;
//   dynamic yMax;
//
//   var position = 0;
//   bool isExpanded = false;
//   var selectedColor = -1;
//   var selectedSize = -1;
//   double fiveStar = 0;
//   double fourStar = 0;
//   double threeStar = 0;
//   double twoStar = 0;
//   double oneStar = 0;
//   bool _autoValidate = false;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   TextEditingController controller = TextEditingController();
//   PageController? _controller;
//
//   Future<ProductDetailModel?>? futuredetail;
//   // ProductDetailModel? pro_det_model;
//   GetVariantModel? getVariantModel;
//   final GlobalKey<State> _keyLoader = new GlobalKey<State>();
//   List<ProductListModel> productListModel = [];
//   bool _isColorVisible = false;
//   bool _isSizeVisible = false;
//   String? selectedValue = null;
//   List<String> selectedItemValue = <String>[];
//   AddCartModel? addCartModel;
//   List<CartPro> cartPro = [];
//   final dbHelper = DatabaseHelper.instance;
//   final List<MyVariant> itemsModel = [];
//   MyVariant? itModel;
//   String mynames = "";
//   String myvariation_name = '';
//   String myvariation_value = '';
//
//   static const _kDuration = const Duration(milliseconds: 300);
//
//   static const _kCurve = Curves.ease;
//
//   final _kArrowColor = Colors.black.withOpacity(0.8);
//   // bool _isVisible = true;
//   // bool _isVisible_success = false;
//   // ProductSellerModel? productSellerModel;
//   CartModel? cat_model;
//   // Future<ProductDetailModel?>? fetchDetailMain;
//   ReportProductModel? reportProductModel;
//   // bool? ct_changel = true;
//   bool singleTap = true;
//   String myFinalToken = '';
//
//   @override
//   void initState() {
//     _controller = PageController();
//     // fetchDetailMain = fetchDetail();
//     final emp_pd = Provider.of<ProductDetailProvider>(context, listen: false);
//     emp_pd.getProductDetail();
//     emp_pd.getSellerDetail();
//     super.initState();
// //    mListings2 = getPopular();
//   }
//
//   Future<bool> _onWillPop() async {
//     Navigator.pop(context);
//     return false;
//   }
//
//
//   Future<ReportProductModel?> reportProduct(
//       String pro_name, String reason) async {
//     EasyLoading.show(status: 'Please wait...');
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // String UserId = prefs.getString('UserId');
//       String? token = prefs.getString('token');
//       String? pro_id = prefs.getString('pro_id');
//
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//
//       final msg = jsonEncode(
//           {"product_name": pro_name, "product_id": pro_id, "reason": reason});
//       print(msg);
//
//       var response = await http
//           .post(
//               Uri.parse(
//                   '${Url.BASE_URL}wp-json/wooapp/v3/report_product'),
//               body: msg,
//               headers: headers)
//           ;
//
//       final jsonResponse = json.decode(response.body);
//       print(
//           'ProductDetailScreen report_product Response status2: ${response.statusCode}');
//       print(
//           'ProductDetailScreen report_product Response body2: ${response.body}');
//       reportProductModel = new ReportProductModel.fromJson(jsonResponse);
//       EasyLoading.dismiss();
//       singleTap = true;
//       if (reportProductModel!.response!.success!) {
//         Navigator.of(context, rootNavigator: true).pop();
//         _openCustomDialog4();
//       } else {
//         toast(reportProductModel!.response!.msg!);
//       }
//
//       return reportProductModel;
//     } on Exception catch (e) {
//       EasyLoading.dismiss();
//
//       singleTap = true;
//       print('caught error $e');
//     }
//   }
//
//
//
//
//   Future<ProductDetailModel?> AddCart() async {
// //    Dialogs.showLoadingDialog(context, _keyLoader);
// //     EasyLoading.show(status: 'Please wait...');
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? pro_id = prefs.getString('pro_id');
//       String? token = prefs.getString('token');
//       String? variant_id = prefs.getString('variant_id');
//
//       print(token);
//
//       // Response response = await get(
//       //     'https://encros.rcstaging.co.in/wp-json/v3/wooapp_add_to_cart?product_id=$pro_id&quantity=1');
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//       final msg = jsonEncode(
//           {"quantity": "1", "product_id": pro_id, "variation_id": variant_id});
//       print(msg);
//
//       // Response response = await post(
//       //     'https://encros.rcstaging.co.in/wp-json/wooapp/v3/wooapp_add_to_cart',
//       //     headers: headers,
//       //     body: msg);
//       var response = await http
//           .post(
//               Uri.parse(
//                   '${Url.BASE_URL}wp-json/wooapp/v3/wooapp_add_to_cart'),
//               body: msg,
//               headers: headers)
//           ;
//
//       print(
//           'ProductDetailScreen wooapp_add_to_cart Response status2: ${response.statusCode}');
//       print(
//           'ProductDetailScreen wooapp_add_to_cart Response body2: ${response.body}');
//       final jsonResponse = json.decode(response.body);
//
//       if (response.statusCode == 200) {
//         addCartModel = new AddCartModel.fromJson(jsonResponse);
//
//         if (addCartModel!.status == true) {
//           // EasyLoading.dismiss();
//           if (addCartModel!.cart == null) {
//             prefs.setInt("cart_count", 0);
//             cart_count == 0;
//           } else if (addCartModel!.cart!.length == 0) {
//             prefs.setInt("cart_count", 0);
//             cart_count == 0;
//           } else {
//             prefs.setInt("cart_count", addCartModel!.cart!.length);
//             cart_count == addCartModel!.cart!.length;
//           }
//
//           // ct_changel = true;
//           // _incrementCounter();
//
// //           showDialog<void>(
// //             context: context,
// //             barrierDismissible: false, // user must tap button for close dialog!
// //             builder: (BuildContext context) {
// //               return AlertDialog(
// //                 title: Text('Success'),
// //                 content: Text("Product added to cart"),
// //                 actions: [
// //                   TextButton(
// //                     child: const Text('Continue Shopping'),
// //                     onPressed: () {
// //                       Navigator.of(context).pop(ConfirmAction.CANCEL);
// //                     },
// //                   ),
// //                   TextButton(
// //                     child: const Text('View Cart'),
// //                     onPressed: () {
// //                       Navigator.of(context).pop(ConfirmAction.CANCEL);
// // //                    launchScreen(context, ShCartScreen.tag);
// //                       Navigator.pushReplacement(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (context) => CartScreen(),
// //                         ),
// //                       );
// //                     },
// //                   )
// //                 ],
// //               );
// //             },
// //           );
//         } else {
//           // EasyLoading.dismiss();
//           toast('Something went wrong');
//           showDialog<void>(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: Text('Server Response:'),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: <Widget>[
//                       Text('Msg: ${response.body}'),
//                       SizedBox(height: 16),
//                     ],
//                   ),
//                 );
//               });
//         }
//       } else {
//         // EasyLoading.dismiss();
//         toast('Spmething went wrong');
//         showDialog<void>(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text('Server Response:'),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: <Widget>[
//                     Text('Msg: ${response.body}'),
//                     SizedBox(height: 16),
//                   ],
//                 ),
//               );
//             });
//       }
//       return null;
//     } on Exception catch (e) {
//
//       print('caught error $e');
//     }
//   }
//
//
//   int? cart_count;
//
//   Future<String?> fetchtotal() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       if (prefs.getInt('cart_count') != null) {
//         cart_count = prefs.getInt('cart_count');
//       } else {
//         cart_count = 0;
//       }
//
//       return '';
//     } catch (e) {
//       print('caught error $e');
//     }
//   }
//
//
//   void _openCustomDialog4() {
//     showGeneralDialog(
//         barrierColor: Colors.black.withOpacity(0.5),
//         transitionBuilder: (context, a1, a2, widget) {
//           return Transform.scale(
//             scale: a1.value,
//             child: Opacity(
//               opacity: a1.value,
//               child: AlertDialog(
//                 shape: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16.0)),
//                 title: Center(
//                     child: Text(
//                   'Your report has been successfully submitted',
//                   style: TextStyle(
//                       color: sh_colorPrimary2,
//                       fontSize: 18,
//                       fontFamily: 'Bold'),
//                   textAlign: TextAlign.center,
//                 )),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(
//                       height: 8,
//                     ),
//                     InkWell(
//                       onTap: () async {
//                         Navigator.of(context, rootNavigator: true).pop();
//                       },
//                       child: Container(
//                         width: MediaQuery.of(context).size.width * .7,
//                         padding: EdgeInsets.only(top: 6, bottom: 10),
//                         decoration: boxDecoration(
//                             bgColor: sh_btn_color,
//                             radius: 10,
//                             showShadow: true),
//                         child: text("Close",
//                             fontSize: 16.0,
//                             textColor: sh_colorPrimary2,
//                             isCentered: true,
//                             fontFamily: 'Bold'),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//         transitionDuration: Duration(milliseconds: 200),
//         barrierDismissible: false,
//         barrierLabel: '',
//         context: context,
//         pageBuilder: (context, animation1, animation2) {
//           return Container();
//         });
//   }
//
//   Future<String?> fetchUserStatus() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? final_token = prefs.getString('token');
//       if (final_token != null && final_token != '') {
//         myFinalToken = final_token;
//         Provider.of<ProductDetailProvider>(context,listen: false).getEstmatePrice();
//
//       } else {
//         myFinalToken = '';
//       }
//
//       return 'checkUserModel';
//     } catch (e) {
//       // EasyLoading.dismiss();
//       print('caught error $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final product_pro = Provider.of<ProductDetailProvider>(context);
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//
//     void _insert() async {
//       // row to insert
//       if (myvariation_name.length > 2) {
//         myvariation_name = myvariation_name.substring(1);
//         myvariation_value = myvariation_value.substring(1);
//       }
//       print(myvariation_name);
//       print(myvariation_value);
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? variation_id = prefs.getString('variant_id');
//
//       final allRows = await dbHelper.queryAllRows();
//       cartPro.clear();
//       allRows.forEach((row) => cartPro.add(CartPro.fromJson(row)));
//       if ((cartPro.singleWhereOrNull(
//             (it) => it.product_id == product_pro.pro_det_model!.id.toString(),
//       )) !=
//           null) {
//         print('Already exists!');
//         int chk = 0;
//         for (var i = 0; i < cartPro.length; i++) {
//           if (cartPro[i].product_id == product_pro.pro_det_model!.id.toString()) {
//             chk == i;
//           }
//         }
//         int dd = int.parse(cartPro[chk].quantity!) + 1;
//
//         double fnlamnt = double.parse(cartPro[chk].line_subtotal!) *
//             double.parse(dd.toString());
//
//         CartPro car = CartPro(
//             cartPro[chk].id,
//             cartPro[chk].product_id,
//             cartPro[chk].product_name,
//             cartPro[chk].product_img,
//             cartPro[chk].variation_id,
//             cartPro[chk].variation_name,
//             cartPro[chk].variation_value,
//             dd.toString(),
//             cartPro[chk].line_subtotal,
//             fnlamnt.toString());
//         final rowsAffected = await dbHelper.update(car);
//
//         // print('Already exists!');
//       } else {
//         print('Added!');
//         Map<String, dynamic> row = {
//           DatabaseHelper.columnProductId: product_pro.pro_det_model!.id.toString(),
//           DatabaseHelper.columnProductName: product_pro.pro_det_model!.name.toString(),
//           DatabaseHelper.columnProductImage:
//           product_pro.pro_det_model!.images![0]!.src.toString(),
//           DatabaseHelper.columnVariationId: variation_id,
//           DatabaseHelper.columnVariationName: myvariation_name,
//           DatabaseHelper.columnVariationValue: myvariation_value,
//           DatabaseHelper.columnQuantity: "1",
//           DatabaseHelper.columnLine_subtotal: product_pro.pro_det_model!.price.toString(),
//           DatabaseHelper.columnLine_total: product_pro.pro_det_model!.price.toString(),
//         };
//         CartPro car = CartPro.fromJson(row);
//         final id = await dbHelper.insert(car);
//       }
//
//       // toast('inserted row id: $id');
//     }
//
//
//     void _openCustomDialog2() {
//       final _formKey = GlobalKey<FormState>();
//       String? cc = product_pro.pro_det_model!.name!;
//       var reasonCont = TextEditingController();
//
//       showGeneralDialog(
//           barrierColor: Colors.black.withOpacity(0.5),
//           transitionBuilder: (context, a1, a2, widget) {
//             return Transform.scale(
//               scale: a1.value,
//               child: Opacity(
//                 opacity: a1.value,
//                 child: AlertDialog(
//                   shape: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16.0)),
//                   title: Center(
//                       child: Text(
//                     'Do you want to report $cc(Product)?',
//                     style: TextStyle(
//                         color: sh_colorPrimary2,
//                         fontSize: 18,
//                         fontFamily: 'Bold'),
//                     textAlign: TextAlign.center,
//                   )),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(
//                         height: 8,
//                       ),
//                       Center(
//                           child: Text(
//                         'Why are you Reporting?',
//                         style: TextStyle(
//                             color: sh_colorPrimary2,
//                             fontSize: 15,
//                             fontFamily: 'Bold'),
//                         textAlign: TextAlign.center,
//                       )),
//                       SizedBox(
//                         height: 16,
//                       ),
//                       Form(
//                         key: _formKey,
//                         child: Container(
//                           color: Colors.transparent,
//                           padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                           child: TextFormField(
//                             maxLines: 5,
//                             style: TextStyle(
//                                 color: sh_colorPrimary2,
//                                 fontSize: textSizeMedium,
//                                 fontFamily: "Bold"),
//                             controller: reasonCont,
//                             validator: (text) {
//                               if (text == null || text.isEmpty) {
//                                 return 'Please Enter Reason';
//                               }
//                               return null;
//                             },
//                             decoration: InputDecoration(
//                               filled: true,
//                               hintMaxLines: 5,
//                               fillColor: sh_text_back,
//                               contentPadding:
//                                   EdgeInsets.fromLTRB(16, 16, 16, 16),
//                               hintText: "Type Report",
//                               hintStyle: TextStyle(color: sh_colorPrimary2),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(
//                                     color: sh_transparent, width: 0.7),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(
//                                     color: sh_transparent, width: 0.7),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 16,
//                       ),
//                       InkWell(
//                         onTap: () async {
//                           if (_formKey.currentState!.validate()) {
//                             // TODO submit
//                             FocusScope.of(context).requestFocus(FocusNode());
//                             if (singleTap) {
//                               reportProduct(cc, reasonCont.text);
//                               setState(() {
//                                 singleTap = false; // update bool
//                               });
//                             }
//                           }
//                         },
//                         child: Container(
//                           width: MediaQuery.of(context).size.width * .7,
//                           padding: EdgeInsets.only(top: 6, bottom: 10),
//                           decoration: boxDecoration(
//                               bgColor: sh_colorPrimary2,
//                               radius: 10,
//                               showShadow: true),
//                           child: text("Report",
//                               fontSize: 16.0,
//                               textColor: sh_white,
//                               isCentered: true,
//                               fontFamily: 'Bold'),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       InkWell(
//                         onTap: () async {
//                           Navigator.of(context, rootNavigator: true).pop();
//                         },
//                         child: Container(
//                           width: MediaQuery.of(context).size.width * .7,
//                           padding: EdgeInsets.only(top: 6, bottom: 10),
//                           decoration: boxDecoration(
//                               bgColor: sh_btn_color,
//                               radius: 10,
//                               showShadow: true),
//                           child: text("Cancel",
//                               fontSize: 16.0,
//                               textColor: sh_colorPrimary2,
//                               isCentered: true,
//                               fontFamily: 'Bold'),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//           transitionDuration: Duration(milliseconds: 200),
//           barrierDismissible: false,
//           barrierLabel: '',
//           context: context,
//           pageBuilder: (context, animation1, animation2) {
//             return Container();
//           });
//     }
//
//     void _openCustomDialog3(int index) {
//       PageController? _controller2 = PageController(
//           initialPage: index, keepPage: true, viewportFraction: 1);
//       showGeneralDialog(
//           barrierColor: Colors.black.withOpacity(0.5),
//           context: context,
//           pageBuilder: (context, animation1, animation2) => Scaffold(
//               backgroundColor: Colors.black87,
//               body: SafeArea(
//                   child: Stack(
//                 children: [
//                   PageView.builder(
//                     controller: _controller2,
//                     itemCount: widget.proImage!.length,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         child: Padding(
//                           padding: const EdgeInsets.all(1.0),
//                           child: Card(
//                               semanticContainer: true,
//                               clipBehavior: Clip.antiAliasWithSaveLayer,
//                               elevation: 0,
//                               margin: EdgeInsets.all(0),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               child: PhotoView(
//                                   imageProvider:
//                                   NetworkImage(
//
//                                 widget.proImage![index],
//                               ))
//                               // Image.network(
//                               //     pro_det_model!.images![index]!.src!,
//                               //     fit: BoxFit.cover),
//                               ),
//                         ),
//                       );
//                     },
//                   ),
//                   new Positioned(
//                     bottom: 0.0,
//                     left: 0.0,
//                     right: 0.0,
//                     child: new Container(
//                       padding: const EdgeInsets.all(20.0),
//                       child: new Center(
//                         child: new DotsIndicator(
//                           controller: _controller2,
//                           itemCount: product_pro.pro_det_model!.images!.length,
//                           onPageSelected: (int page) {
//                             _controller2.animateToPage(
//                               page,
//                               duration: _kDuration,
//                               curve: _kCurve,
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     alignment: Alignment.topLeft,
//                     margin: EdgeInsets.fromLTRB(20, 20, 20, 26),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.of(context, rootNavigator: true).pop();
//                       },
//                       child: _icon(Icons.close,
//                           color: sh_white,
//                           size: 15,
//                           padding: 12,
//                           isOutLine: false),
//                     ),
//                   )
//                 ],
//               ))
//               //Put your screen design here!
//               ));
//     }
//
//     Imagevw4() {
//       if (widget.proImage!.length < 1) {
//         return
//             //   Image.asset(
//             //   sh_no_img,
//             //   fit: BoxFit.fill,
//             //   height: width * 0.34,
//             // );
//             Image.asset(sh_no_img, width: width, height: 250, fit: BoxFit.fill);
//       } else {
//         return Stack(
//           children: [
//             PageView.builder(
//               controller: _controller,
//               itemCount: widget.proImage!.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     _openCustomDialog3(index);
//                   },
//                   child: Container(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
//                       child: Card(
//                         semanticContainer: true,
//                         clipBehavior: Clip.antiAliasWithSaveLayer,
//                         elevation: 0,
//                         margin: EdgeInsets.all(0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18.0),
//                         ),
//                         child:  CachedNetworkImage(
//                           imageUrl: widget.proImage![index],
//                           fit: BoxFit.cover,
//                           alignment: Alignment.topCenter,
//                           filterQuality: FilterQuality.low,
//                           placeholder: (context, url) =>
//                               Center(
//                                 child: SizedBox(
//                                     height: 30,
//                                     width: 30,
//                                     child:
//                                     CircularProgressIndicator()),
//                               ),
//                           errorWidget:
//                               (context, url, error) =>
//                           new Icon(Icons.error),
//                         )
//                         // FadeInImage.assetNetwork(
//                         //     placeholder: 'images/tenor.gif',
//                         //     image: widget.proImage![index],
//                         //     fit: BoxFit.fitWidth),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             new Positioned(
//               bottom: 0.0,
//               left: 0.0,
//               right: 0.0,
//               child: new Container(
//                 padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 26),
//                 child: new Center(
//                   child: new DotsIndicator(
//                     controller: _controller,
//                     itemCount: widget.proImage!.length,
//                     onPageSelected: (int page) {
//                       _controller!.animateToPage(
//                         page,
//                         duration: _kDuration,
//                         curve: _kCurve,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             // Positioned(
//             //   bottom: 0.0,
//             //   right: 0.0,
//             //   child: Padding(
//             //     padding: const EdgeInsets.fromLTRB(16.0, 16, 10, 18),
//             //     child: InkWell(
//             //       onTap: () async {
//             //         SharedPreferences prefs = await SharedPreferences.getInstance();
//             //         String? UserId = prefs.getString('UserId');
//             //         String? token = prefs.getString('token');
//             //         if (UserId != null && UserId != '') {
//             //           _openCustomDialog2();
//             //         }else{
//             //           Navigator.push(
//             //             context,
//             //             MaterialPageRoute(
//             //               builder: (context) => LoginScreen(),
//             //             ),
//             //           );
//             //         }
//             //       },
//             //       child: Padding(
//             //         padding: const EdgeInsets.all(6.0),
//             //         child: Image.asset(imgWarning2,height: 20,),
//             //       ),
//             //     ),
//             //     // new IconButton(
//             //     //     icon: new Image.asset(sh_report_pro,height: 20,width: 20,fit: BoxFit.fill,),
//             //     //     onPressed: () {
//             //     //       _openCustomDialog2();
//             //     //     }),
//             //   ),
//             // )
//           ],
//         );
//       }
//     }
//
//     MyPriceSuccess() {
//       // var myprice2 = double.parse(pro_det_model!.price!);
//       // var myprice = myprice2.toStringAsFixed(2);
//       var myprice2, myprice;
//       if (product_pro.pro_det_model!.price == '') {
//         myprice = "0.00";
//       } else {
//         myprice2 = double.parse(product_pro.pro_det_model!.price!);
//         myprice = myprice2.toStringAsFixed(2);
//       }
//
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "\$" + myprice + " " + "USD",
//             style: TextStyle(
//                 color: sh_black,
//                 fontFamily: fontBold,
//                 fontSize: textSizeMedium),
//           ),
//           SizedBox(
//             width: 5,
//           ),
//           // Text(
//           //   "\$" + myprice,
//           //   style: TextStyle(
//           //       color: sh_red,
//           //       fontFamily: fontBold,
//           //       fontSize: textSizeSMedium,
//           //       decoration: TextDecoration.lineThrough),
//           // )
//         ],
//       );
//     }
//
//     Imagevwsuccess() {
//       if (product_pro.isVisible_success) {
//         if (product_pro.pro_det_model!.images!.length < 1) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12.0),
//                 child: Image.asset(sh_no_img,
//                     width: width * .4, height: width * .4, fit: BoxFit.fill),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 product_pro.pro_det_model!.name!,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                     color: sh_colorPrimary2,
//                     fontFamily: fontBold,
//                     fontSize: textSizeMedium),
//               ),
//               SizedBox(
//                 height: 4,
//               ),
//               MyPriceSuccess(),
//               // SizedBox(
//               //   height: 4,
//               // ),
//               // Text(
//               //   pro_det_model!.slug!,
//               //   maxLines: 2,
//               //   style: TextStyle(
//               //       color: sh_textColorSecondary,
//               //       fontFamily: "SemiBold",
//               //       fontSize: textSizeSMedium),
//               // )
//             ],
//           );
//         } else {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12.0),
//                 child: Image.network(
//                   product_pro.pro_det_model!.images![0]!.src!,
//                   fit: BoxFit.cover,
//                   width: width * .4,
//                   height: width * .4,
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Wrap(
//                 children: [
//                   Column(
//                     children: [
//                       Text(
//                         product_pro.pro_det_model!.name!,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                             color: sh_colorPrimary2,
//                             fontFamily: fontBold,
//                             fontSize: textSizeMedium),
//                       ),
//                       SizedBox(
//                         height: 4,
//                       ),
//                       MyPriceSuccess(),
//                       // SizedBox(
//                       //   height: 4,
//                       // ),
//                       // Text(
//                       //   pro_det_model!.slug!,
//                       //   maxLines: 2,
//                       //   style: TextStyle(
//                       //       color: sh_textColorSecondary,
//                       //       fontFamily: "SemiBold",
//                       //       fontSize: textSizeSMedium),
//                       // )
//                     ],
//                   )
//                 ],
//               ),
//             ],
//           );
//         }
//       } else {
//         return Container();
//       }
//     }
//
//     Widget _productImage() {
//       return Stack(
//         children: <Widget>[
//           SizedBox(
//             height: 250,
//             child: Column(
//               children: <Widget>[
//                 Expanded(child: Imagevw4()),
//                 // Scrollindic()
//               ],
//             ),
//           ),
//         ],
//       );
//     }
//
//     MyPrice() {
//       // var myprice2 = double.parse(pro_det_model!.price!);
//       // var myprice = myprice2.toStringAsFixed(2);
//       var myprice2, myprice;
//       if (widget.proPrice == '') {
//         myprice = "0.00";
//       } else {
//         myprice2 = double.parse(widget.proPrice!);
//         myprice = myprice2.toStringAsFixed(2);
//       }
//
//       return Row(
//         children: [
//           Text(
//             "\$" + myprice + " " + "USD",
//             style: TextStyle(
//                 color: sh_black,
//                 fontFamily: fontBold,
//                 fontSize: textSizeMedium),
//           ),
//         ],
//       );
//     }
//
//     EstPrice(estPriceModel) {
//       var myprice2, myprice;
//       if (estPriceModel!.estimatedRetailPrice == '') {
//         myprice = "0.00";
//       } else {
//         myprice2 = double.parse(estPriceModel!.estimatedRetailPrice!);
//         myprice = myprice2.toStringAsFixed(2);
//       }
//
//       return Row(
//         children: [
//           Text(
//             "\$" + myprice + " " + "USD",
//             style: TextStyle(
//                 color: sh_black, fontFamily: fontMedium, fontSize: 14),
//           ),
//         ],
//       );
//     }
//
//     CheckVariant() {
//       int? my_index = -1;
//       for (var i = 0; i < product_pro.pro_det_model!.metaData!.length; i++) {
//         if (product_pro.pro_det_model!.metaData![i]!.key == "attrs_val") {
//           my_index = i;
//         }
//       }
//
//       if (my_index == -1) {
//         return ListView.builder(
//             itemCount: product_pro.pro_det_model!.metaData!.length,
//             physics: NeverScrollableScrollPhysics(),
//             // itemExtent: 50.0,
//             shrinkWrap: true,
//             itemBuilder: (BuildContext context, int index) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     product_pro.pro_det_model!.metaData![index]!.key!,
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: fontSemibold,
//                         color: sh_colorPrimary2),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     product_pro.pro_det_model!.metaData![index]!.value!,
//                     style: TextStyle(
//                         fontSize: 14, fontFamily: fontMedium, color: sh_black),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               );
//             });
//       } else {
//         return ListView.builder(
//             itemCount: product_pro.pro_det_model!.metaData![my_index!]!.value!.length,
//             physics: NeverScrollableScrollPhysics(),
//             // itemExtent: 50.0,
//             shrinkWrap: true,
//             itemBuilder: (BuildContext context, int index) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     product_pro.pro_det_model!.metaData![my_index!]!.value![index]!.key!,
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: fontSemibold,
//                         color: sh_colorPrimary2),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     product_pro.pro_det_model!.metaData![my_index]!.value![index]!.value!,
//                     style: TextStyle(
//                         fontSize: 14, fontFamily: fontMedium, color: sh_black),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               );
//             });
//       }
//     }
//
//     BadgeCount() {
//       if (cart_count == 0) {
//         return Image.asset(
//           sh_new_cart,
//           height: 44,
//           width: 44,
//           fit: BoxFit.fill,
//           color: sh_white,
//         );
//       } else {
//         return Badge(
//           position: BadgePosition.topEnd(top: 4, end: 6),
//           badgeContent: Text(
//             cart_count.toString(),
//             style: TextStyle(color: sh_white, fontSize: 8),
//           ),
//           child: Image.asset(
//             sh_new_cart,
//             height: 44,
//             width: 44,
//             fit: BoxFit.fill,
//             color: sh_white,
//           ),
//         );
//       }
//     }
//
//     RefreshCount() {
//       return FutureBuilder<String?>(
//         future: fetchtotal(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return BadgeCount();
//           } else if (snapshot.hasError) {
//             return Text("${snapshot.error}");
//           }
//           // By default, show a loading spinner.
//           return CircularProgressIndicator();
//         },
//       );
//     }
//
//     SuccesVisiblity() {
//       if (product_pro.isVisible_success) {
//         var myprice2 = double.parse(product_pro.pro_det_model!.price!.toString());
//         var myprice = myprice2.toStringAsFixed(2);
//         return Visibility(
//             visible: product_pro.isVisible_success,
//             child: Container(
//               height: height,
//               width: width,
//               margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
//               padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
//               color: sh_white,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.check_circle_outline,
//                         color: sh_colorPrimary2,
//                         size: 30,
//                       ),
//                       SizedBox(
//                         width: 8,
//                       ),
//                       Text(
//                         "Added To Cart!",
//                         style: TextStyle(
//                             color: sh_colorPrimary2,
//                             fontSize: 24,
//                             fontFamily: fontSemibold),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Imagevwsuccess(),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     height: 0.5,
//                     color: sh_app_txt_color,
//                   ),
//                   SizedBox(
//                     height: 12,
//                   ),
//                   Column(
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             "You have ",
//                             style: TextStyle(
//                                 color: sh_colorPrimary2,
//                                 fontSize: 15,
//                                 fontFamily: fontSemibold),
//                           ),
//                           Text(
//                             "1 Item ",
//                             style: TextStyle(
//                                 color: sh_black,
//                                 fontSize: 15,
//                                 fontFamily: fontSemibold),
//                           ),
//                           Text(
//                             "in your cart",
//                             style: TextStyle(
//                                 color: sh_colorPrimary2,
//                                 fontSize: 15,
//                                 fontFamily: fontSemibold),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 6,
//                       ),
//                       Row(
//                         children: [
//                           Text(
//                             "Cart Total: ",
//                             style: TextStyle(
//                                 color: sh_colorPrimary2,
//                                 fontSize: 15,
//                                 fontFamily: fontSemibold),
//                           ),
//                           Text(
//                             "\$" + myprice + " " + "USD",
//                             style: TextStyle(
//                                 color: sh_black,
//                                 fontSize: 15,
//                                 fontFamily: fontSemibold),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 40,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       InkWell(
//                         onTap: () async {
//                           Navigator.pop(context);
//                         },
//                         child: Container(
//                           padding: EdgeInsets.all(spacing_standard),
//                           decoration: boxDecoration(
//                               bgColor: sh_btn_color,
//                               radius: 6,
//                               showShadow: true),
//                           child: text("Continue Shopping",
//                               textColor: sh_colorPrimary2,
//                               isCentered: true,
//                               fontSize: 12.0,
//                               fontFamily: 'Bold'),
//                         ),
//                       ),
//                       // CheckShimmer(),
//                       groceryButton(),
//
//                       // InkWell(
//                       //   onTap: () async {
//                       //     Navigator.of(context).pop(ConfirmAction.CANCEL);
//                       //     SharedPreferences prefs =
//                       //         await SharedPreferences.getInstance();
//                       //     prefs.setInt("shiping_index", -2);
//                       //     prefs.setInt("payment_index", -2);
//                       //     // launchScreen(context, CartScreen.tag);
//                       //     Navigator.push(
//                       //       context,
//                       //       MaterialPageRoute(
//                       //           builder: (context) => CartScreen()),
//                       //     ).then((value) {
//                       //       setState(() {
//                       //         // refresh state
//                       //       });
//                       //     });
//                       //     //   Navigator.pushReplacement(
//                       //     // context,
//                       //     // MaterialPageRoute(
//                       //     //   builder: (context) => CartScreen(),
//                       //     // ),
//                       //     // );
//                       //   },
//                       //   child: Container(
//                       //     padding: EdgeInsets.all(spacing_standard),
//                       //     decoration: boxDecoration(
//                       //         bgColor: sh_colorPrimary2,
//                       //         radius: 6,
//                       //         showShadow: true),
//                       //     child: text("Cart/Checkout",
//                       //         textColor: sh_white,
//                       //         isCentered: true,
//                       //         fontSize: 12.0,
//                       //         fontFamily: 'Bold'),
//                       //   ),
//                       // ),
//                     ],
//                   )
//                 ],
//               ),
//             ));
//       } else {
//         return Container();
//       }
//     }
//
//     SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(statusBarColor: sh_colorPrimary2));
//
//     Widget setUserForm() {
//       AppBar appBar = AppBar(
//         elevation: 0,
//         backgroundColor: sh_colorPrimary2,
//         title: Text(
//           "Product Details",
//           style: TextStyle(color: sh_white),
//         ),
//         iconTheme: IconThemeData(color: sh_white),
//         actions: <Widget>[
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () async {
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   prefs.setInt("shiping_index", -2);
//                   prefs.setInt("payment_index", -2);
//                   // launchScreen(context, CartScreen.tag);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => CartScreen()),
//                   ).then((value) {
//                     setState(() {
//                       // refresh state
//                     });
//                   });
//                 },
//                 child: RefreshCount(),
//               ),
//               SizedBox(
//                 width: 16,
//               )
//             ],
//           ),
//         ],
//       );
//       double app_height = appBar.preferredSize.height;
//       return Stack(children: <Widget>[
//         // Background with gradient
//         Container(
//             height: 120,
//             width: width,
//             child: Image.asset(sh_upper2, fit: BoxFit.fill)
//             // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
//             ),
//         //Above card
//         Visibility(
//           visible: product_pro.isVisible,
//           child: Container(
//             height: height,
//             margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
//             color: sh_white,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Expanded(
//                   flex: 9,
//                   child: SingleChildScrollView(
//                     child: Container(
//                       width: width,
//                       padding: EdgeInsets.fromLTRB(26, 0, 26, 0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.max,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Stack(
//                             children: [_productImage()],
//                           ),
//                           SizedBox(
//                             height: 8,
//                           ),
//                           Text(
//                             widget.proName!,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                                 color: sh_colorPrimary2,
//                                 fontFamily: fontBold,
//                                 fontSize: textSizeLargeMedium),
//                           ),
//                           SizedBox(
//                             height: 2,
//                           ),
//                           MyPrice(),
//                           SizedBox(
//                             height: 14,
//                           ),
//                           product_pro.loader ?
//                           Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             direction: ShimmerDirection.ltr,
//                             child: Container(
//                               width: width,
//                               padding: const EdgeInsets.fromLTRB(1, 12, 12, 12),
//                               child: Column(
//                                 crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                                 children: [
//                                   InkWell(
//                                     child: Padding(
//                                       padding: const EdgeInsets.fromLTRB(
//                                           1.0, 0, 12, 12),
//                                       child: Container(
//                                         width: width * .40,
//                                         height: 12.0,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     height: 4,
//                                   ),
//                                   InkWell(
//                                     child: Padding(
//                                       padding: const EdgeInsets.fromLTRB(
//                                           1.0, 12, 12, 12),
//                                       child: Container(
//                                         width: width * .30,
//                                         height: 12.0,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     height: 4,
//                                   ),
//                                   InkWell(
//                                     child: Padding(
//                                       padding: const EdgeInsets.fromLTRB(
//                                           1.0, 12, 12, 12),
//                                       child: Container(
//                                         width: width * .35,
//                                         height: 12.0,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     height: 10,
//                                   ),
//                                   InkWell(
//                                     child: Padding(
//                                       padding: const EdgeInsets.fromLTRB(
//                                           1.0, 12, 12, 12),
//                                       child: Container(
//                                         width: width * .20,
//                                         height: 12.0,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     height: 4,
//                                   ),
//                                   InkWell(
//                                     child: Padding(
//                                       padding: const EdgeInsets.fromLTRB(
//                                           1.0, 12, 12, 12),
//                                       child: Container(
//                                         width: width,
//                                         height: 62.0,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ) :
//                           Stack(
//                             children: <Widget>[
//                               Column(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       FutureBuilder<String?>(
//                                           future: fetchUserStatus(),
//                                           builder: (context, snapshot) {
//                                             if (snapshot.hasData) {
//                                               if (myFinalToken != '') {
//                                                 return
//                                                 Consumer<ProductDetailProvider>(builder: ((context, value, child) {
//                                                   return value.loader_est_price ? Center(
//                                                       child:
//                                                       CircularProgressIndicator()) : value.estPriceModel!=null?
//                                                       value.estPriceModel!.estimatedRetailPrice!.isNotEmpty ?
//                                                       Column(
//                                                         crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                         children: [
//                                                           Text(
//                                                             'Estimated Retail Price',
//                                                             style: TextStyle(
//                                                                 fontSize:
//                                                                 14,
//                                                                 fontFamily:
//                                                                 fontSemibold,
//                                                                 color:
//                                                                 sh_colorPrimary2),
//                                                           ),
//                                                           SizedBox(
//                                                             height: 4,
//                                                           ),
//                                                           EstPrice(value.estPriceModel),
//                                                           SizedBox(
//                                                             height: 6,
//                                                           ),
//                                                         ],
//                                                       ) :Container():Container();
//                                                 }));
//
//                                               } else {
//                                                 return Container();
//                                               }
//                                             }
//                                             // By default, show a loading spinner.
//                                             return Center(
//                                                 child:
//                                                 CircularProgressIndicator());
//                                           })
//
//                                       // CheckVariant()
//                                     ],
//                                   ),
//
//                                   SizedBox(
//                                     height: 12,
//                                   ),
//                                   CheckVariant(),
//
//                                   // _availableSize(),
//                                   // SizedBox(
//                                   //   height: 20,
//                                   // ),
//                                   // _availableColor(),
//                                   SizedBox(
//                                     height: 8,
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       Text(
//                                         "Description",
//                                         maxLines: 2,
//                                         style: TextStyle(
//                                             color: sh_colorPrimary2,
//                                             fontFamily: fontSemibold,
//                                             fontSize: textSizeMedium),
//                                       ),
//                                       SizedBox(
//                                         height: 4,
//                                       ),
//                                       Html(
//                                         data:
//                                         product_pro.pro_det_model!.description,
//                                         style: {
//                                           "body": Style(
//                                               color: sh_black,
//                                               fontFamily: "Regular"),
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       InkWell(
//                                         onTap: () async {
//                                           SharedPreferences prefs = await SharedPreferences.getInstance();
//                                           String? UserId = prefs.getString('UserId');
//                                           String? token = prefs.getString('token');
//                                           if (UserId != null && UserId != '') {
//                                             _openCustomDialog2();
//                                           }else{
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) => LoginScreen(),
//                                               ),
//                                             );
//                                           }
//                                         },
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(4.0),
//                                           child: Image.asset(imgWarning2,height: 20,),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: 8,
//                                   ),
//                                   Container(
//                                     height: 0.5,
//                                     color: sh_app_txt_color,
//                                   ),
//                                   SizedBox(
//                                     height: 26,
//                                   ),
//                                   Consumer<ProductDetailProvider>(builder: ((context, value, child) {
//                                     return value.loader_seller_det ? CircularProgressIndicator() :
//                                     Container(
//                                       child: InkWell(
//                                         onTap: () async {
//                                           SharedPreferences prefs =
//                                           await SharedPreferences
//                                               .getInstance();
//                                           prefs.setString(
//                                               "seller_id",
//                                               value.productSellerModel!
//                                                   .seller!.sellerId
//                                                   .toString());
//                                           prefs.setString(
//                                               "seller_name",
//                                               value.productSellerModel!
//                                                   .seller!
//                                                   .nickname![0]
//                                                   .toString());
//                                           launchScreen(
//                                               context,
//                                               SellerProfileScreen
//                                                   .tag);
//                                         },
//                                         child: Column(
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                               MainAxisAlignment
//                                                   .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   "Seller",
//                                                   maxLines: 2,
//                                                   style: TextStyle(
//                                                       color:
//                                                       sh_colorPrimary2,
//                                                       fontFamily:
//                                                       fontSemibold,
//                                                       fontSize: 16),
//                                                 ),
//                                                 Row(
//                                                   children: <
//                                                       Widget>[
//                                                     Text(
//                                                       "View Profile",
//                                                       maxLines: 2,
//                                                       style: TextStyle(
//                                                           color:
//                                                           sh_black,
//                                                           fontFamily:
//                                                           fontSemibold,
//                                                           fontSize:
//                                                           14),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(
//                                               height: 6,
//                                             ),
//                                             Row(
//                                               children: [
//                                                 Padding(
//                                                     padding:
//                                                     const EdgeInsets
//                                                         .all(
//                                                         2.0),
//                                                     child: value.productSellerModel!
//                                                         .seller!
//                                                         .profile_picture ==
//                                                         null
//                                                         ? CircleAvatar(
//                                                       // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
//                                                       backgroundImage:
//                                                       NetworkImage("https://firebasestorage.googleapis.com/v0/b/sureloyalty-24e2a.appspot.com/o/nophoto.jpg?alt=media&token=cd6972d8-f794-4951-9c7a-b02cd2bc6366"),
//                                                       radius:
//                                                       22,
//                                                     )
//                                                         : CircleAvatar(
//                                                       // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
//                                                       backgroundImage: NetworkImage(value.productSellerModel!
//                                                           .seller!
//                                                           .profile_picture!),
//                                                       radius:
//                                                       22,
//                                                     )),
//                                                 // Icon(
//                                                 //   Icons.circle,
//                                                 //   color: sh_grey,
//                                                 //   size: 40,
//                                                 // ),
//                                                 SizedBox(
//                                                   width: 10,
//                                                 ),
//                                                 Text(
//                                                   value.productSellerModel!
//                                                       .seller!
//                                                       .nickname![
//                                                   0]!
//                                                       .toString(),
//                                                   maxLines: 2,
//                                                   style: TextStyle(
//                                                       color:
//                                                       sh_colorPrimary2,
//                                                       fontFamily:
//                                                       fontSemibold,
//                                                       fontSize: 14),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   })),
//
//
//                                   SizedBox(
//                                     height: 36,
//                                   ),
//                                   InkWell(
//                                     onTap: () async {
//                                       SharedPreferences prefs = await SharedPreferences.getInstance();
//                                       String? UserId = prefs.getString('UserId');
//                                       String? token = prefs.getString('token');
//                                       if (UserId != null && UserId != '') {
//                                         prefs.setString("variant_id", "");
//                                         _insert();
//                                         Provider.of<ProductDetailProvider>(context, listen: false).incrementCounter(product_pro.ct_changel);
//
//                                         AddCart();
//                                         // product_pro.ct_changel = true;
//                                         cart_count == 1;
//
//                                         // product_pro.in();
//                                       }else{
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => LoginScreen(),
//                                           ),
//                                         );
//                                       }
//
//                                     },
//                                     child: Container(
//                                       width: MediaQuery.of(context)
//                                           .size
//                                           .width,
//                                       padding: EdgeInsets.only(
//                                           top: spacing_middle,
//                                           bottom: spacing_middle),
//                                       decoration: boxDecoration(
//                                           bgColor: sh_app_background,
//                                           radius: 10,
//                                           showShadow: true),
//                                       child: text("Add to Cart",
//                                           textColor: sh_app_txt_color,
//                                           isCentered: true,
//                                           fontFamily: 'Bold'),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 18,
//                                   ),
//                                 ],
//                               ),
// //                        _detailWidget()
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Expanded(
//                 //   flex: 1,
//                 //   child: bottomButtons(sh_white),
//                 // )
//               ],
//             ),
//           ),
//         ),
//
//         SuccesVisiblity(),
//
//         // Positioned to take only AppBar size
//         Positioned(
//           top: 0.0,
//           left: 0.0,
//           right: 0.0,
//           child: Container(
//             padding: const EdgeInsets.fromLTRB(10, 18, 16, 0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(1.0, 0, 6, 0),
//                       child: IconButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           icon: Icon(
//                             Icons.chevron_left_rounded,
//                             color: Colors.white,
//                             size: 30,
//                           )),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 6.0, 6, 6),
//                       child: Text(
//                         "Product Details",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontFamily: 'TitleCursive'),
//                       ),
//                     )
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () async {
//                         SharedPreferences prefs = await SharedPreferences.getInstance();
//                         String? UserId = prefs.getString('UserId');
//                         String? token = prefs.getString('token');
//                         if (UserId != null && UserId != '') {
//                           prefs.setInt("shiping_index", -2);
//                           prefs.setInt("payment_index", -2);
//                           // launchScreen(context, CartScreen.tag);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => CartScreen()),
//                           ).then((value) {
//                             setState(() {
//                               // refresh state
//                             });
//                           });
//                         }else{
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => LoginScreen(),
//                             ),
//                           );
//                         }
//
//
//                       },
//                       child: FutureBuilder<String?>(
//                         future: fetchtotal(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return BadgeCount();
//                           } else if (snapshot.hasError) {
//                             return Text("${snapshot.error}");
//                           }
//                           // By default, show a loading spinner.
//                           return CircularProgressIndicator();
//                         },
//                       ),
//                     ),
//                     // SizedBox(
//                     //   width: 16,
//                     // )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ]);
//     }
//
//     return Scaffold(
//       body: WillPopScope(
//           onWillPop: _onWillPop,
//           child: StreamProvider<NetworkStatus>(
//             initialData: NetworkStatus.Online,
//             create: (context) =>
//                 NetworkStatusService().networkStatusController.stream,
//             child: NetworkAwareWidget(
//               onlineChild: SafeArea(child: setUserForm()),
//               offlineChild: Container(
//                 child: Center(
//                   child: Text(
//                     "No internet connection!",
//                     style: TextStyle(
//                         color: Colors.grey[400],
//                         fontWeight: FontWeight.w600,
//                         fontSize: 20.0),
//                   ),
//                 ),
//               ),
//             ),
//           )),
//     );
//   }
// }
//
// Widget _icon(IconData icon,
//     {Color color = iconColor,
//     double size = 20,
//     double padding = 10,
//     bool isOutLine = false}) {
//   return Container(
//     height: 40,
//     width: 40,
//     padding: EdgeInsets.all(padding),
//     // margin: EdgeInsets.all(padding),
//     decoration: BoxDecoration(
//       border: Border.all(
//           color: iconColor,
//           style: isOutLine ? BorderStyle.solid : BorderStyle.none),
//       borderRadius: BorderRadius.all(Radius.circular(30)),
//       color: sh_dots_color,
//     ),
//     child: Icon(icon, color: color, size: size),
//   );
// }
//
// /// An indicator showing the currently selected page of a PageController
// class DotsIndicator extends AnimatedWidget {
//   final PageController? controller;
//
//   /// The number of items managed by the PageController
//   final int? itemCount;
//
//   /// Called when a dot is tapped
//   final ValueChanged<int>? onPageSelected;
//
//   /// The color of the dots.
//   ///
//   /// Defaults to `Colors.white`.
//   final Color? color;
//
//   // The base size of the dots
//   static const double? _kDotSize = 8.0;
//
//   // The increase in the size of the selected dot
//   static const double? _kMaxZoom = 1.8;
//
//   // The distance between the center of each dot
//   static const double? _kDotSpacing = 20.0;
//
//   DotsIndicator({
//     this.controller,
//     this.itemCount,
//     this.onPageSelected,
//     this.color: sh_colorPrimary2,
//   }) : super(listenable: controller!);
//
//   /// The PageController that this DotsIndicator is representing.
//
//   Widget _buildDot(int index) {
//     double selectedness = Curves.easeOut.transform(
//       max(
//         0.0,
//         1.0 - ((controller!.page ?? controller!.initialPage) - index).abs(),
//       ),
//     );
//     double zoom = 1.0 + (_kMaxZoom! - 1.0) * selectedness;
//     return new Container(
//       width: _kDotSpacing,
//       child: new Center(
//         child: new Material(
//           color: color,
//           type: MaterialType.circle,
//           child: new Container(
//             width: _kDotSize! * zoom,
//             height: _kDotSize! * zoom,
//             child: new InkWell(
//               onTap: () => onPageSelected!(index),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget build(BuildContext context) {
//     return new Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: new List<Widget>.generate(itemCount!, _buildDot),
//     );
//   }
// }
//
// class groceryButton extends StatefulWidget {
//   groceryButton();
//
//   @override
//   groceryButtonState createState() => groceryButtonState();
// }
//
// class groceryButtonState extends State<groceryButton> {
//   bool ch = false;
//
//   @override
//   void initState() {
//     Timer(Duration(milliseconds: 1500), () {
//       setState(() {
//         ch = true;
//       });
//     });
//     super.initState();
// //    mListings2 = getPopular();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (ch) {
//       return InkWell(
//         onTap: () async {
//           Navigator.of(context).pop(ConfirmAction.CANCEL);
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setInt("shiping_index", -2);
//           prefs.setInt("payment_index", -2);
//           // launchScreen(context, CartScreen.tag);
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => CartScreen()),
//           ).then((value) {
//             setState(() {
//               // refresh state
//             });
//           });
//           //   Navigator.pushReplacement(
//           // context,
//           // MaterialPageRoute(
//           //   builder: (context) => CartScreen(),
//           // ),
//           // );
//         },
//         child: Container(
//           padding: EdgeInsets.all(spacing_standard),
//           decoration: boxDecoration(
//               bgColor: sh_colorPrimary2, radius: 6, showShadow: true),
//           child: text("Cart/Checkout",
//               textColor: sh_white,
//               isCentered: true,
//               fontSize: 12.0,
//               fontFamily: 'Bold'),
//         ),
//       );
//     } else {
//       return Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         direction: ShimmerDirection.ltr,
//         child: Container(
//           padding: EdgeInsets.all(spacing_standard),
//           decoration: boxDecoration(
//               bgColor: sh_colorPrimary2, radius: 6, showShadow: true),
//           child: text("Cart/Checkout",
//               textColor: sh_white,
//               isCentered: true,
//               fontSize: 12.0,
//               fontFamily: 'Bold'),
//         ),
//       );
//     }
//   }
// }
