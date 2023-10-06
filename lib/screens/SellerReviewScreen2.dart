// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:thrift/model/ReviewModel.dart';
// import 'package:thrift/screens/CartScreen.dart';
// import 'package:thrift/utils/ShColors.dart';
// import 'package:thrift/utils/ShConstant.dart';
// import 'package:thrift/utils/ShExtension.dart';
// import 'package:http/http.dart' as http;
// import 'package:thrift/utils/ShStrings.dart';
//
// class SellerReviewScreen extends StatefulWidget {
//   static String tag='/SellerReviewScreen';
//   const SellerReviewScreen({Key? key}) : super(key: key);
//
//   @override
//   _SellerReviewScreenState createState() => _SellerReviewScreenState();
// }
//
// class _SellerReviewScreenState extends State<SellerReviewScreen> {
//   List<ReviewModel> reviewModel = [];
//
//   Future<List<ReviewModel>?> fetchAlbum() async {
//     try {
// //      prefs = await SharedPreferences.getInstance();
// //      String UserId = prefs.getString('UserId');
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? cat_id = prefs.getString('cat_id');
//       String? user_country = prefs.getString('user_selected_country');
//       // toast(cat_id);
//
//
//
//       var response;
//         response = await http.get(Uri.parse(
//             "${Url.BASE_URL}wp-json/wc/v3/products/reviews?product=2879&per_page=100"));
//       print('Response status2: ${response.statusCode}');
//       print('Response body2: ${response.body}');
//       reviewModel.clear();
//       final jsonResponse = json.decode(response.body);
//       for (Map i in jsonResponse) {
//
//           reviewModel.add(ReviewModel.fromJson(i));
// //        orderListModel = new OrderListModel2.fromJson(i);
//       }
//
//
//       return reviewModel;
//     } catch (e) {
// //      return orderListModel;
//       print('caught error $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//
//
//     Widget reviews() {
//       return ListView.builder(
//         scrollDirection: Axis.vertical,
//         itemCount: reviewModel.length,
//         shrinkWrap: true,
//         physics: NeverScrollableScrollPhysics(),
//         itemBuilder: (context, index) {
//           return Container(
//             padding: EdgeInsets.all(18.0),
//             margin: EdgeInsets.only(bottom: spacing_standard_new),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Container(
//                       padding:
//                       EdgeInsets.only(left: 12, right: 12, top: 1, bottom: 1),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.all(
//                               Radius.circular(spacing_standard_new)),
//                           color: reviewModel[index].rating! < 2
//                               ? Colors.red
//                               : reviewModel[index].rating! < 4
//                               ? Colors.orange
//                               : Colors.green),
//                       child: Row(
//                         children: <Widget>[
//                           text(reviewModel[index].rating.toString(),
//                               textColor: sh_white),
//                           SizedBox(width: spacing_control_half),
//                           Icon(Icons.star, color: sh_white, size: 12)
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: spacing_standard_new),
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           text(reviewModel[index].reviewer,
//                               textColor: sh_colorPrimary2,
//                               fontSize: textSizeMedium,
//                               fontFamily: fontMedium),
//                           text(reviewModel[index].review, fontSize: textSizeMedium),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//                 SizedBox(height: spacing_standard),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     Row(
//                       children: <Widget>[
//                         Container(
//                           padding: EdgeInsets.all(4),
//                           margin: EdgeInsets.only(right: spacing_standard),
//                           decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: reviewModel[index].verified!
//                                   ? Colors.green
//                                   : Colors.grey.withOpacity(0.5)),
//                           child: Icon(
//                               reviewModel[index].verified! ? Icons.done : Icons.clear,
//                               color: sh_white,
//                               size: 12),
//                         ),
//                         text(
//                             reviewModel[index].verified!
//                                 ? sh_lbl_verified
//                                 : sh_lbl_not_verified,
//                             textColor: sh_textColorPrimary,
//                             fontFamily: fontMedium,
//                             fontSize: textSizeSMedium)
//                       ],
//                     ),
//                     text("23 Feb 2022", fontSize: textSizeSMedium)
//                   ],
//                 )
//               ],
//             ),
//           );
//         },
//       );
//     }
//
//     Widget setUserForm() {
//       AppBar appBar = AppBar(
//         elevation: 0,
//         backgroundColor: sh_colorPrimary2,
//         title: Text(
//           "Customer Support",
//           style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
//         ),
//         iconTheme: IconThemeData(color: sh_white),
//         actions: <Widget>[
//           GestureDetector(
//             onTap: () {
//               launchScreen(context, CartScreen.tag);
//             },
//             child: Image.asset(
//               sh_new_cart,
//               height: 50,
//               width: 50,
//               color: sh_white,
//             ),
//
//           ),
//           SizedBox(
//             width: 22,
//           ),
//         ],
//       );
//       double app_height = appBar.preferredSize.height;
//       return Stack(children: <Widget>[
//         // Background with gradient
//         Container(
//             height: 120,
//             width: width,
//             child: Image.asset(sh_upper2,fit: BoxFit.fill)
//           // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
//         ),
//         //Above card
//
//         Container(
//           height: height,
//           width: width,
//           color: sh_white,
//           margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
//           child:   Container(
//             height: height,
//             width: width,
//             child: SingleChildScrollView(
//               child: Column(
//                 children: <Widget>[
//                   // TopBar(t1_Listing),
//                   FutureBuilder<List<ReviewModel>?>(
//                     future: fetchAlbum(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData) {
//                         return reviews();
//                       }
//                       return Center(child: CircularProgressIndicator());
//                     },
//                   ),
//
//                   Container(
//                     height: 16,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//         // Positioned to take only AppBar size
//         Positioned(
//           top: 0.0,
//           left: 0.0,
//           right: 0.0,
//           child: Container(
//             padding: const EdgeInsets.fromLTRB(0,spacing_middle4,0,0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(6.0,2,6,2),
//                       child: IconButton(onPressed: () {
//                         Navigator.pop(context);
//                       }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 36,)),
//                     ),
//
//                     Padding(
//                       padding: const EdgeInsets.all(6.0),
//                       child: Text("All Reviews",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Cursive'),),
//                     )
//                   ],
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     launchScreen(context, CartScreen.tag);
//                   },
//                   child: Container(
//                     padding: EdgeInsets.fromLTRB(4, 0, 20, 0),
//                     child: Image.asset(
//                       sh_new_cart,
//                       height: 50,
//                       width: 50,
//                       color: sh_white,
//                     ),
//                   ),
//
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//       ]);
//     }
//
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: SafeArea(
//         child: setUserForm(),
//       ),
//     );
//   }
// }
