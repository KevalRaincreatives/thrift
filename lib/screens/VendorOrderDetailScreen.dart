import 'dart:async';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/OrderDetailModel.dart';
import 'package:thrift/provider/order_provider.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

class VendorOrderDetailScreen extends StatefulWidget {
  static String tag = '/VendorOrderDetailScreen';

  const VendorOrderDetailScreen({Key? key}) : super(key: key);

  @override
  _VendorOrderDetailScreenState createState() =>
      _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  // OrderDetailModel? orderDetailModel;
  String? productPerRow,
      showDiscountPrice,
      showShortDesc,
      currency_symbol,
      price_decimal_sep,
      price_num_decimals;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController controller5 = TextEditingController();
  String pro_rating = "";

  // String? vendor_country;
  int? cart_count;

  // Future<OrderDetailModel?>? fetchOrderMain;

  @override
  void initState() {
    super.initState();
    // fetchOrderMain=fetchOrder();
    final emp_pd = Provider.of<OrderProvider>(context, listen: false);
    emp_pd.getVendorOrderDetails();
  }

  Future<String?> fetchtotal() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('cart_count') != null) {
        cart_count = prefs.getInt('cart_count');
      } else {
        cart_count = 0;
      }

      return '';
    } catch (e) {
      print('caught error $e');
    }
  }

  // Future<String?> fetchCountry() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     vendor_country = prefs.getString('vendor_country');
  //
  //     return '';
  //   } catch (e) {
  //     print('caught error $e');
  //   }
  // }

  // Future<OrderDetailModel?> fetchOrder() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     // String UserId = prefs.getString('UserId');
  //     String? token = prefs.getString('token');
  //     String? order_id = prefs.getString('order_id');
  //
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     };
  //
  //     final msg = jsonEncode({"order_id": order_id});
  //     print(msg);
  //
  //     Response response = await post(
  //         Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/get_order_detail'),
  //         headers: headers,
  //         body: msg);
  //
  //     final jsonResponse = json.decode(response.body);
  //     print('VendorOrderDetailScreen get_order_detail Response status2: ${response.statusCode}');
  //     print('VendorOrderDetailScreen get_order_detail Response body2: ${response.body}');
  //     orderDetailModel = new OrderDetailModel.fromJson(jsonResponse);
  //
  //     return orderDetailModel;
  //   }  on Exception catch (e) {
  //
  //     print('caught error $e');
  //   }
  // }

  Future<String?> ReviewSubmit(String pro_id) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      // String email = emailCont.text;
      // String firstname = firstNameCont.text;
      // String lastname = lastNameCont.text;
      // String phone = profileModel!.data!.phone.toString();
      // String country_code = profileModel!.data!.phoneCode.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      String? profile_name = prefs.getString("profile_name");
      String? OrderUserEmail = prefs.getString('OrderUserEmail');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({
        "product_id": pro_id,
        "review": controller5.text.toString(),
        "reviewer": profile_name,
        "reviewer_email": OrderUserEmail,
        "rating": pro_rating
      });

      // String body = json.encode(data2);

      Response response = await post(
          Uri.parse('${Url.BASE_URL}wp-json/wc/v3/products/reviews'),
          headers: headers,
          body: msg);

