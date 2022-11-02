import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:thrift/model/SearchModel.dart';
import 'package:thrift/screens/ProductDetailScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/utils/ShExtension.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

class SearchScreen extends StatefulWidget {
  static String tag='/SearchScreen';
  String? serchdata;

  SearchScreen({this.serchdata});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  // var list = List<ShProduct>();
  bool isLoadingMoreData = false;
  bool isEmpty = true;
  var searchText = "";
  String? currency,currency_pos;
  String _verticalGroupValue = "All";
  bool? firsttime=true;
  final double runSpacing = 4;
  final double spacing = 4;
  final columns = 2;
  List<ProductListModel> productListModel = [];

bool lasttime=true;
  List<String> _status = ["All","Popularity", "Latest", "Price Low to High", "Price High to Low"];
  Future<String?>? fetchaddMain;


  @override
  void initState() {
    super.initState();
    SearchNewData();
    fetchaddMain=fetchadd();
  }


  Future<List<ProductListModel>?> SearchNewData() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? user_country = prefs.getString('user_selected_country');
      // toast(cat_id);

      searchText=widget.serchdata!;
print("https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products?stock_status=instock&status=publish&country=$user_country&search=$searchText");
      var response = await http.get(
          Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products?stock_status=instock&status=publish&country=$user_country&search=$searchText"));

      print('SearchScreen products Response status2: ${response.statusCode}');
      print('SearchScreen products Response body2: ${response.body}');
      productListModel.clear();
      final jsonResponse = json.decode(response.body);
      for (Map i in jsonResponse) {
        productListModel.add(ProductListModel.fromJson(i));
//        orderListModel = new OrderListModel2.fromJson(i);
      }

      EasyLoading.dismiss();
      searchController.text==widget.serchdata;

      setState(() {
        isEmpty = productListModel.isEmpty;
      });

      return productListModel;
    } catch (e) {
      EasyLoading.dismiss();
//      return orderListModel;
      print('caught error $e');
    }
  }

//   Future<SearchModel?> SearchNewData() async {
//     EasyLoading.show(status: 'Please wait...');
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // String pro_id = prefs.getString('pro_id');
//       currency = prefs.getString('currency');
//       currency_pos = prefs.getString('currency_pos');
//
//
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };
//       String? types;
//       if(_verticalGroupValue=='All'){
//         types='';
//       }else if(_verticalGroupValue=='Popularity'){
//         types='popularity';
//       }else if(_verticalGroupValue=='Latest'){
//         types='latest';
//       }else if(_verticalGroupValue=='Price Low to High'){
//         types='price_low_to_high';
//       }else if(_verticalGroupValue=='Price High to Low'){
//         types='price_high_to_low';
//       }
//       searchText=widget.serchdata!;
//
//       var body = json.encode({
//         "type": types,
//         "title": searchText
//       });
//
//       print(body);
//
//
//       var response = await http.post(Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/filter'), body: body,headers: headers);
//
//       EasyLoading.dismiss();
//
//       print('Response status2: ${response.statusCode}');
//       print('Response body2: ${response.body}');
//       final jsonResponse = json.decode(response.body);
//       print('not json $jsonResponse');
//       searchModel = new SearchModel.fromJson(jsonResponse);
//       // toast(orderSuccessModel.error);
//       // launchScreen(context, CheckOut.tag);
//       searchController.text==widget.serchdata;
//
//       setState(() {
//         isEmpty = searchModel!.data!.isEmpty;
//       });
//
// //      print(cat_model.data);
//       return searchModel;
//
//     } catch (e) {
//       EasyLoading.dismiss();
//       print('caught error $e');
//       // return cat_model;
//     }
//   }

  Future<List<ProductListModel>?> SearchData() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? user_country = prefs.getString('user_selected_country');
      // toast(cat_id);

      // print("https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products?stock_status=instock&status=publish&country=India&search=$searchText");
      var response = await http.get(
          Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products?stock_status=instock&status=publish&country=$user_country&search=$searchText"));

      print('SearchScreen products Response status2: ${response.statusCode}');
      print('SearchScreen products Response body2: ${response.body}');
      productListModel.clear();
      final jsonResponse = json.decode(response.body);
      for (Map i in jsonResponse) {
        if (i["display_product"] == true) {
          productListModel.add(ProductListModel.fromJson(i));
        }
      }
      EasyLoading.dismiss();

      searchController.text==widget.serchdata;

      setState(() {
        isEmpty = productListModel.isEmpty;
      });

      return productListModel;
    } catch (e) {
      EasyLoading.dismiss();
//      return orderListModel;
      print('caught error $e');
    }
  }

