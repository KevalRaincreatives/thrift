import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/ReportProductModel.dart';
import 'package:thrift/model/ProductListSellerModel.dart';
import 'package:thrift/model/ReviewModel.dart';
import 'package:thrift/provider/seller_profile_provider.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/ProductDetailScreen.dart';
import 'package:thrift/screens/SellerReviewScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:thrift/model/BlockProductModel.dart';

import '../provider/profile_provider.dart';


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
  String? seller_name,seller_id,profile_name;
  // ReviewModel? reviewModel;

  int? cart_count;
  String? seller_pic;
  Future<String?>? fetchPicMain;
  Future<String?>? fetchaddMain;
  // Future<ReviewModel?>? fetchREviewMain;
  ReportProductModel? reportProductModel;
  BlockProductModel? blockProductModel;

  @override
  void initState() {
    super.initState();
    fetchPicMain=fetchPic();
    fetchaddMain=fetchadd();
    // fetchREviewMain=fetchREview();

    final pro_provider = Provider.of<ProfileProvider>(context, listen: false);
    pro_provider.getReview();


    final seller_pro_provider = Provider.of<SellerProfileProvider>(context, listen: false);
    seller_pro_provider.getSellerProductList();
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

  Future<ReportProductModel?> reportSeller(String reason) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      seller_name = prefs.getString('seller_name');
      seller_id = prefs.getString('seller_id');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode(
          {"vendor_name": seller_name, "vendor_id": seller_id, "reason": reason});
      print(msg);

      var response = await http.post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/report_vendor'),
          body: msg,
          headers: headers);

      final jsonResponse = json.decode(response.body);
      print('SellerProfileScreen report_vendor Response status2: ${response.statusCode}');
      print('SellerProfileScreen report_vendor Response body2: ${response.body}');
      reportProductModel = new ReportProductModel.fromJson(jsonResponse);
      EasyLoading.dismiss();
      if(reportProductModel!.response!.success!) {
        Navigator.of(context, rootNavigator: true).pop();
        _openCustomDialog4();
      }else{
        toast(reportProductModel!.response!.msg!);
      }

      return reportProductModel;
    }  on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }

  Future<BlockProductModel?> reportBlock() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      seller_name = prefs.getString('seller_name');
      seller_id = prefs.getString('seller_id');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode(
          {"user_id": UserId, "vendor_id": seller_id});
      print(msg);

      var response = await http.post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/block_vendor'),
          body: msg,
          headers: headers);

      final jsonResponse = json.decode(response.body);
      print('SellerProfileScreen block_vendor Response status2: ${response.statusCode}');
      print('SellerProfileScreen block_vendor Response body2: ${response.body}');
      blockProductModel = new BlockProductModel.fromJson(jsonResponse);
      EasyLoading.dismiss();

      if(blockProductModel!.success!) {
        Navigator.of(context, rootNavigator: true).pop();
        _openCustomDialog5();
      }else{
        toast(blockProductModel!.error!);
      }

      return blockProductModel;
    }
    on Exception catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }

  void _openCustomDialog4() {
    showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Center(child: Text('Your report has been successfully submitted',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8,),
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
                        child: text("Close",
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
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  void _openCustomDialog5() {
    showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: const Center(child: Text('Vendor Block Successfully!',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8,),
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
                        child: text("Close",
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
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

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

    Imagevw4(int index,productListSellerModel) {
      if (productListSellerModel!.products![index]!.data!.images!.length < 1) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Image.asset(
            sh_no_img,
            fit: BoxFit.cover,
            height: 130,
            width: MediaQuery.of(context).size.width,


          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: CachedNetworkImage(
            imageUrl:
            productListSellerModel!.products![index]!.data!.images![0]!.src!,
            fit: BoxFit.cover,
            height: 130,
            width: width,
            // memCacheWidth: width,
            filterQuality: FilterQuality.low,
            placeholder: (context, url) => Center(
              child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => new Icon(Icons.error),
          )
        );
      }
    }

    NewImagevw(int index,productListSellerModel) {
      return Imagevw4(index,productListSellerModel);
    }

    MyPrice(int index,productListSellerModel){
      var myprice2,myprice;
      if(productListSellerModel!.products![index]!.data!.price==''){
        myprice='0.00';
      }else {
        myprice2 = double.parse(productListSellerModel!.products![index]!.data!.price!);
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

    void _openCustomDialog2() {
      var reasonCont = TextEditingController();
      showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Center(child: Text('Do you want to report this seller $seller_name?',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8,),

                      Center(child: Text('Why are you Reporting?',style: TextStyle(color: sh_colorPrimary2,fontSize: 15,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
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
                          controller: reasonCont,
                          decoration: InputDecoration(
                            filled: true,
                            hintMaxLines: 5,
                            fillColor: sh_text_back,
                            contentPadding:
                            EdgeInsets.fromLTRB(16, 16, 16, 16),
                            hintText: "Type Report",
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
                      InkWell(
                        onTap: () async {
                          reportSeller(reasonCont.text);


                          // Navigator.of(context, rootNavigator: true).pop();
                          //
                          // _openCustomDialog4();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*.7,
                          padding: EdgeInsets.only(
                              top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2, radius: 10, showShadow: true),
                          child: text("Report",
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
          barrierDismissible: false,
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Container();
          });
    }

    void _openCustomDialog3() {
      var reasonCont = TextEditingController();
      showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Center(child: Text('Do you want to block this User?',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      SizedBox(height: 16,),
                      InkWell(
                        onTap: () async {
                          reportBlock();

                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*.7,
                          padding: EdgeInsets.only(
                              top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2, radius: 10, showShadow: true),
                          child: text("Yes,Block!",
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
          barrierDismissible: false,
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Container();
          });
    }

    void _openCustomDialog6() {
      showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  // title: Center(child: Text('Your report has been successfully submitted',style: TextStyle(color: sh_colorPrimary2,fontSize: 18,fontFamily: 'Bold'),textAlign: TextAlign.center,)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 14.0,
                            backgroundColor: sh_app_black,
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String? UserId = prefs.getString('UserId');
                          String? token = prefs.getString('token');
                          if (UserId != null && UserId != '') {
                            _openCustomDialog2();
                          }else{
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          }
                          // _openCustomDialog2();
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              8,8,6,8),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2, radius: 4, showShadow: true),
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              text("Report User",
                                  fontSize: 14.0,
                                  textColor: sh_white,
                                  isCentered: true,
                                  fontFamily: 'Bold'),
                              Image.asset(sh_report_pro,height: 12,width: 12,fit: BoxFit.fill,)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),
                      InkWell(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String? UserId = prefs.getString('UserId');
                          String? token = prefs.getString('token');
                          if (UserId != null && UserId != '') {
                            _openCustomDialog3();
                          }else{
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          }
                          // _openCustomDialog3();
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              8,8,6,8),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2, radius: 4, showShadow: true),
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              text("Block User",
                                  fontSize: 14.0,
                                  textColor: sh_white,
                                  isCentered: true,
                                  fontFamily: 'Bold'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 200),
          barrierDismissible: false,
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Container();
          });
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
            margin: EdgeInsets.fromLTRB(26,0,26,0),
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
                Consumer<ProfileProvider>(builder: ((context, value, child) {
                  return value.loader_review
                      ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    direction: ShimmerDirection.ltr,
                    child: Container(
                      width: width,
                      padding: EdgeInsets.fromLTRB(1, 12, 1, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      1.0, 12, 1, 12),
                                  child: Container(
                                    width: width * .3,
                                    height: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      1.0, 12, 1, 12),
                                  child: Container(
                                    width: width * .3,
                                    height: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  )
                      : InkWell(
                    onTap: () {
                      launchScreen(context, SellerReviewScreen.tag);
                    },
                    child: Column(
                      children: [
                        Text(
                          "User Rating",
                          style: TextStyle(
                              color: sh_colorPrimary2,
                              fontSize: 13,
                              fontFamily: fontMedium),
                        ),
                        RatingBar.builder(
                          initialRating: double.parse(
                              value.reviewModel!.average.toString()),
                          minRating: 1,
                          itemSize: 16,
                          ignoreGestures: true,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          unratedColor: sh_rating_unrated,
                          itemPadding:
                          EdgeInsets.symmetric(horizontal: 4.0),
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
                })),
                SizedBox(
                  height: 20,
                ),
                Container(height: .5,color: sh_colorPrimary2,),
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Listing",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: fontSemibold),),
                    InkWell(
                      onTap: (){
                        _openCustomDialog6();
                      },
                        child: Image.asset(imgWarning2,height: 20,)),
                  ],
                ),
                SizedBox(height: 16,),
                Row(
      children: [
      Image.asset(
      sh_menu_filter,
      color: sh_colorPrimary2,
      height: 22,
      width: 16,
      fit: BoxFit.fill,
      ),
      SizedBox(width: 12,),
      Text("Newest to Oldest",style: TextStyle(color: sh_colorPrimary2,fontSize: 13),)
      ],
      ),
                SizedBox(height: 6,),
                Consumer<SellerProfileProvider>(builder: ((context, value, child) {
                  return value.loader_seller ? Expanded(
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
                  ) :
                  Expanded(
                    child: AnimationLimiter(
                      child: GridView.count(
                        physics: AlwaysScrollableScrollPhysics(),
                        childAspectRatio: 0.75,
                        crossAxisCount: 2,
                        crossAxisSpacing: 30.0,
                        mainAxisSpacing: 10.0,

                        children: List.generate(
                          value.productListSellerModel!.products!.length,
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
                                      prefs.setString('pro_id', value.productListSellerModel!.products![index]!.data!.id.toString());
                                      List<String> myimages = [];
                                      for (var i = 0;
                                      value.productListSellerModel!.products![index]!.data!.images!.length > i;
                                      i++) {
                                        myimages.add(
                                            value.productListSellerModel!.products![index]!.data!.images![i]!.src!);
                                      }
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ProductDetailScreen(proName: value.productListSellerModel!.products![index]!.data!.name,proPrice: value.productListSellerModel!.products![index]!.data!.price,proImage: myimages,)));
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
                                          NewImagevw(index,value.productListSellerModel),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: spacing_standard, right: spacing_standard),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Html(
                                                  data: value.productListSellerModel!.products![index]!.data!.name!,
                                                  style: {
                                                    "body": Style(
                                                      maxLines: 1,
                                                      margin: EdgeInsets.zero, padding: EdgeInsets.zero,
                                                      fontSize: FontSize(16.0),
                                                      fontWeight: FontWeight.bold,
                                                      color: sh_black,
                                                      fontFamily: fontBold,
                                                    ),
                                                  },
                                                ),
                                                // Text(
                                                //   value.productListSellerModel!.products![index]!.data!.name!,
                                                //   maxLines: 1,
                                                //   style: TextStyle(
                                                //       color: sh_black,
                                                //       fontFamily: fontBold,
                                                //       fontSize: textSizeMedium),
                                                // ),
                                                SizedBox(
                                                  height: 2,
                                                ),


                                                MyPrice(index,value.productListSellerModel),

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
                })),

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
                      child: FutureBuilder<String?>(
                        future: fetchadd(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(profile_name!,style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'));
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
                        String? UserId = prefs.getString('UserId');
                        String? token = prefs.getString('token');
                        if (UserId != null && UserId != '') {
                          prefs.setInt("shiping_index", -2);
                          prefs.setInt("payment_index", -2);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CartScreen()),).then((value) {   setState(() {
                            // refresh state
                          });});
                        }else{
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        }

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
      resizeToAvoidBottomInset: false,
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
