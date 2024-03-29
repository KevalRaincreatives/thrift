import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/OrderListModel.dart';
import 'package:thrift/provider/order_provider.dart';
import 'package:thrift/screens/CartScreen.dart';

import 'package:thrift/screens/VendorOrderDetailScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:badges/badges.dart';
class MySalesFragment extends StatefulWidget {
  const MySalesFragment({Key? key}) : super(key: key);

  @override
  _MySalesFragmentState createState() => _MySalesFragmentState();
}

class _MySalesFragmentState extends State<MySalesFragment> with AutomaticKeepAliveClientMixin<MySalesFragment>{
  // OrderListModel? orderListModel;
  String? productPerRow,
      showDiscountPrice,
      showShortDesc,currency_symbol,price_decimal_sep,price_num_decimals;
  String? sh_app_bars;
  // Future<OrderListModel?>? fetchOrderMain;

  @override
  void initState() {
    super.initState();
    // fetchOrderMain=fetchOrder();
    final emp_pd = Provider.of<OrderProvider>(context, listen: false);
    emp_pd.getVendorOrderList();
  }

  @override
  bool get wantKeepAlive => true;

  // Future<OrderListModel?> fetchOrder() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     // String UserId = prefs.getString('UserId');
  //     String? token = prefs.getString('token');
  //     print(token);
  //
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     };
  //
  //     Response response = await get(
  //         Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/view_vendor_order'),
  //         headers: headers);
  //
  //
  //
  //     print('MySalesFragment view_vendor_order Response status2: ${response.statusCode}');
  //     print('MySalesFragment view_vendor_order Response body2: ${response.body}');
  //     final jsonResponse = json.decode(response.body);
  //     orderListModel = new OrderListModel.fromJson(jsonResponse);
  //
  //     return orderListModel;
  //   } on Exception catch (e) {
  //
  //     print('caught error $e');
  //   }
  // }



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
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var height = MediaQuery
        .of(context)
        .size
        .height;
    toCurrencyFormat({var format = '\$'}) {
      return format + this;
    }

    OrderDate(int index,vendorOrderListModel) {
      String order_status=vendorOrderListModel!.data![index]!.order_status!;
      String hh = vendorOrderListModel!.data![index]!.postTitle!.substring(13);
      String dd = hh.substring(0, hh.length - 10);
      return text(
          dd +
              "\n Order Status: $order_status",
          maxLine: 2,
          fontSize: textSizeSMedium2,
          textColor: sh_textColorPrimary);


    }

    CartPrice(int index,vendorOrderListModel){
      var myprice2 =double.parse(vendorOrderListModel!.data![index]!.subTotal.toString());
      var myprice = myprice2.toStringAsFixed(2);
      var myprice3;
      if(price_decimal_sep==',') {
        myprice3 = myprice.replaceAll('.', ',').toString();
      }else{
        myprice3=myprice;
      }
      return                           text7("Total : \$" +
          myprice3 +" "+vendorOrderListModel!.currency!,
          textColor: sh_app_txt_color,
          fontFamily: fontBold,
          fontSize: textSizeMedium);
    }

    listView(vendorOrderListModel) {
      if(vendorOrderListModel!.data!.length == 0){
        return Container(
          height: height-130,
          alignment: Alignment.center,
          child: Center(
            child: Text(
              'No Order Found',
              style: TextStyle(
                  fontSize: 20,
                  color: sh_colorPrimary2,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      }else {
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: vendorOrderListModel!.data!.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('order_id',
                    vendorOrderListModel!.data![index]!.ID!.toString());
                prefs.commit();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VendorOrderDetailScreen()));
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(26, 20, 26, 0),
                padding: EdgeInsets.fromLTRB(16,10.0,16,10),
                decoration: BoxDecoration(
                  border: Border.all(color: sh_colorPrimary2),
                  color: sh_white,
                  borderRadius: BorderRadius.circular(10.0),
                  // boxShadow: true
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            text7("ID :#" +
                                vendorOrderListModel!.data![index]!.ID.toString(),
                                textColor: sh_textColorPrimary,
                                fontFamily: fontSemibold,
                                fontSize: textSizeMedium),
                            // SizedBox(height: 2),
                            Html(
                              data: vendorOrderListModel!.data![index]!.products![0]!.name!,
                              style: {
                                "body": Style(
                                  maxLines: 2,
                                  margin: EdgeInsets.zero, padding: EdgeInsets.zero,
                                  fontSize: FontSize(16.0),
                                  color: sh_app_txt_color,
                                  fontFamily: fontSemibold,
                                ),
                              },
                            ),
                            // text7(vendorOrderListModel!.data![index]!.products![0]!.name!,
                            //     textColor: sh_app_txt_color,
                            //     fontFamily: fontSemibold,
                            //     fontSize: textSizeMedium),
                            CartPrice(index,vendorOrderListModel),
                            // text7("Total : $currency_symbol" +
                            //     orderListModel!.data![index]!.total.toString(),
                            //     textColor: sh_colorPrimary,
                            //     fontFamily: 'Bold',
                            //     fontSize: textSizeNormal),
                            SizedBox(
                              height: spacing_standard,
                            ),
                            Expanded(
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment
                                      .stretch,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          OrderDate(index,vendorOrderListModel)


                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    }

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
          sh_lbl_my_orders,
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
          child: Container(
            width: width,
            height: height,
            child: SafeArea(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // TopBar(t1_Listing),
                      Consumer<OrderProvider>(
                          builder: ((context, order_value, child) {
                            return order_value.loader_vendor
                                ? Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              enabled: true,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemBuilder: (_, __) => Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        height: 10.0,
                                        color: Colors.white,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5.0),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 10.0,
                                        color: Colors.white,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5.0),
                                      ),
                                      Container(
                                        width: 40.0,
                                        height: 8.0,
                                        color: Colors.white,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5.0),
                                      ),
                                      Container(
                                        width: 40.0,
                                        height: 8.0,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                itemCount: 6,
                              ),
                            )
                                : listView(order_value.vendorOrderListModel);
                          })),


                      Container(
                        height: 16,
                      )
                    ],
                  ),
                ),
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
            padding: const EdgeInsets.fromLTRB(30,18,10,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(6.0,0,6,0),
                    //   child: IconButton(onPressed: () {
                    //     // Navigator.pop(context);
                    //   }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 32,)),
                    // ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,6,6,6.0),
                      child: Text(sh_lbl_my_sales,style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