//   Future<SearchModel?> SearchData() async {
//     EasyLoading.show(status: 'Please wait...');
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // String pro_id = prefs.getString('pro_id');
//       currency = prefs.getString('currency');
//       currency_pos = prefs.getString('currency_pos');
//
//
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };
//       String? types;
//       if(_verticalGroupValue=='All'){
//         types='';
//       }else if(_verticalGroupValue=='Popularity'){
//         types='popularity';
//       }else if(_verticalGroupValue=='Latest'){
//         types='latest';
//       }else if(_verticalGroupValue=='Price Low to High'){
//         types='price_low_to_high';
//       }else if(_verticalGroupValue=='Price High to Low'){
//         types='price_high_to_low';
//       }
//
//       var body = json.encode({
//         "type": types,
//         "title": searchText
//       });
//
//       print(body);
//
//
//       var response = await http.post(Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/filter'), body: body,headers: headers);
//
//       EasyLoading.dismiss();
//
//       print('Response status2: ${response.statusCode}');
//       print('Response body2: ${response.body}');
//       final jsonResponse = json.decode(response.body);
//       print('not json $jsonResponse');
//       searchModel = new SearchModel.fromJson(jsonResponse);
//       // toast(orderSuccessModel.error);
//       // launchScreen(context, CheckOut.tag);
//
//       setState(() {
//
//         isEmpty = searchModel!.data!.isEmpty;
//       });
//
// //      print(cat_model.data);
//       return searchModel;
//
//     } catch (e) {
//       EasyLoading.dismiss();
//       print('caught error $e');
//       // return cat_model;
//     }
//   }

  Future<String?> fetchadd() async {
    try {
      if(firsttime!) {
        searchController.text = widget.serchdata!;
      }
      // else{
      //   searchController.text=""
      // }
      return '';
    } catch (e) {
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    Imagevw4(int index) {
      if (productListModel[index].images!.length < 1) {
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
            productListModel[index].images![0]!.src!,
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
      if(productListModel[index].price==''){
        myprice='0.00';
      }else {
        myprice2 = double.parse(productListModel[index].price!);
        myprice = myprice2.toStringAsFixed(2);
      }
      return Row(
        children: [
          Text(
            "\$" + myprice+ " "+"USD",
            style: TextStyle(
                color: sh_black,
                fontFamily: 'Medium',
                fontSize: textSizeSMedium2),
          ),

        ],
      );
    }

    CheckTitle() {
      if (!firsttime!) {
        if (searchController.text == '') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 80,
              ),
              text("Search Empty", fontFamily: fontMedium,
                  fontSize: textSizeMedium)
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 80,
              ),
              text("No results found for \"" + searchController.text + "\"",
                  textColor: sh_textColorPrimary,
                  fontFamily: fontMedium,
                  fontSize: textSizeMedium),
              text("Try a diffetent keyword", fontFamily: fontMedium,
                  fontSize: textSizeSMedium)
            ],
          );
        }
      }else{
        // toast("value");

        // return Container();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            text("No results found for \"" + searchController.text + "\"",
                textColor: sh_textColorPrimary,
                fontFamily: fontMedium,
                fontSize: textSizeMedium),
            text("Try a different keyword", fontFamily: fontMedium,
                fontSize: textSizeSMedium)
          ],
        );
      }
    }

    searchList(){
      return AnimationLimiter(
        child: GridView.count(
          childAspectRatio: 0.75,
          crossAxisCount: 2,
          crossAxisSpacing: 30.0,
          mainAxisSpacing: 15.0,

          children: List.generate(
            productListModel.length,
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
                        prefs.setString('pro_id', productListModel[index].id.toString());
                        List<String> myimages = [];
                        for (var i = 0;
                        productListModel[index].images!.length > i;
                        i++) {
                          myimages.add(
                              productListModel[index].images![i]!.src!);
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(proName: productListModel[index].name,proPrice: productListModel[index].price,proImage: myimages,)));
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
                                  Text(
                                    productListModel[index].name!,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: sh_black,
                                        fontFamily: fontBold,
                                        fontSize: textSizeMedium),
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
      )
    ;}

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: TextFormField(
          onFieldSubmitted: (value) {
            setState(() {
              searchText = value;
              isEmpty = false;
              isLoadingMoreData = true;
              firsttime=false;
            });
            SearchData();
          },
          controller: searchController,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: textSizeMedium, color: sh_white),
          decoration: InputDecoration( hintText: "Search",focusColor: sh_white),
          keyboardType: TextInputType.text,
          textAlign: TextAlign.start,
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          searchController.text.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.fromLTRB(8.0,2,8,2),
                child: IconButton(
            icon: Icon(
                Icons.clear,
                color: sh_white,
            ),
            onPressed: () {
                setState(() {
                  firsttime=false;
                  searchController.clear();
                  productListModel.clear();
                  isEmpty = false;
                  isLoadingMoreData = false;
                });
            },
          ),
              )
              : Container()
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
          child: Container(
            padding: EdgeInsets.fromLTRB(26,0,26,0),
            // physics: BouncingScrollPhysics(),
            child: !isEmpty
                ? searchList()
                : Center(
              child: CheckTitle(),
            ),
          ),
        ),
        // Positioned to take only AppBar size
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: appBar,
        ),

      ]);
    }

    return Scaffold(
      body: SafeArea(child:
      FutureBuilder<String?>(
        future: fetchaddMain,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamProvider<NetworkStatus>(
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
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator(

          );
        },
      )

      ),
    );

  }
}
