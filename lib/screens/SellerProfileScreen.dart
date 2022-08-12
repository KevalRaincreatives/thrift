import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:thrift/model/ProductListSellerModel.dart';
import 'package:thrift/model/ReviewModel.dart';
import 'package:thrift/screens/CartScreen2.dart';
import 'package:thrift/screens/ProductDetailScreen.dart';
import 'package:thrift/screens/SellerReviewScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;

class SellerProfileScreen extends StatefulWidget {
  static String tag = '/SellerProfileScreen';

  const SellerProfileScreen({Key? key}) : super(key: key);

  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final double runSpacing = 4;
  final double spacing = 4;
  final columns = 2;
  ProductListSellerModel? productListModel;
  String? seller_name,seller_id,profile_name;
  ReviewModel? reviewModel;

  int? cart_count;
  String? seller_pic;
  Future<String?>? fetchPicMain;
  Future<String?>? fetchaddMain;
  Future<ReviewModel?>? fetchREviewMain;

  @override
  void initState() {
    super.initState();
    fetchPicMain=fetchPic();
    fetchaddMain=fetchadd();
    fetchREviewMain=fetchREview();

  }

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

  Future<String?> fetchPic() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(prefs.getString('seller_pic')!=null){
        seller_pic = prefs.getString('seller_pic');
      }else{
        seller_pic = "https://firebasestorage.googleapis.com/v0/b/sureloyalty-24e2a.appspot.com/o/nophoto.jpg?alt=media&token=cd6972d8-f794-4951-9c7a-b02cd2bc6366";
      }

      return '';
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<ReviewModel?> fetchREview() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? seller_id = prefs.getString('seller_id');

      // toast(cat_id);

