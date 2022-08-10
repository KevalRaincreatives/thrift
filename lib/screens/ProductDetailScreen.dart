import 'dart:convert';

import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nb_utils/nb_utils.dart' hide lightGrey;
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/database/CartPro.dart';
import 'package:thrift/database/database_hepler.dart';
import 'package:thrift/model/AddCartModel.dart';
import 'package:thrift/model/CartModel.dart';
import 'package:thrift/model/GetVariantModel.dart';
import 'package:thrift/model/MyVariant.dart';
import 'package:thrift/model/ProductDetailModel.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/model/ProductSellerModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/SellerProfileScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:badges/badges.dart';

class ProductDetailScreen extends StatefulWidget {
  static String tag = '/ProductDetailScreen';
  // ProductListModel? product;

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  dynamic yMin;
  dynamic yMax;

  var position = 0;
  bool isExpanded = false;
  var selectedColor = -1;
  var selectedSize = -1;
  double fiveStar = 0;
  double fourStar = 0;
  double threeStar = 0;
  double twoStar = 0;
  double oneStar = 0;
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  PageController? _controller;

  Future<ProductDetailModel?>? futuredetail;
  ProductDetailModel? pro_det_model;
  GetVariantModel? getVariantModel;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  List<ProductListModel> productListModel = [];
  bool _isColorVisible = false;
  bool _isSizeVisible = false;
  String? selectedValue = null;
  List<String> selectedItemValue = <String>[];
  AddCartModel? addCartModel;
  List<CartPro> cartPro = [];
  final dbHelper = DatabaseHelper.instance;
  final List<MyVariant> itemsModel = [];
  MyVariant? itModel;
  String mynames = "";
  String myvariation_name = '';
  String myvariation_value = '';

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  final _kArrowColor = Colors.black.withOpacity(0.8);
  bool _isVisible = true;
  bool _isVisible_success = false;
  ProductSellerModel? productSellerModel;
  CartModel? cat_model;
  Future<ProductDetailModel?>? fetchDetailMain;
  Future<ProductSellerModel?>? fetchSellerMain;

  @override
  void initState() {
    _controller = PageController();
    fetchDetailMain=fetchDetail();
    fetchSellerMain=fetchSeller();
    super.initState();
//    mListings2 = getPopular();
  }

  Future<bool> _onWillPop()  async{
    Navigator.pop(context);
    return false;
  }

