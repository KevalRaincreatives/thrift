import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/ReviewModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/utils/ShStrings.dart';
import 'package:intl/intl.dart';

class SellerReviewScreen extends StatefulWidget {
  static String tag='/SellerReviewScreen';
  const SellerReviewScreen({Key? key}) : super(key: key);

  @override
  _SellerReviewScreenState createState() => _SellerReviewScreenState();
}

class _SellerReviewScreenState extends State<SellerReviewScreen> {
  ReviewModel? reviewModel;
  Future<ReviewModel?>? fetchAlbumMain;

  @override
  void initState() {
    super.initState();
    fetchAlbumMain=fetchAlbum();

  }

  Future<ReviewModel?> fetchAlbum() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? seller_id = prefs.getString('seller_id');
      // toast(cat_id);

      var response;
        response = await http.get(Uri.parse(
            "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/seller_reviews?seller_id=$seller_id"));
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      // for (Map i in jsonResponse) {
      //
      //     // reviewModel.add(ReviewModel.fromJson(i));
       reviewModel = new ReviewModel.fromJson(jsonResponse);
//       }


      return reviewModel;
    } catch (e) {
//      return orderListModel;
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

    BadgeCount(){
      if(cart_count==0){
        return Image.asset(
          sh_new_cart,
          height: 50,
          width: 50,
          fit: BoxFit.fill,
          color: sh_white,
        );
      }else{
        return Badge(
          position: BadgePosition.topEnd(top: 4, end: 6),
          badgeContent: Text(cart_count.toString(),style: TextStyle(color: sh_white),),
          child: Image.asset(
            sh_new_cart,
            height: 50,
            width: 50,
            fit: BoxFit.fill,
            color: sh_white,
          ),
        );
      }
    }

    ReviewDate(int index){
      var inputFormat = DateFormat("yyyy-MM-dd");
      String date1 = inputFormat.parse(
          reviewModel!.reviews!.data![index]!.dateCreated!.substring(0, 10)).toString();
      DateTime dateTime = DateTime.parse(date1);
      var outputFormat = DateFormat.yMMMMd('en_US').format(dateTime);

      String date2 = outputFormat.toString();
      return text(date2, fontSize: textSizeSMedium);
    }


    Widget reviews() {
      if(reviewModel!.reviews!.data!.length == 0){
        return Container(
          height: height-130,
          alignment: Alignment.center,
          child: Center(
            child: Text(
              'No Review Found',
              style: TextStyle(
                  fontSize: 20,
                  color: sh_colorPrimary2,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      }else {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: reviewModel!.reviews!.data!.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(18.0),
              margin: EdgeInsets.only(bottom: spacing_standard_new),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding:
                        EdgeInsets.only(left: 12, right: 12, top: 1, bottom: 1),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(spacing_standard_new)),
                            color: reviewModel!.reviews!.data![index]!.rating! <
                                2
                                ? Colors.red
                                : reviewModel!.reviews!.data![index]!.rating! <
                                4
                                ? Colors.orange
                                : Colors.green),
                        child: Row(
                          children: <Widget>[
                            text(reviewModel!.reviews!.data![index]!.rating
                                .toString(),
                                textColor: sh_white, fontSize: 14.0),
                            SizedBox(width: spacing_control_half),
                            Icon(Icons.star, color: sh_white, size: 12)
                          ],
                        ),
                      ),
                      SizedBox(width: spacing_standard_new),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            text(reviewModel!.reviews!.data![index]!.reviewer,
                                textColor: sh_colorPrimary2,
                                fontSize: textSizeMedium,
                                fontFamily: fontMedium),
                            Html(
                              data: reviewModel!.reviews!.data![index]!.review,
                              style: {
                                "body": Style(color: sh_black),
                              },
                            )
                            // text(reviewModel!.reviews!.data![index]!.review, fontSize: textSizeMedium),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: spacing_standard),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(4),
                            margin: EdgeInsets.only(right: spacing_standard),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: reviewModel!.reviews!.data![index]!
                                    .verified!
                                    ? Colors.green
                                    : Colors.grey.withOpacity(0.5)),
                            child: Icon(
                                reviewModel!.reviews!.data![index]!.verified!
                                    ? Icons.done
                                    : Icons.clear,
                                color: sh_white,
                                size: 12),
                          ),
                          text(
                              reviewModel!.reviews!.data![index]!.verified!
                                  ? sh_lbl_verified
                                  : sh_lbl_not_verified,
                              textColor: sh_textColorPrimary,
                              fontFamily: fontMedium,
                              fontSize: textSizeSMedium)
                        ],
                      ),
                      ReviewDate(index)
                    ],
                  )
                ],
              ),
            );
          },
        );
      }
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Customer Support",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
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
            child: Image.asset(sh_upper2,fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Container(
          height: height,
          width: width,
          color: sh_white,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          child:   Container(
            height: height,
            width: width,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // TopBar(t1_Listing),
                  FutureBuilder<ReviewModel?>(
                    future: fetchAlbumMain,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return reviews();
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),

                  Container(
                    height: 16,
                  )
                ],
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
                      child: Text("All Reviews",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Cursive'),),
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
                    SizedBox(width: 16,)
                  ],
                ),
              ],
            ),
          ),
        ),

      ]);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: setUserForm(),
      ),
    );
  }
}
