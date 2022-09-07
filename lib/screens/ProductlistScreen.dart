import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/ProductDetailScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';



class ProductlistScreen extends StatefulWidget {
  static String tag='/ProductlistScreen';
  const ProductlistScreen({Key? key}) : super(key: key);

  @override
  _ProductlistScreenState createState() => _ProductlistScreenState();
}

class _ProductlistScreenState extends State<ProductlistScreen> {
  final double runSpacing = 4;
  final double spacing = 4;
  final columns = 2;
  List<ProductListModel> productListModel = [];
  var appBarTitleText ;
  String? fnl_token;
  Future<String?>? fetchDataMain;
  Future<List<ProductListModel>?>? fetchAlbumMain;
  int? cart_count;
  int timer = 800, offset = 0;
  @override
  void initState() {
    super.initState();
    fetchDataMain=fetchData();
    fetchAlbumMain=fetchAlbum();

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

  Future<String?> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      fnl_token = prefs.getString('token');
      appBarTitleText = prefs.getString('cat_names');


      return appBarTitleText;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }

  Future<List<ProductListModel>?> fetchAlbum() async {
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? user_country = prefs.getString('user_selected_country');
      // toast(cat_id);

      var response = await http.get(
          Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/?stock_status=instock&status=publish&orderby=date&order=desc&per_page=100&country=$user_country&category=$cat_id"));

      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      productListModel.clear();
      final jsonResponse = json.decode(response.body);
      for (Map i in jsonResponse) {
        productListModel.add(ProductListModel.fromJson(i));
//        orderListModel = new OrderListModel2.fromJson(i);
      }

      return productListModel;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - runSpacing * (columns - 1)) / columns;
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

    Imagevw4(int index) {
      if (productListModel[index].images!.length < 1) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Image.asset(
            sh_no_img,
            fit: BoxFit.cover,
            height: 150,
            width: MediaQuery.of(context).size.width,


          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Image.network(
            productListModel[index].images![0]!.src!,
            fit: BoxFit.cover ,
            height: 150,
            width: width,

          ),
        );
      }
    }

    NewImagevw(int index) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [

              Imagevw4(index),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: <Widget>[
              //     Container(
              //       height: 40,
              //       width: 40,
              //       child: Icon(
              //         Icons.favorite_border,
              //         color: sh_textColorSecondary,
              //         size: 24,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ],
      );
    }

    TextName(String names) {
      var unescape = HtmlUnescape();
      print(unescape.convert('&lt;strong&#62;This &quot;escaped&quot; string '
          'will be printed normally.</strong>'));
      return Container(
          child: Text(
            unescape.convert(names),
            style: TextStyle(
                fontSize: 20,
                color: sh_app_txt_color,
                fontFamily: 'Bold',
                fontWeight: FontWeight.bold),
          )
        // text10(model.name, textColor: sh_textColorSecondary)
      );
    }

    Descrptntext(int index){
      // if(showShortDesc=='1') {
        return text(productListModel[index].slug,
            fontFamily: fontMedium,
            textColor: sh_app_txt_color,
            fontSize: textSizeSmall);
      // }else{
      //   return Container();
      // }
    }

    DiscountPrice(int index){
      var myprice2,myprice;
      if(productListModel[index].price==''){
        myprice="0.00";
      }else {
        myprice2 = double.parse(productListModel[index].price!);
        myprice = myprice2.toStringAsFixed(2);
      }

      // if(showDiscountPrice=='1') {
        return Text(
          "\$" + myprice,
          style: TextStyle(
              color: sh_red,
              fontFamily: fontBold,
              fontSize: textSizeSMedium,
              decoration: TextDecoration.lineThrough),
        );
      // }else{
      //   return Container();
      // }
    }

    MyPrice(int index){
      var myprice2,myprice;
      if(productListModel[index].price==''){
        myprice="0.00";
      }else {
         myprice2 = double.parse(productListModel[index].price!);
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
          // SizedBox(
          //   width: 5,
          // ),
          // DiscountPrice(index)

        ],
      );
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Products",
          style: TextStyle(color: sh_white),
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
            child: Image.asset(sh_upper2,fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Container(
          height: height,
          width: width,

          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          padding: EdgeInsets.fromLTRB(0,0, 10, 0),
          child: SingleChildScrollView(

            child: Container(
              color: sh_white,
              // margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(

                    padding: const EdgeInsets.fromLTRB(12.0,8,8,12),
                    child: FutureBuilder<String?>(
                      future: fetchDataMain,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return  TextName(appBarTitleText);
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  FutureBuilder<List<ProductListModel>?>(
                    future: fetchAlbumMain,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
      if(productListModel.length > 0) {
        return Wrap(
          runSpacing: runSpacing,
          spacing: spacing,
          alignment: WrapAlignment.center,
          children: List.generate(productListModel.length, (index) {
              return InkWell(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString(
                      'pro_id', productListModel[index].id.toString());
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductDetailScreen()));
                },
                child: Container(
                  width: w * .9,
                  decoration: boxDecoration4(showShadow: false),
                  margin: EdgeInsets.only(left: 12, bottom: 12),
                  // padding: EdgeInsets.fromLTRB(spacing_standard,spacing_standard,spacing_standard,spacing_control_half),
                  padding:
                  EdgeInsets.fromLTRB(0, 0, 0, spacing_control_half),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      NewImagevw(index),
                      SizedBox(
                        height: 6,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0, right: spacing_standard),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              productListModel[index].name!,
                              maxLines: 1,
                              style: TextStyle(
                                  color: sh_black,
                                  fontFamily: fontBold,
                                  fontSize: textSizeMedium),
                            ),
                            SizedBox(
                              height: 2,
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
              );
          }),
        );
      }else{
        return Container(
          height: height-350,
          alignment: Alignment.center,
          child: Center(
              child: Text(
                'No Product Found',
                style: TextStyle(
                    fontSize: 20,
                    color: sh_colorPrimary2,
                    fontWeight: FontWeight.bold),
              ),
          ),
        );
      }

                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
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
                      child: Text("Products",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive'),),
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
        ));
  }
}