//
      final jsonResponse = json.decode(response.body);
      EasyLoading.dismiss();

      print(
          'VendorOrderDetailScreen reviews Response status2: ${response.statusCode}');
      print('VendorOrderDetailScreen reviews Response body2: ${response.body}');
      toast("Review Submitted successfully");
      // becameSellerModel = new BecameSellerModel.fromJson(jsonResponse);

      // prefs.setString('login_name', firstname);

      return "becameSellerModel";
    } on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    CartPrice(int position,vendorOrderDetailModel) {
      var myprice2 =
          double.parse(vendorOrderDetailModel!.data!.products![position]!.total!);
      var myprice = myprice2.toStringAsFixed(2);
      // var myprice3;
      // if(price_decimal_sep==',') {
      //   myprice3 = myprice.replaceAll('.', ',').toString();
      // }else{
      //   myprice3=myprice;
      // }
      return text("\$" + myprice + " " + vendorOrderDetailModel!.data!.currency!,
          textColor: sh_colorPrimary2, fontSize: 14.0, fontFamily: 'Bold');
    }

    void _openCustomDialogSold(String prod_id) {
      showGeneralDialog(
          barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Center(
                      child: Text(
                    'Rate this product',
                    style: TextStyle(
                        color: sh_colorPrimary2,
                        fontSize: 18,
                        fontFamily: 'Bold'),
                    textAlign: TextAlign.center,
                  )),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Divider(
                        thickness: 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(spacing_standard),
                        child: RatingBar.builder(
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          unratedColor: sh_rating_unrated,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: sh_rating,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                            pro_rating = rating.toString();
                            // toast(rating.toString());
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: spacing_standard, right: spacing_standard),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: controller5,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            validator: (value) {
                              return value!.isEmpty
                                  ? "Review Filed Required!"
                                  : null;
                            },
                            style: TextStyle(
                                fontFamily: fontRegular,
                                fontSize: textSizeSMedium,
                                color: sh_textColorPrimary),
                            decoration: new InputDecoration(
                              hintText: 'Describe your experience',
                              border: InputBorder.none,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                              ),
                              filled: false,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            //   // TODO submit

                            if (pro_rating == '') {
                              toast("Please add a rating");
                            } else {
                              FocusScope.of(context).requestFocus(FocusNode());
                              Navigator.of(context, rootNavigator: true).pop();

                              ReviewSubmit(prod_id);
                            }
                          }
                          // _openCustomDialog2();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.only(top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2,
                              radius: 10,
                              showShadow: true),
                          child: text("Submit",
                              fontSize: 16.0,
                              textColor: sh_white,
                              isCentered: true,
                              fontFamily: 'Bold'),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.only(top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_btn_color,
                              radius: 10,
                              showShadow: true),
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

    ProductList(vendorOrderDetailModel) {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: vendorOrderDetailModel!.data!.products!.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              // margin: EdgeInsets.only(bottom: spacing_standard_new),
              margin: EdgeInsets.fromLTRB(26, 0, 26, spacing_standard_new),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.all(Radius.circular(spacing_middle)),
                      child: Image.network(
                        vendorOrderDetailModel!.data!.products![index]!.image!,
                        fit: BoxFit.fill,
                        height: width * 0.20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: spacing_standard_new,
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Html(
                          data: vendorOrderDetailModel!.data!.products![index]!.name!,
                          style: {
                            "body": Style(
                              maxLines: 2,
                              margin: EdgeInsets.zero, padding: EdgeInsets.zero,
                              fontSize: FontSize(16.0),
                              color: sh_colorPrimary2,
                              fontFamily: fontRegular,
                            ),
                          },
                        ),
                        // Text(
                        //   vendorOrderDetailModel!.data!.products![index]!.name!,
                        //   style:
                        //       TextStyle(color: sh_colorPrimary2, fontSize: 16),
                        // ),
                        SizedBox(
                          height: 1,
                        ),
                        CartPrice(index,vendorOrderDetailModel),
                        // text(
                        //   "\$" + orderDetailModel!.data!.products![index]!.total!,
                        // ),
                        SizedBox(
                          height: 4,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              spacing_standard, 1, spacing_standard, 1),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: sh_view_color, width: 1)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              text(
                                  "Qty: " +
                                      vendorOrderDetailModel!
                                          .data!.products![index]!.quantity
                                          .toString(),
                                  textColor: sh_textColorPrimary,
                                  fontSize: textSizeSmall)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            ;
          });
    }

    // CouponDet() {
    //   if (orderDetailModel!.data!.coupons!.length > 0) {
    //     var myprice2 =
    //         double.parse(orderDetailModel!.data!.coupons![0].amount.toString());
    //     var myprice = myprice2.toStringAsFixed(2);
    //     var myprice3;
    //     if (price_decimal_sep == ',') {
    //       myprice3 = myprice.replaceAll('.', ',').toString();
    //     } else {
    //       myprice3 = myprice;
    //     }
    //
    //     return Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: <Widget>[
    //         text(sh_lbl_coupon_discount),
    //         text(
    //             "(" +
    //                 orderDetailModel!.data!.coupons![0].code! +
    //                 ")" +
    //                 myprice3,
    //             textColor: sh_textColorPrimary,
    //             fontFamily: fontMedium),
    //       ],
    //     );
    //   } else {
    //     return Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: <Widget>[
    //         text(sh_lbl_coupon_discount),
    //         text('N/A', textColor: sh_textColorPrimary, fontFamily: fontMedium),
    //       ],
    //     );
    //   }
    // }

    SubPrice(vendorOrderDetailModel) {
      var myprice2 = double.parse(vendorOrderDetailModel!.data!.subTotal.toString());
      var myprice = myprice2.toStringAsFixed(2);
      var myprice3;
      if (price_decimal_sep == ',') {
        myprice3 = myprice.replaceAll('.', ',').toString();
      } else {
        myprice3 = myprice;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // text(AppLocalizations.of(context)!.sh_lbl_sub_total,
          //     fontSize: textSizeSMedium,
          //     fontFamily: fontBold,
          //     textColor: sh_textColorPrimary),
          // text(currency_symbol! + myprice3,
          //     textColor: sh_textColorPrimary,
          //     fontFamily: fontBold,
          //     fontSize: textSizeSMedium),
          text(sh_lbl_sub_total,
              textColor: sh_textColorPrimary,
              fontSize: textSizeMedium,
              fontFamily: fontSemibold),
          text("\$" + myprice + " " + vendorOrderDetailModel!.data!.currency!,
              textColor: sh_colorPrimary2,
              fontFamily: fontMedium,
              fontSize: textSizeMedium),
        ],
      );
    }



    OrdDate(vendorOrderDetailModel) {
      var inputFormat = DateFormat("yyyy-MM-dd");

      String date1 = inputFormat
          .parse(vendorOrderDetailModel!.data!.dateCreated!.date!.substring(0, 10))
          .toString();
      DateTime dateTime = DateTime.parse(date1);
      var outputFormat = DateFormat.yMMMMd('en_US').format(dateTime);

      String date2 = outputFormat.toString();
      return text(date2,
          textColor: sh_textColorPrimary,
          fontFamily: fontMedium,
          fontSize: textSizeMedium);
    }


    FetchCountryDetails(vendorOrderDetailModel) {
      if (vendorOrderDetailModel == 'Barbados') {
        return Container();
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                text("Order By -",
                    textColor: sh_textColorPrimary,
                    fontSize: textSizeMedium,
                    fontFamily: fontSemibold),
                text(
                    vendorOrderDetailModel!.data!.shippingAddress!.firstName! +
                        " " +
                        vendorOrderDetailModel!.data!.shippingAddress!.lastName!,
                    textColor: sh_textColorPrimary,
                    fontFamily: fontMedium,
                    fontSize: textSizeMedium),
              ],
            ),
            SizedBox(
              height: spacing_control,
            ),
          ],
        );
      }
    }

    shippingDetail(vendorOrderDetailModel) {
      if (vendorOrderDetailModel == 'Barbados') {
        return Container();
      } else {
        return Container(
          margin:
              EdgeInsets.only(left: 26, right: 26, top: spacing_standard_new),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: sh_view_color, width: 1.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(spacing_standard_new,
                    spacing_middle, spacing_standard_new, spacing_middle),
                child: text(sh_lbl_shipping_details,
                    textColor: sh_textColorPrimary,
                    fontSize: textSizeMedium,
                    fontFamily: fontSemibold),
              ),
              Divider(
                height: 1,
                color: sh_view_color,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(spacing_standard_new,
                    spacing_middle, spacing_standard_new, spacing_middle),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    text(
                        vendorOrderDetailModel!.data!.shippingAddress!.firstName! +
                            " " +
                            vendorOrderDetailModel!.data!.shippingAddress!.lastName!,
                        textColor: sh_textColorPrimary,
                        fontFamily: fontMedium,
                        fontSize: textSizeMedium),
                    text(vendorOrderDetailModel!.data!.shippingAddress!.address,
                        textColor: sh_textColorPrimary,
                        fontSize: textSizeMedium),
                    text(
                        vendorOrderDetailModel!.data!.shippingAddress!.city! +
                            "," +
                            vendorOrderDetailModel!.data!.shippingAddress!.postcode!,
                        textColor: sh_textColorPrimary,
                        fontSize: textSizeSMedium),
                    text(
                        vendorOrderDetailModel!.data!.shippingAddress!.state! +
                            "," +
                            vendorOrderDetailModel!.data!.shippingAddress!.country!,
                        textColor: sh_textColorPrimary,
                        fontSize: textSizeMedium),
                  ],
                ),
              )
            ],
          ),
        );
      }
    }

    orderDetail(vendorOrderDetailModel) {
      return Container(
        margin: EdgeInsets.only(left: 26, right: 26),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: sh_view_color, width: 1.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(spacing_standard_new,
                  spacing_middle, spacing_standard_new, spacing_middle),
              child: text(sh_lbl_sales_details,
                  textColor: sh_textColorPrimary,
                  fontSize: textSizeMedium,
                  fontFamily: fontSemibold),
            ),
            Divider(
              height: 1,
              color: sh_view_color,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(spacing_standard_new,
                  spacing_middle, spacing_standard_new, spacing_middle),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      text(sh_lbl_order_id,
                          textColor: sh_textColorPrimary,
                          fontSize: textSizeMedium,
                          fontFamily: fontSemibold),
                      text("#" + vendorOrderDetailModel!.data!.orderId.toString(),
                          textColor: sh_textColorPrimary,
                          fontFamily: fontMedium,
                          fontSize: textSizeMedium),
                    ],
                  ),
                  SizedBox(
                    height: spacing_control,
                  ),
                  Row(
                    children: <Widget>[
                      text(sh_lbl_order_date,
                          textColor: sh_textColorPrimary,
                          fontSize: textSizeMedium,
                          fontFamily: fontSemibold),
                      OrdDate(vendorOrderDetailModel)
                    ],
                  ),
                  SizedBox(
                    height: spacing_control,
                  ),
                  // FetchCountryDetails(vendorOrderDetailModel),

                ],
              ),
            )
          ],
        ),
      );
    }

    BadgeCount() {
      if (cart_count == 0) {
        return Image.asset(
          sh_new_cart,
          height: 44,
          width: 44,
          fit: BoxFit.fill,
          color: sh_white,
        );
      } else {
        return Badge(
          position: BadgePosition.topEnd(top: 4, end: 6),
          badgeContent: Text(
            cart_count.toString(),
            style: TextStyle(color: sh_white, fontSize: 8),
          ),
          child: Container(
            child: Image.asset(
              sh_new_cart,
              height: 44,
              width: 44,
              color: sh_white,
            ),
          ),
        );
      }
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Sales Details",
          style:
              TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
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
          child: SingleChildScrollView(
            child: Container(
              width: width,
              height: height,
              child: Consumer<OrderProvider>(builder: ((context, data, child) {
                return data.loader_det_vendor
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        enabled: true,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 60.0,
                                    height: 60.0,
                                    color: Colors.white,
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 8.0,
                                          color: Colors.white,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
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
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: width * .3,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: double.infinity,
                                height: 40.0,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              Container(
                                width: width * .3,
                                height: 8.0,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: double.infinity,
                                height: 80.0,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: double.infinity,
                                height: 100.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            // SizedBox(
                            //   height: 16,
                            // ),
                            ProductList(data.vendorOrderDetailModel),
                            orderDetail(data.vendorOrderDetailModel),
                            // shippingDetail(data.vendorOrderDetailModel),
                            // paymentDetail(data.orderDetailModel),
                            SizedBox(
                              height: 200,
                            )
                          ],
                        ),
                      );
              })),

              // FutureBuilder<OrderDetailModel?>(
              //     future: fetchOrderMain,
              //     builder: (context, snapshot) {
              //       if (snapshot.hasData) {
              //         return SingleChildScrollView(
              //           child: Column(
              //             children: <Widget>[
              //
              //               ProductList(),
              //               orderDetail(),
              //               FutureBuilder<String?>(
              //                 future: fetchCountry(),
              //                 builder: (context, snapshot) {
              //                   if (snapshot.hasData) {
              //                     return shippingDetail();
              //                   } else if (snapshot.hasError) {
              //                     return Text("${snapshot.error}");
              //                   }
              //                   // By default, show a loading spinner.
              //                   return CircularProgressIndicator();
              //                 },
              //               ),
              //
              //               // paymentDetail(),
              //               SizedBox(
              //                 height: 200,
              //               )
              //             ],
              //           ),
              //         );
              //       } else if (snapshot.hasError) {
              //         return Text("${snapshot.error}");
              //       }
              //       // By default, show a loading spinner.
              //       // return CircularProgressIndicator();
              //       return Shimmer.fromColors(
              //         baseColor: Colors.grey[300]!,
              //         highlightColor: Colors.grey[100]!,
              //         enabled: true,
              //         child: Container(
              //           padding: EdgeInsets.all(20),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Row(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: <Widget>[
              //                   Container(
              //                     width: 60.0,
              //                     height: 60.0,
              //                     color: Colors.white,
              //                   ),
              //                   const Padding(
              //                     padding: EdgeInsets.symmetric(horizontal: 8.0),
              //                   ),
              //                   Expanded(
              //                     child: Column(
              //                       crossAxisAlignment: CrossAxisAlignment.start,
              //                       children: <Widget>[
              //                         Container(
              //                           width: double.infinity,
              //                           height: 8.0,
              //                           color: Colors.white,
              //                         ),
              //                         const Padding(
              //                           padding: EdgeInsets.symmetric(vertical: 8.0),
              //                         ),
              //                         Container(
              //                           width: double.infinity,
              //                           height: 8.0,
              //                           color: Colors.white,
              //                         ),
              //                         const Padding(
              //                           padding: EdgeInsets.symmetric(vertical: 8.0),
              //                         ),
              //                         Container(
              //                           width: 40.0,
              //                           height: 8.0,
              //                           color: Colors.white,
              //                         ),
              //                       ],
              //                     ),
              //                   )
              //                 ],
              //               ),
              //               SizedBox(height: 20,),
              //               Container(
              //                 width: width*.3,
              //                 height: 8.0,
              //                 color: Colors.white,
              //               ),
              //               SizedBox(height: 10,),
              //               Container(
              //                 width: double.infinity,
              //                 height: 40.0,
              //                 color: Colors.white,
              //               ),
              //               SizedBox(height: 18,),
              //               Container(
              //                 width: width*.3,
              //                 height: 8.0,
              //                 color: Colors.white,
              //               ),
              //               SizedBox(height: 10,),
              //               Container(
              //                 width: double.infinity,
              //                 height: 80.0,
              //                 color: Colors.white,
              //               ),
              //
              //               SizedBox(height: 20,),
              //               Container(
              //                 width: double.infinity,
              //                 height: 100.0,
              //                 color: Colors.white,
              //               ),
              //             ],),
              //         ),
              //       );
              //     }),
            ),
          ),
        ),
        // Positioned to take only AppBar size
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.0, 2, 6, 2),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 32,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 6, 6, 6.0),
                      child: Text(
                        "Sales Details",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'TitleCursive'),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setInt("shiping_index", -2);
                        prefs.setInt("payment_index", -2);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartScreen()),
                        ).then((value) {
                          setState(() {
                            // refresh state
                          });
                        });
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