  Future<List<ProductListModel>?> fetchAlbum() async {
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');

      var response = await http.get(Uri.parse(
          "https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/?category=$cat_id"));

      print('Response status2: ${response.statusCode}');
      print('Response body2:  prpr${response.body}');
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

  Future<ProductSellerModel?> fetchSeller() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pro_id = prefs.getString('pro_id');
      // toast(pro_id);
      print(
          "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/get_product_seller?product_id=$pro_id");
      var response = await http.get(Uri.parse(
          'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/get_product_seller?product_id=$pro_id'));
      final jsonResponse = json.decode(response.body);
      print('not json prpr$jsonResponse');
      productSellerModel = new ProductSellerModel.fromJson(jsonResponse);
      prefs.setString("seller_pic", productSellerModel!.seller!.profile_picture!);
      return productSellerModel;
    } catch (e) {
      print('caught error $e');
    }
  }
  bool? ct_changel=true;

  Future<ProductDetailModel?> fetchDetail() async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? pro_id = prefs.getString('pro_id');
        // toast(pro_id);
        print(
            "https://thriftapp.rcstaging.co.in//wp-json/wc/v3/products/$pro_id");
        var response = await http.get(Uri.parse(
            'https://thriftapp.rcstaging.co.in//wp-json/wc/v3/products/$pro_id'));
        final jsonResponse = json.decode(response.body);
        print('not json prpr$jsonResponse');
        pro_det_model = new ProductDetailModel.fromJson(jsonResponse);
        if (pro_det_model!.attributes!.length > 0) {
          if (pro_det_model!.attributes![0]!.variation == true) {
            if (pro_det_model!.attributes![0]!.name == 'Size') {
              _isSizeVisible = true;
            } else if (pro_det_model!.attributes![0]!.name == 'Color') {
              _isColorVisible = true;
            }
          }
        }
        ct_changel=false;

        // if(pro_det_model.type=='variable'){
        //   fetchVariant();
        // }
        return pro_det_model;
      } catch (e) {
        print('caught error $e');
      }
  }

  Future<GetVariantModel?> fetchVariant(String myurl) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pro_id = prefs.getString('pro_id');
      // toast(pro_id);
      // print(
      //     "https://thriftapp.rcstaging.co.in//wp-json/wc/v3/products/$pro_id");
      var response = await http.get(Uri.parse(myurl));
      final jsonResponse = json.decode(response.body);
      print('not json prpr$jsonResponse');
      EasyLoading.dismiss();
      getVariantModel = new GetVariantModel.fromJson(jsonResponse);

      if (getVariantModel!.data!.variationId == 0) {
        prefs.setString("variant_id", "");
      } else {
        prefs.setString(
            "variant_id", getVariantModel!.data!.variationId.toString());
        // AddCart();
        AddCheckCart();
      }
      // if(pro_det_model.type=='variable'){
      //   fetchVariant();
      // }
      return getVariantModel;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  void _insert() async {
    // row to insert
    if (myvariation_name.length > 2) {
      myvariation_name = myvariation_name.substring(1);
      myvariation_value = myvariation_value.substring(1);
    }
    print(myvariation_name);
    print(myvariation_value);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? variation_id = prefs.getString('variant_id');

    final allRows = await dbHelper.queryAllRows();
    cartPro.clear();
    allRows.forEach((row) => cartPro.add(CartPro.fromJson(row)));
    if ((cartPro.singleWhereOrNull(
          (it) => it.product_id == pro_det_model!.id.toString(),
        )) !=
        null) {
      if (variation_id != '') {
        if ((cartPro.singleWhere((it) => it.variation_id == variation_id,
                orElse: () => null!)) !=
            null) {
          print('Already exists!');
          int chk = 0;
          for (var i = 0; i < cartPro.length; i++) {
            if (cartPro[i].variation_id == variation_id) {
              chk == i;
            }
          }
          int dd = int.parse(cartPro[chk].quantity!) + 1;

          double fnlamnt = double.parse(cartPro[chk].line_subtotal!) *
              double.parse(dd.toString());

          CartPro car = CartPro(
              cartPro[chk].id,
              cartPro[chk].product_id,
              cartPro[chk].product_name,
              cartPro[chk].product_img,
              cartPro[chk].variation_id,
              cartPro[chk].variation_name,
              cartPro[chk].variation_value,
              dd.toString(),
              cartPro[chk].line_subtotal,
              fnlamnt.toString());
          final rowsAffected = await dbHelper.update(car);
        } else {
          print('Added!');
          Map<String, dynamic> row = {
            DatabaseHelper.columnProductId: pro_det_model!.id.toString(),
            DatabaseHelper.columnProductName: pro_det_model!.name.toString(),
            DatabaseHelper.columnProductImage:
                pro_det_model!.images![0]!.src.toString(),
            DatabaseHelper.columnVariationId: variation_id,
            DatabaseHelper.columnVariationName: myvariation_name,
            DatabaseHelper.columnVariationValue: myvariation_value,
            DatabaseHelper.columnQuantity: "1",
            DatabaseHelper.columnLine_subtotal: pro_det_model!.price.toString(),
            DatabaseHelper.columnLine_total: pro_det_model!.price.toString(),
          };
          CartPro car = CartPro.fromJson(row);
          final id = await dbHelper.insert(car);
        }
      } else {
        print('Already exists!');
        int chk = 0;
        for (var i = 0; i < cartPro.length; i++) {
          if (cartPro[i].product_id == pro_det_model!.id.toString()) {
            chk == i;
          }
        }
        int dd = int.parse(cartPro[chk].quantity!) + 1;

        double fnlamnt = double.parse(cartPro[chk].line_subtotal!) *
            double.parse(dd.toString());

        CartPro car = CartPro(
            cartPro[chk].id,
            cartPro[chk].product_id,
            cartPro[chk].product_name,
            cartPro[chk].product_img,
            cartPro[chk].variation_id,
            cartPro[chk].variation_name,
            cartPro[chk].variation_value,
            dd.toString(),
            cartPro[chk].line_subtotal,
            fnlamnt.toString());
        final rowsAffected = await dbHelper.update(car);
      }

      // print('Already exists!');
    } else {
      print('Added!');
      Map<String, dynamic> row = {
        DatabaseHelper.columnProductId: pro_det_model!.id.toString(),
        DatabaseHelper.columnProductName: pro_det_model!.name.toString(),
        DatabaseHelper.columnProductImage:
            pro_det_model!.images![0]!.src.toString(),
        DatabaseHelper.columnVariationId: variation_id,
        DatabaseHelper.columnVariationName: myvariation_name,
        DatabaseHelper.columnVariationValue: myvariation_value,
        DatabaseHelper.columnQuantity: "1",
        DatabaseHelper.columnLine_subtotal: pro_det_model!.price.toString(),
        DatabaseHelper.columnLine_total: pro_det_model!.price.toString(),
      };
      CartPro car = CartPro.fromJson(row);
      final id = await dbHelper.insert(car);
    }

    // Map<String, dynamic> row = {
    //   DatabaseHelper.columnProductId: pro_det_model.id.toString(),
    //   DatabaseHelper.columnProductName: pro_det_model.name.toString(),
    //   DatabaseHelper.columnProductImage: pro_det_model.images[0].src.toString(),
    //   DatabaseHelper.columnVariationId: variation_id,
    //   DatabaseHelper.columnVariation: variation,
    //   DatabaseHelper.columnQuantity: "1",
    //   DatabaseHelper.columnLine_subtotal: pro_det_model.price.toString(),
    //   DatabaseHelper.columnLine_total: pro_det_model.price.toString(),
    // };
    // CartPro car = CartPro.fromJson(row);
    // final id = await dbHelper.insert(car);
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text(
            "Product added to cart",
          ),
          actions: [
            TextButton(
              child: Text("Continue Shopping"),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            TextButton(
              child: Text("View Cart"),
              onPressed: () async{
                Navigator.of(context).pop(ConfirmAction.CANCEL);
//                    launchScreen(context, ShCartScreen.tag);
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
            )
          ],
        );
      },
    );
    // toast('inserted row id: $id');
  }

  Future<ProductDetailModel?> AddCart() async {
//    Dialogs.showLoadingDialog(context, _keyLoader);
    EasyLoading.show(status: 'Please wait...');
    try {
      // String variation_id = '';
      // if (pro_det_model!.attributes!.length > 0) {
      //   if (pro_det_model!.attributes![0]!.variation == true) {
      //     if (pro_det_model!.attributes![0]!.name == 'Size') {
      //       variation_id = pro_det_model!.variations![selectedSize].toString();
      //     } else if (pro_det_model!.attributes![0]!.name == 'Color') {
      //       variation_id = pro_det_model!.variations![selectedColor].toString();
      //     }
      //   }
      // }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      String? variant_id = prefs.getString('variant_id');

      print(token);

      // Response response = await get(
      //     'https://encros.rcstaging.co.in/wp-json/v3/wooapp_add_to_cart?product_id=$pro_id&quantity=1');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final msg = jsonEncode(
          {"quantity": "1", "product_id": pro_id, "variation_id": variant_id});
      print(msg);

      // Response response = await post(
      //     'https://encros.rcstaging.co.in/wp-json/wooapp/v3/wooapp_add_to_cart',
      //     headers: headers,
      //     body: msg);
      var response = await http.post(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/wooapp_add_to_cart'),
          body: msg,
          headers: headers);

      print('Response body: addcart${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        addCartModel = new AddCartModel.fromJson(jsonResponse);
        if (addCartModel!.status == true) {
          setState(() {
            _isVisible = false;
            _isVisible_success = true;
          });
//           showDialog<void>(
//             context: context,
//             barrierDismissible: false, // user must tap button for close dialog!
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text('Success'),
//                 content: Text("Product added to cart"),
//                 actions: [
//                   TextButton(
//                     child: const Text('Continue Shopping'),
//                     onPressed: () {
//                       Navigator.of(context).pop(ConfirmAction.CANCEL);
//                     },
//                   ),
//                   TextButton(
//                     child: const Text('View Cart'),
//                     onPressed: () {
//                       Navigator.of(context).pop(ConfirmAction.CANCEL);
// //                    launchScreen(context, ShCartScreen.tag);
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => CartScreen(),
//                         ),
//                       );
//                     },
//                   )
//                 ],
//               );
//             },
//           );
        } else {
          toast('Something went wrong');
          showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Server Response:'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Msg: ${response.body}'),
                      SizedBox(height: 16),
                    ],
                  ),
                );
              });
        }
      } else {
        toast('Spmething went wrong');
        showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Server Response:'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Msg: ${response.body}'),
                    SizedBox(height: 16),
                  ],
                ),
              );
            });
      }
      return null;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  Future<String?> AddCheckCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String pro_id = prefs.getString('pro_id');
    String? token = prefs.getString('token');

    if (token != null && token != '') {
      AddCart();
    } else {
      _insert();
    }
  }

  Future<CartModel?> fetchCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String pro_id = prefs.getString('pro_id');
      String? token = prefs.getString('token');
      String? user_country = prefs.getString('user_selected_country');

      print(token);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Response response = await get(
      //     Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/woocart'),
      //     headers: headers);
      var response = await http.get(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/woocart?country=$user_country'),
          headers: headers);

      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      cat_model = new CartModel.fromJson(jsonResponse);

      if (cat_model!.cart == null) {
        prefs.setInt("cart_count", 0);
        cart_count==0;
      }else if (cat_model!.cart!.length == 0) {
        prefs.setInt("cart_count", 0);
        cart_count==0;
      }else{

        prefs.setInt("cart_count", cat_model!.cart!.length);
        cart_count==cat_model!.cart!.length;
      }
ct_changel=true;
      _incrementCounter();




      return cat_model;
    } catch (e) {
      print('caught error $e');
      // return cat_model;
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

  _incrementCounter() {
    if(ct_changel!) {
      setState(() {
        ct_changel = false;
        // cart_count = cart_count! + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    void _openCustomDialog3(int index) {

      PageController? _controller2=PageController(initialPage: index, keepPage: true, viewportFraction: 1);
      showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),

          context: context,
          pageBuilder: (context, animation1, animation2) => Scaffold(
              backgroundColor: Colors.black87,
              body: SafeArea(child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller2,
                    itemCount: pro_det_model!.images!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: 0,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: PhotoView(
                                  imageProvider: NetworkImage(pro_det_model!.images![index]!.src!,
                                  ))
                            // Image.network(
                            //     pro_det_model!.images![index]!.src!,
                            //     fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                  new Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: new Container(
                      padding: const EdgeInsets.all(20.0),
                      child: new Center(
                        child: new DotsIndicator(
                          controller: _controller2,
                          itemCount: pro_det_model!.images!.length,
                          onPageSelected: (int page) {
                            _controller2.animateToPage(
                              page,
                              duration: _kDuration,
                              curve: _kCurve,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 26),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: _icon(Icons.close,
                          color: sh_white, size: 15, padding: 12, isOutLine: false),
                    ),
                  )
                ],
              ))
              //Put your screen design here!
          )
      );
    }

    Imagevw4() {
        if (pro_det_model!.images!.length < 1) {
          return
              //   Image.asset(
              //   sh_no_img,
              //   fit: BoxFit.fill,
              //   height: width * 0.34,
              // );
              Image.asset(sh_no_img,
                  width: width, height: 250, fit: BoxFit.fill);
        }
        else {
          return Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: pro_det_model!.images!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _openCustomDialog3(index);
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 0,
                          margin: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: FadeInImage.assetNetwork(
                              placeholder: 'images/tenor.gif',
                              image: pro_det_model!.images![index]!.src!,
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                    ),
                  );
                },
              ),
              new Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: new Container(
                  padding: const EdgeInsets.all(20.0),
                  child: new Center(
                    child: new DotsIndicator(
                      controller: _controller,
                      itemCount: pro_det_model!.images!.length,
                      onPageSelected: (int page) {
                        _controller!.animateToPage(
                          page,
                          duration: _kDuration,
                          curve: _kCurve,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        }

    }

    MyPriceSuccess() {
      // var myprice2 = double.parse(pro_det_model!.price!);
      // var myprice = myprice2.toStringAsFixed(2);
      var myprice2, myprice;
      if (pro_det_model!.price == '') {
        myprice = "0.00";
      } else {
        myprice2 = double.parse(pro_det_model!.price!);
        myprice = myprice2.toStringAsFixed(2);
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "\$" + myprice+ " "+pro_det_model!.currency!,
            style: TextStyle(
                color: sh_black,
                fontFamily: fontBold,
                fontSize: textSizeMedium),
          ),
          SizedBox(
            width: 5,
          ),
          // Text(
          //   "\$" + myprice,
          //   style: TextStyle(
          //       color: sh_red,
          //       fontFamily: fontBold,
          //       fontSize: textSizeSMedium,
          //       decoration: TextDecoration.lineThrough),
          // )
        ],
      );
    }

    Imagevwsuccess() {
        if (_isVisible_success) {
          if (pro_det_model!.images!.length < 1) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(sh_no_img,
                      width: width * .4, height: width * .4, fit: BoxFit.fill),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  pro_det_model!.name!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: sh_colorPrimary2,
                      fontFamily: fontBold,
                      fontSize: textSizeMedium),
                ),
                SizedBox(
                  height: 4,
                ),
                MyPriceSuccess(),
                SizedBox(
                  height: 4,
                ),
                Text(
                  pro_det_model!.slug!,
                  maxLines: 2,
                  style: TextStyle(
                      color: sh_textColorSecondary,
                      fontFamily: "SemiBold",
                      fontSize: textSizeSMedium),
                )
              ],
            );
          }
          else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    pro_det_model!.images![0]!.src!,
                    fit: BoxFit.cover,
                    width: width * .4,
                    height: width * .4,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Wrap(
                  children: [Column(

                    children: [
                      Text(
                        pro_det_model!.name!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: sh_colorPrimary2,
                            fontFamily: fontBold,
                            fontSize: textSizeMedium),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      MyPriceSuccess(),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        pro_det_model!.slug!,
                        maxLines: 2,
                        style: TextStyle(
                            color: sh_textColorSecondary,
                            fontFamily: "SemiBold",
                            fontSize: textSizeSMedium),
                      )
                    ],
                  )],
                ),

              ],
            );
          }
        } else {
          return Container();
        }
    }

    Widget _productImage() {
      return Stack(
        children: <Widget>[
          SizedBox(
            height: 250,
            child: Column(
              children: <Widget>[
                Expanded(child: Imagevw4()),
                // Scrollindic()
              ],
            ),
          ),

        ],
      );
    }

    MyPrice() {
      // var myprice2 = double.parse(pro_det_model!.price!);
      // var myprice = myprice2.toStringAsFixed(2);
      var myprice2, myprice;
      if (pro_det_model!.price == '') {
        myprice = "0.00";
      } else {
        myprice2 = double.parse(pro_det_model!.price!);
        myprice = myprice2.toStringAsFixed(2);
      }

      return Row(
        children: [
          Text(
            "\$" + myprice+ " "+pro_det_model!.currency!,
            style: TextStyle(
                color: sh_black,
                fontFamily: fontBold,
                fontSize: textSizeLargeMedium),
          ),
          // SizedBox(
          //   width: 5,
          // ),
          // Text(
          //   "\$" + myprice,
          //   style: TextStyle(
          //       color: sh_red,
          //       fontFamily: fontBold,
          //       fontSize: textSizeSMedium,
          //       decoration: TextDecoration.lineThrough),
          // )
        ],
      );
    }

    CheckVariant() {
      if (pro_det_model!.variations!.length > 0) {
        return Container(
          child: ListView.builder(
              itemCount: pro_det_model!.attributes!.length,
              physics: NeverScrollableScrollPhysics(),
              // itemExtent: 50.0,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                itModel = MyVariant(
                    attr_name: pro_det_model!.attributes![index]!.name!,
                    attr_optn: "");
                itemsModel.add(itModel!);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      pro_det_model!.attributes![index]!.name!,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'ExtraBold',
                          color: sh_colorPrimary2),
                    ),
                    SizedBox(height: 20),
                    PlayerWidget(
                        pro_det_model: pro_det_model!,
                        index: index,
                        itemsModel: itemsModel),
                    // DropdownButton(
                    //   underline: SizedBox(),
                    //   isExpanded: true,
                    //   items: pro_det_model!.attributes![index]!.options!
                    //       .map((item) {
                    //     return new DropdownMenuItem(
                    //       child: Text(
                    //         item.toString(),
                    //         style: TextStyle(
                    //             color: sh_textColorPrimary,
                    //             fontFamily: fontRegular,
                    //             fontSize: textSizeNormal),
                    //       ),
                    //       value: item,
                    //     );
                    //   }).toList(),
                    //   hint: Text('Select'),
                    //   value: selectedValue,
                    //   onChanged: (String? newVal) {
                    //     selectedValue = newVal!;
                    //     setState(() {});
                    //   },
                    // ),
                  ],
                );
              }),
        );
      } else {
        int? my_index=-1;
        for (var i = 0; i < pro_det_model!.metaData!.length; i++) {
          if(pro_det_model!.metaData![i]!.key=="attrs_val"){
            my_index=i;
          }
        }

        if(my_index==-1){
          return ListView.builder(
              itemCount: pro_det_model!.metaData!.length,
              physics: NeverScrollableScrollPhysics(),
              // itemExtent: 50.0,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {


                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      pro_det_model!.metaData![index]!.key!,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Bold',
                          color: sh_colorPrimary2),
                    ),
                    SizedBox(height: 4),
                    Text(
                      pro_det_model!.metaData![index]!.value!,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'SemiBold',
                          color: sh_black),
                    ),
                    SizedBox(height: 20),

                  ],
                );
              });
        }else{
          return ListView.builder(
              itemCount: pro_det_model!.metaData![my_index!]!.value!.length,
              physics: NeverScrollableScrollPhysics(),
              // itemExtent: 50.0,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {


                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      pro_det_model!.metaData![my_index!]!.value![index]!.key!,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Bold',
                          color: sh_colorPrimary2),
                    ),
                    SizedBox(height: 4),
                    Text(
                      pro_det_model!.metaData![my_index]!.value![index]!.value!,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'SemiBold',
                          color: sh_black),
                    ),
                    SizedBox(height: 20),

                  ],
                );
              });
        }

      }
    }

    BadgeCount(){
      if(cart_count==0){
        return Image.asset(
          sh_new_cart,
          height: 50,
          width: 50,
          fit: BoxFit.fill,
          color: sh_white,
        );
      }
      else{
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

    RefreshCount(){
     return FutureBuilder<String?>(
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
      );

    }

    SuccesVisiblity() {
      if(_isVisible_success){
       return  Visibility(
           visible: _isVisible_success,
           child: Container(
             height: height,
             width: width,
             margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
             padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
             color: sh_white,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(
                       Icons.check_circle_outline,
                       color: sh_colorPrimary2,
                       size: 30,
                     ),
                     SizedBox(
                       width: 8,
                     ),
                     Text(
                       "Added To Cart!",
                       style: TextStyle(
                           color: sh_colorPrimary2,
                           fontSize: 24,
                           fontFamily: "Bold"),
                     )
                   ],
                 ),
                 SizedBox(
                   height: 20,
                 ),
                 Imagevwsuccess(),

                 SizedBox(
                   height: 20,
                 ),
                 Container(
                   height: 0.5,
                   color: sh_app_txt_color,
                 ),
                 SizedBox(
                   height: 12,
                 ),
                 FutureBuilder<CartModel?>(
                     future: fetchCart(),
                     builder: (context, snapshot) {
                       if (snapshot.hasData) {

                         var myprice2 =double.parse(cat_model!.total.toString());
                         var myprice = myprice2.toStringAsFixed(2);
                         return Column(
                           children: [
                             Row(
                               children: [
                                 Text(
                                   "You have ",
                                   style: TextStyle(
                                       color: sh_colorPrimary2,
                                       fontSize: 15,
                                       fontFamily: "Bold"),
                                 ),
                                 Text(
                                   cat_model!.cart!.length.toString()+" Item ",
                                   style: TextStyle(
                                       color: sh_black, fontSize: 15, fontFamily: "Bold"),
                                 ),
                                 Text(
                                   "in your cart",
                                   style: TextStyle(
                                       color: sh_colorPrimary2,
                                       fontSize: 15,
                                       fontFamily: "Bold"),
                                 ),
                               ],
                             ),
                             SizedBox(
                               height: 6,
                             ),
                             Row(
                               children: [
                                 Text(
                                   "Cart Total: ",
                                   style: TextStyle(
                                       color: sh_colorPrimary2,
                                       fontSize: 15,
                                       fontFamily: "Bold"),
                                 ),
                                 Text(
                                   "\$"+myprice+ " "+pro_det_model!.currency!,
                                   style: TextStyle(
                                       color: sh_black, fontSize: 15, fontFamily: "Bold"),
                                 ),
                               ],
                             ),
                           ],
                         );
                       } else if (snapshot.hasError) {
//                    return Text("${snapshot.error}");
                         return Center(
                             child: Container(
                               alignment: Alignment.center,
                               child: Text(
                                 'Your Cart is currently empty',
                                 style: TextStyle(
                                     fontSize: 16,
                                     color: sh_textColorPrimary,
                                     fontWeight: FontWeight.bold),
                               ),
                             ));
                       }
                       // By default, show a loading spinner.
                       return Center(child: CircularProgressIndicator());
                     }),

                 SizedBox(
                   height: 40,
                 ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     InkWell(
                       onTap: () async {

                         Navigator.pop(context);
                       },
                       child: Container(
                         padding: EdgeInsets.all(spacing_standard),
                         decoration: boxDecoration(
                             bgColor: sh_btn_color,
                             radius: 6,
                             showShadow: true),
                         child: text("Continue Shopping",
                             textColor: sh_colorPrimary2,
                             isCentered: true,
                             fontSize: 12.0,
                             fontFamily: 'Bold'),
                       ),
                     ),
                     InkWell(
                       onTap: () async {
                         Navigator.of(context).pop(ConfirmAction.CANCEL);
                         SharedPreferences prefs = await SharedPreferences.getInstance();
                         prefs.setInt("shiping_index", -2);
                         prefs.setInt("payment_index", -2);
                         // launchScreen(context, CartScreen.tag);
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                               builder: (context) =>
                                   CartScreen()),).then((value) {   setState(() {
                           // refresh state
                         });});
                         //   Navigator.pushReplacement(
                         // context,
                         // MaterialPageRoute(
                         //   builder: (context) => CartScreen(),
                         // ),
                         // );
                       },
                       child: Container(
                         padding: EdgeInsets.all(spacing_standard),
                         decoration: boxDecoration(
                             bgColor: sh_colorPrimary2,
                             radius: 6,
                             showShadow: true),
                         child: text("Cart/Checkout",
                             textColor: sh_white,
                             isCentered: true,
                             fontSize: 12.0,
                             fontFamily: 'Bold'),
                       ),
                     ),
                   ],
                 )
               ],
             ),
           ));
      }else{
        return Container();
      }

    }


    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: sh_colorPrimary2));

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Product Details",
          style: TextStyle(color: sh_white),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setInt("shiping_index", -2);
                  prefs.setInt("payment_index", -2);
                  // launchScreen(context, CartScreen.tag);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CartScreen()),).then((value) {   setState(() {
                    // refresh state
                  });});
                },
                child: RefreshCount(),

              ),
              SizedBox(width: 16,)
            ],
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
        Visibility(
          visible: _isVisible,
          child: Container(
            height: height,
            margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
            color: sh_white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 9,
                  child: SingleChildScrollView(
                    child: Container(
                      width: width,
                      child: FutureBuilder<ProductDetailModel?>(
                        future: fetchDetailMain,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              width: width,
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Stack(
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Stack(
                                        children: [_productImage()],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Container(
                                        height: 0.5,
                                        color: sh_textColorSecondary,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            pro_det_model!.name!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: sh_colorPrimary2,
                                                fontFamily: fontBold,
                                                fontSize: textSizeNormal),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          MyPrice(),

                                          SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            pro_det_model!.slug!,
                                            maxLines: 2,
                                            style: TextStyle(
                                                color: sh_textColorSecondary,
                                                fontFamily: "SemiBold",
                                                fontSize: textSizeMedium),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          // CheckVariant()
                                        ],
                                      ),

                                      SizedBox(
                                        height: 18,
                                      ),
                                      CheckVariant(),

                                      // _availableSize(),
                                      // SizedBox(
                                      //   height: 20,
                                      // ),
                                      // _availableColor(),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Description",
                                            maxLines: 2,
                                            style: TextStyle(
                                                color: sh_colorPrimary2,
                                                fontFamily: fontBold,
                                                fontSize: textSizeLargeMedium),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Html(
                                            data: pro_det_model!.description,
                                            style: {
                                              "body": Style(color: sh_black),
                                            },
                                          ),
                                        ],
                                      ),

                                      SizedBox(
                                        height: 8,
                                      ),
                                      Container(
                                        height: 0.5,
                                        color: sh_app_txt_color,
                                      ),
                                      SizedBox(
                                        height: 26,
                                      ),
                                      FutureBuilder<ProductSellerModel?>(
                                        future: fetchSellerMain,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Container(
                                              child: InkWell(
                                                onTap: () async{
                                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                                  prefs.setString("seller_id", productSellerModel!.seller!.sellerId.toString());
                                                  prefs.setString("seller_name", productSellerModel!.seller!.firstName![0].toString()+" "+productSellerModel!.seller!.lastName![0].toString());
                                                  launchScreen(context, SellerProfileScreen.tag);
                                                },
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Seller",
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              color: sh_colorPrimary2,
                                                              fontFamily: fontBold,
                                                              fontSize: 16),
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Text(
                                                              "View Profile",
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  color: sh_black,
                                                                  fontFamily: "Bold",
                                                                  fontSize: 14),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                            padding: const EdgeInsets.all(2.0),
                                                            child: productSellerModel!.seller!.profile_picture == null
                                                                ? CircleAvatar(
                                                              // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
                                                              backgroundImage: NetworkImage(
                                                                  "https://firebasestorage.googleapis.com/v0/b/sureloyalty-24e2a.appspot.com/o/nophoto.jpg?alt=media&token=cd6972d8-f794-4951-9c7a-b02cd2bc6366"
                                                                  ),
                                                              radius: 22,
                                                            )
                                                                : CircleAvatar(
                                                              // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
                                                              backgroundImage: NetworkImage(productSellerModel!.seller!.profile_picture!),
                                                              radius: 22,
                                                            )),
                                                        // Icon(
                                                        //   Icons.circle,
                                                        //   color: sh_grey,
                                                        //   size: 40,
                                                        // ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                            productSellerModel!.seller!.firstName![0]!.toString()+" "+productSellerModel!.seller!.lastName![0]!.toString(),
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              color: sh_colorPrimary2,
                                                              fontFamily: fontBold,
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text("${snapshot.error}");
                                          }
                                          // By default, show a loading spinner.
                                          return CircularProgressIndicator();
                                        },
                                      ),



                                      SizedBox(
                                        height: 36,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          String? pro_id =
                                              prefs.getString('pro_id');
                                          if (pro_det_model!
                                                  .variations!.length >
                                              0) {
                                            int selval = 0;
                                            String mygsss = '';

                                            for (var i = 0;
                                                i < itemsModel.length;
                                                i++) {
                                              if (itemsModel[i].attr_optn ==
                                                  '') {
                                                selval = 1;
                                              } else {
                                                mynames = "&attributes[" +
                                                    pro_det_model!
                                                        .attributes![i]!.name! +
                                                    "]=";

//                     print(itemsModel[i].attr_name);
// print(itemsModel[i].attr_optn);

                                                mygsss = mygsss +
                                                    mynames +
                                                    itemsModel[i].attr_optn!;
                                                myvariation_name =
                                                    myvariation_name +
                                                        "," +
                                                        pro_det_model!
                                                            .attributes![i]!
                                                            .name!;
                                                myvariation_value =
                                                    myvariation_value +
                                                        "," +
                                                        itemsModel[i]
                                                            .attr_optn!;
                                              }
                                            }
                                            if (selval == 1) {
                                              mygsss = '';
                                              toast("select value");
                                            } else {
                                              print(
                                                  'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/get_product_variation_id/?product_id=$pro_id' +
                                                      mygsss);
                                              fetchVariant(
                                                  'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/get_product_variation_id/?product_id=$pro_id' +
                                                      mygsss);

                                              // toast("Proceed");
                                            }
                                          } else {
                                            prefs.setString("variant_id", "");
                                            // AddCart();
                                            AddCheckCart();
                                          }
                                          // AddCheckCart();
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.only(
                                              top: spacing_middle,
                                              bottom: spacing_middle),
                                          decoration: boxDecoration(
                                              bgColor: sh_app_background,
                                              radius: 10,
                                              showShadow: true),
                                          child: text("Add to Cart",
                                              textColor: sh_app_txt_color,
                                              isCentered: true,
                                              fontFamily: 'Bold'),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 18,
                                      ),
                                    ],
                                  ),
