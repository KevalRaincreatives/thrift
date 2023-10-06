import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/CouponErrorModel.dart';
import 'package:thrift/model/CouponModel.dart';
import 'package:thrift/screens/OfferModel.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/api_service/Url.dart';
class OfferListScreen extends StatefulWidget {
  final int? cat_title;

  OfferListScreen({this.cat_title});

  @override
  _OfferListScreenState createState() => _OfferListScreenState();
}

class _OfferListScreenState extends State<OfferListScreen> {
  List<OfferModel> offerModel = [];
  CouponModel? couponModel;
  CouponErrorModel? couponErrorModel;

  Future<List<OfferModel>?> fetchOffer() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Response response = await get(
          Uri.parse('${Url.BASE_URL}wp-json/wc/v3/coupons'),
          headers: headers);

      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      // offerModel = new OfferModel.fromJson(jsonResponse);

      for (Map i in jsonResponse) {
        offerModel.add(OfferModel.fromJson(i));
//        orderListModel = new OrderListModel2.fromJson(i);
      }
      return offerModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<CouponModel?> getCoupon(String coupon) async {
    EasyLoading.show(status: 'Please wait...');

    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
//      print

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({"coupon_code": coupon});
      print(msg);

      Response response = await post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/apply_coupon'),
          headers: headers,
          body: msg);
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json coupon$jsonResponse');

      couponModel = new CouponModel.fromJson(jsonResponse);
      if (couponModel!.success!) {
        Navigator.pop(context, 0);
      } else {
        couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
        toast(couponErrorModel!.error!);
      }
      EasyLoading.dismiss();

      return couponModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;


    return Scaffold(

      resizeToAvoidBottomInset: false,
      backgroundColor: sh_white,
      appBar: AppBar(
        title: Text(
          'Offers',
          style: TextStyle(color: sh_textColorPrimary),
        ),
        backgroundColor: sh_app_bar,
        elevation: 0,
        iconTheme: IconThemeData(color: sh_black),
        actionsIconTheme: IconThemeData(color: sh_black),
      ),
      body: SingleChildScrollView(
        child: Container(
            width: width,
            height: height,
            padding: EdgeInsets.all(12),
            child: FutureBuilder<List<OfferModel>?>(
                future: fetchOffer(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: offerModel.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async{
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String? my_tot = prefs.getString('my_tot');
                            int mytots=double.parse(my_tot!).toInt();
                            print(mytots.toString());

                            // prefs.setString('order_id',
                            //     orderListModel!.data![index]!.ID!.toString());
                            // prefs.commit();
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             OrderDetailScreen()));
                            if(offerModel[index].discountType=='fixed_cart'){
                              int mytots2=double.parse(offerModel[index].amount!).toInt();
                              print(mytots2.toString());
                              if(mytots>mytots2){
                                // toast(mytots2.toString());
                                getCoupon(offerModel[index].code!);
                              }else{
                                toast('Valid on minimum transaction value of $mytots2');
                              }

                            }else {
                              getCoupon(offerModel[index].code!);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10,10,10,10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                DottedBorder(
                                  color: sh_colorPrimary,
                                  strokeWidth: 2,
                                  padding: EdgeInsets.all(spacing_control_half),
                                  radius: Radius.circular(20),
                                  child: ClipRRect(
                                    //borderRadius: BorderRadius.all(Radius.circular(spacing_middle)),
                                    child: Container(
                                      width: width * 0.3,
                                      color: sh_white,
                                      child: text(offerModel[index].code, textColor: sh_colorPrimary, isCentered: true,fontFamily: fontBold),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                // text(offerModel[index].description, textColor: sh_textColorSecondary),
                                Text(offerModel[index].description!,style: TextStyle(color: sh_textColorSecondary,fontSize: 16),),
                                Container(
                                  height: 0.5,
                                  color: sh_view_color,
                                  width: width,
                                  margin: EdgeInsets.only(top: spacing_standard_new),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  // By default, show a loading spinner.
                  return Center(child: CircularProgressIndicator());
                })),
      ),
    );
  }
}