      var response;
      response = await http.get(Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/seller_reviews?seller_id=$seller_id"));
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

  Future<ProductListSellerModel?> fetchAlbum() async {
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
      SharedPreferences prefs = await SharedPreferences.getInstance();
        seller_id = prefs.getString('seller_id');
      // toast(seller_id);

      var response = await http.get(
          Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/seller_products_customers?seller_id=$seller_id"));

      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      productListModel = new ProductListSellerModel.fromJson(jsonResponse);

      return productListModel;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }

  Future<String?> fetchadd() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      seller_name = prefs.getString('seller_name');
      seller_id = prefs.getString('seller_id');
      profile_name=prefs.getString("profile_name");
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

    Imagevw4(int index) {
      if (productListModel!.products![index]!.data!.images!.length < 1) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            sh_no_img,
            fit: BoxFit.cover,
            height: 130,
            width: MediaQuery.of(context).size.width,


          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            productListModel!.products![index]!.data!.images![0]!.src!,
            fit: BoxFit.cover ,
            height: 130,
            width: width,

          ),
        );
      }
    }

    NewImagevw(int index) {
      return Imagevw4(index);
    }

    MyPrice(int index){
      var myprice2,myprice;
      if(productListModel!.products![index]!.data!.price==''){
        myprice='0.00';
      }else {
        myprice2 = double.parse(productListModel!.products![index]!.data!.price!);
        myprice = myprice2.toStringAsFixed(2);
      }
      return Row(
        children: [
          Text(
            "\$" + myprice,
            style: TextStyle(
                color: sh_black,
                fontFamily: 'Medium',
                fontSize: textSizeSMedium),
          ),

        ],
      );
    }


    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "TheBuyerman2022",
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
          color: sh_white,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          child: Container(
            height: height,
            width: width,
            margin: EdgeInsets.fromLTRB(16,0,16,0),
            child: Column(
              children: [
                FutureBuilder<String?>(
                  future: fetchPicMain,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(seller_pic!),
                        radius: 50,
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                ),

                SizedBox(
                  height: 10,
                ),
                FutureBuilder<String?>(
                  future: fetchaddMain,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        seller_name!,
                        style: TextStyle(
                            color: sh_colorPrimary2,
                            fontSize: 16,
                            fontFamily: "Bold"),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                FutureBuilder<ReviewModel?>(
                  future: fetchREviewMain,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return InkWell(
                        onTap: () {
                          launchScreen(context, SellerReviewScreen.tag);
                        },
                        child: Column(
                          children: [
                            Text(
                              "User Rating",
                              style: TextStyle(
                                  color: sh_colorPrimary2,
                                  fontSize: 14,
                                  fontFamily: "Bold"),
                            ),
                            RatingBar.builder(
                              initialRating: double.parse(reviewModel!.average.toString()),
                              minRating: 1,
                              itemSize: 18,
                              ignoreGestures: true,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              unratedColor: sh_rating_unrated,
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: sh_rating,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      direction: ShimmerDirection.ltr,
                      child: Container(
                        width: width,
                        padding: EdgeInsets.fromLTRB(1,12,1,12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        1.0, 12, 1, 12),
                                    child:                             Container(
                                      width: width*.3,
                                      height: 12.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                            SizedBox(height: 10,),
                            Container(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        1.0, 12, 1, 12),
                                    child:                             Container(
                                      width: width*.3,
                                      height: 12.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ],
                        ),

                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 26,
                ),
                Container(height: .5,color: sh_colorPrimary2,),
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Listing",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: "Bold"),),
                  ],
                ),
                SizedBox(height: 16,),
                Row(
                  children: [
                    Container(

                      child: SvgPicture.asset(sh_menu_filter,color: sh_colorPrimary2,),
                      height :40,
                      width: 40,),
                    Text("Newest to Oldest",style: TextStyle(color: sh_colorPrimary2,fontSize: 14),)
                  ],
                ),
                SizedBox(height: 16,),
                FutureBuilder<ProductListSellerModel?>(
                  future: fetchAlbum(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: AnimationLimiter(
                          child: GridView.count(
                            physics: AlwaysScrollableScrollPhysics(),
                            childAspectRatio: 0.75,
                            crossAxisCount: 2,
                            crossAxisSpacing: 30.0,
                            mainAxisSpacing: 15.0,

                            children: List.generate(
                              productListModel!.products!.length,
                                  (int index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  columnCount: 2,
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: InkWell(
                                        onTap: () async{
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          prefs.setString('pro_id', productListModel!.products![index]!.data!.id.toString());
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ProductDetailScreen()));
                                        },
                                        child: Container(
                                          decoration: boxDecoration4(showShadow: false),
                                          // margin: EdgeInsets.only(left: 16, bottom: 16),
                                          // padding: EdgeInsets.fromLTRB(spacing_standard,spacing_standard,spacing_standard,spacing_control_half),
                                          // padding:
                                          // EdgeInsets.fromLTRB(0, 0, 0, spacing_control_half),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              NewImagevw(index),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: spacing_standard, right: spacing_standard),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Hero(
                                                      tag: 'Pro_name',
                                                      child: Text(
                                                        productListModel!.products![index]!.data!.name!,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: sh_black,
                                                            fontFamily: fontBold,
                                                            fontSize: textSizeMedium),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),


                                                    MyPrice(index),

                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );


                    }
                    return Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        enabled: true,
                        child: ListView.builder(
                          itemBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 48.0,
                                  height: 48.0,
                                  color: Colors.white,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        height: 8.0,
                                        color: Colors.white,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 2.0),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 8.0,
                                        color: Colors.white,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 2.0),
                                      ),
                                      Container(
                                        width: 40.0,
                                        height: 8.0,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          itemCount: 6,
                        ),
                      ),
                    );
                  },
                ),
              ],
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
                      child: FutureBuilder<String?>(
                        future: fetchadd(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(profile_name!,style: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Regular'));
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          // By default, show a loading spinner.
                          return CircularProgressIndicator(

                          );
                        },
                      ),

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