//                        _detailWidget()
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          // By default, show a loading spinner.
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            direction: ShimmerDirection.ltr,
                            child: Container(
                              width: width,
                              padding: EdgeInsets.fromLTRB(12,12,12,12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 250,
                                    child: Column(
                                      children: <Widget>[
                                        Container(                                            width: double.infinity,
                                          height: 200.0,

                                          color: Colors.white,),
                                        // Scrollindic()
                                      ],
                                    ),
                                  ),
                                  Container(
                                      child: InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              18.0, 0, 12, 12),
                                          child:                             Container(
                                            width: width*.40,
                                            height: 12.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),
                                  SizedBox(height: 4,),
                                  Container(
                                      child: InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              18.0, 12, 12, 12),
                                          child:                             Container(
                                            width: width*.30,
                                            height: 12.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),
                                  SizedBox(height: 4,),
                                  Container(
                                      child: InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              18.0, 12, 12, 12),
                                          child:                             Container(
                                            width: width*.35,
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
                                              18.0, 12, 12, 12),
                                          child:                             Container(
                                            width: width*.20,
                                            height: 12.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),
                                  SizedBox(height: 4,),
                                  Container(
                                      child: InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              18.0, 12, 12, 12),
                                          child:                             Container(
                                            width: width,
                                            height: 62.0,
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
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: bottomButtons(sh_white),
                // )
              ],
            ),
          ),
        ),

        SuccesVisiblity(),

        // Positioned to take only AppBar size
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0,18,0,0),
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
                      child: Text("Product Details",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Cursive'),),
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
                        // launchScreen(context, CartScreen.tag);
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
      body: WillPopScope(
          onWillPop: _onWillPop,
          child: SafeArea(child: setUserForm())),
    );
  }
}

Widget _icon(IconData icon,
    {Color color = iconColor,
    double size = 20,
    double padding = 10,
    bool isOutLine = false}) {
  return Container(
    height: 40,
    width: 40,
    padding: EdgeInsets.all(padding),
    // margin: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      border: Border.all(
          color: iconColor,
          style: isOutLine ? BorderStyle.solid : BorderStyle.none),
      borderRadius: BorderRadius.all(Radius.circular(30)),
      color: sh_dots_color,
    ),
    child: Icon(icon, color: color, size: size),
  );
}

class Similar extends StatelessWidget {
  ProductListModel? model;
  Color? sh_app_black, sh_red, sh_textColorSecondary;

  Similar(ProductListModel model, int pos, Color sh_app_black, Color sh_red,
      Color sh_textColorSecondary) {
    this.model = model;
    this.sh_app_black = sh_app_black;
    this.sh_red = sh_red;
    this.sh_textColorSecondary = sh_textColorSecondary;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    Imagevw4() {
      if (model!.images!.length < 1) {
        return Image.asset(
          sh_no_img,
          fit: BoxFit.fill,
          height: width * 0.34,
        );
      } else {
        return Image.network(
          model!.images![0]!.src!,
          fit: BoxFit.fill,
          height: width * 0.34,
          width: width,
        );
      }
    }

    NewImagevw() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Imagevw4(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: <Widget>[
              //     Container(
              //       height: 40,
              //       width: 40,
              //       padding: EdgeInsets.only(
              //           left: spacing_control, right: spacing_control),
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.all(Radius.circular(30)),
              //         color: sh_dots_color.withOpacity(0.5),
              //       ),
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

    SimilarPrice() {
      // var myprice2 = double.parse(model!.price!);
      // var myprice = myprice2.toStringAsFixed(2);
      var myprice2, myprice;
      if (model!.price == '') {
        myprice = "0.00";
      } else {
        myprice2 = double.parse(model!.price!);
        myprice = myprice2.toStringAsFixed(2);
      }

      return Row(
        children: [
          Text(
            "\$" + myprice,
            style: TextStyle(
                color: sh_app_black,
                fontFamily: fontBold,
                fontSize: textSizeSMedium),
          ),
          // SizedBox(
          //   width: 5,
          // ),
          // Text(
          //   "\$" + myprice,
          //   style: TextStyle(
          //       color: sh_red,
          //       fontFamily: fontBold,
          //       fontSize: textSizeSmall,
          //       decoration: TextDecoration.lineThrough),
          // )
        ],
      );
    }

    return GestureDetector(
      onTap: () async {
//        callNext(GroceryProductDescription(), context);
//        SharedPreferences prefs = await SharedPreferences.getInstance();
//        prefs.setString('pro_id', model.id.toString());
//        Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (context) => SCProductDetailScreen(product: product)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.44,
        decoration: boxDecoration4(showShadow: true),
        margin: EdgeInsets.only(bottom: 10, right: 10),
        padding: EdgeInsets.fromLTRB(0, 0, 0, spacing_control_half),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: <Widget>[
            //     Container(
            //       padding: EdgeInsets.only(
            //           left: spacing_control, right: spacing_control),
            //       decoration: boxDecoration(
            //         radius: spacing_control,
            //       ),
            //     ),
            //     Icon(
            //       Icons.favorite_border,
            //       color: sh_textColorSecondary,
            //     )
            //   ],
            // ),
            // SizedBox(
            //   height: 4,
            // ),
            // Imagevw(),
            NewImagevw(),
            SizedBox(
              height: 6,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: spacing_standard, right: spacing_standard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  text(model!.slug,
                      fontFamily: fontMedium,
                      textColor: sh_textColorSecondary,
                      fontSize: textSizeSmall),
                  // Descrptntext(index),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    model!.name!,
                    maxLines: 2,
                    style: TextStyle(
                        color: sh_app_black,
                        fontFamily: fontBold,
                        fontSize: textSizeMedium),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  SimilarPrice(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  final ProductDetailModel? pro_det_model;
  final int? index;
  final List<MyVariant>? itemsModel;

  PlayerWidget({Key? key, this.pro_det_model, this.index, this.itemsModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String? selectedItemValue = null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var _value = widget.pro_det_model!.attributes![widget.index!]!.options!.isEmpty
    //     ? selectedItemValue
    //     : widget.pro_det_model!.attributes![widget.index!]!.options!.firstWhere((item) => item.toString() == selectedItemValue.toString());

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState2) {
      return DropdownButton(
        iconEnabledColor: sh_app_txt_color,
        underline: SizedBox(),
        isExpanded: true,
        items: widget.pro_det_model!.attributes![widget.index!]!.options!
            .map((item) {
          return new DropdownMenuItem(
            child: Text(
              item.toString(),
              style: TextStyle(
                  color: sh_black,
                  fontFamily: fontRegular,
                  fontSize: textSizeNormal),
            ),
            value: item,
          );
        }).toList(),
        hint: Text(
          'Select',
          style: TextStyle(color: sh_black),
        ),
        value: selectedItemValue,
        onChanged: (String? newVal) {
          setState2(() {
            selectedItemValue = newVal!;
            widget.itemsModel![widget.index!].attr_optn = newVal;
          });
        },
      );
    });
  }
}

/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {
  final PageController? controller;

  /// The number of items managed by the PageController
  final int? itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int>? onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color? color;

  // The base size of the dots
  static const double? _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double? _kMaxZoom = 1.8;

  // The distance between the center of each dot
  static const double? _kDotSpacing = 20.0;

  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: sh_colorPrimary2,
  }) : super(listenable: controller!);

  /// The PageController that this DotsIndicator is representing.

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller!.page ?? controller!.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom! - 1.0) * selectedness;
    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: color,
          type: MaterialType.circle,
          child: new Container(
            width: _kDotSize! * zoom,
            height: _kDotSize! * zoom,
            child: new InkWell(
              onTap: () => onPageSelected!(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount!, _buildDot),
    );
  }
}
