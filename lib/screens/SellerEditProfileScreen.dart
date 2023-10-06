import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrift/model/ViewProModel.dart';
import 'package:thrift/utils/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/ProductDetailModel.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:thrift/model/ProductListSellerModel.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:thrift/model/ReviewModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/ProductDetailScreen.dart';
import 'package:thrift/screens/ProductUpdateScreen.dart';
import 'package:thrift/screens/ProfileScreen.dart';
import 'package:thrift/screens/SellerReviewScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

import '../provider/profile_provider.dart';
import '../provider/seller_profile_provider.dart';

class ItemModel {
  String title;

  ItemModel(this.title);
}

class SellerEditProfileScreen extends StatefulWidget {
  static String tag = '/SellerEditProfileScreen';

  const SellerEditProfileScreen({Key? key}) : super(key: key);

  @override
  _SellerEditProfileScreenState createState() =>
      _SellerEditProfileScreenState();
}

class _SellerEditProfileScreenState extends State<SellerEditProfileScreen> {
  late List<ItemModel> menuItems;
  CustomPopupMenuController _controller = CustomPopupMenuController();

  final double runSpacing = 4;
  final double spacing = 4;
  final columns = 2;

  // List<ProductListModel> productListModel = [];
  // ProductListSellerModel? productListModel;
  // ProfileModel? profileModel;
  String? seller_name, seller_id, profile_name;
  String? filter_str = 'Newest to Oldest';

  // ReviewModel? reviewModel;
  // String fnl_img = 'https://secure.gravatar.com/avatar/598b1f668254d0f7097133846aa32daf?s=96&d=mm&r=g';
  // ViewProModel? viewProModel;

  int? cart_count;

  // Future<ViewProModel?>? ViewProfilePicMain;

  @override
  void initState() {
    menuItems = [
      ItemModel('Newest to Oldest'),
      ItemModel('Oldest to Newest'),
      ItemModel('Price High to Low'),
      ItemModel('Price Low to High'),
    ];
    final postMdl = Provider.of<SellerProfileProvider>(context, listen: false);
    postMdl.getProduct('Newest to Oldest');

    final pro_provider = Provider.of<ProfileProvider>(context, listen: false);
    pro_provider.getReview();
    pro_provider.getProfile();
    pro_provider.getProfilePic();
    super.initState();
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

  Future<String?> ChangeReserve(String reserver, String pro_id) async {
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

      final msg = jsonEncode({"product_id": pro_id});
      print(msg);
      Response response;
      if (reserver == "Reserved") {
        response = await post(
            Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/mark_as_reserved'),
            headers: headers,
            body: msg);
      } else {
        response = await post(
            Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/mark_as_unreserved'),
            headers: headers,
            body: msg);
      }
      print(
          'SellerEditProfileScreen mark_as_unreserved Response status2: ${response.statusCode}');
      print(
          'SellerEditProfileScreen mark_as_unreserved Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);

      // setState(() {
      //
      // });
      final postMdl =
          Provider.of<SellerProfileProvider>(context, listen: false);
      postMdl.getProduct(filter_str);
      // couponModel = new CouponModel.fromJson(jsonResponse);

      EasyLoading.dismiss();

      // } else {
      //   couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
      //   toast(couponErrorModel.error);
      // }
      return "couponModel";
    } on Exception catch (e) {
      print('caught error $e');
    }
  }

  Future<String?> ChangeSold(String pro_id) async {
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

      final msg = jsonEncode({"product_id": pro_id});
      print(msg);
      Response response = await post(
          Uri.parse('${Url.BASE_URL}wp-json/wooapp/v3/mark_as_sold'),
          headers: headers,
          body: msg);

      print(
          'SellerEditProfileScreen mark_as_sold Response status2: ${response.statusCode}');
      print(
          'SellerEditProfileScreen mark_as_sold Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);

      EasyLoading.dismiss();
      // setState(() {
      //
      // });
      final postMdl =
          Provider.of<SellerProfileProvider>(context, listen: false);
      postMdl.getProduct(filter_str);

      // couponModel = new CouponModel.fromJson(jsonResponse);

      // } else {
      //   couponErrorModel = new CouponErrorModel.fromJson(jsonResponse);
      //   toast(couponErrorModel.error);
      // }
      return "couponModel";
    } on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }

  Future<String?> fetchDelete(String pro_id) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? pro_id = prefs.getString('pro_id');
      toast(pro_id);
      print("${Url.BASE_URL}wp-json/wc/v3/products/$pro_id");
      var response = await http
          .delete(Uri.parse('${Url.BASE_URL}wp-json/wc/v3/products/$pro_id'));
      final jsonResponse = json.decode(response.body);
      print(
          'SellerEditProfileScreen products Response status2: ${response.statusCode}');
      print(
          'SellerEditProfileScreen products Response body2: ${response.body}');
      // pro_det_model = new ProductDetailModel.fromJson(jsonResponse);
      EasyLoading.dismiss();
      // setState(() {
      //
      // });
      final postMdl =
          Provider.of<SellerProfileProvider>(context, listen: false);
      postMdl.getProduct(filter_str);
      // if(pro_det_model.type=='variable'){
      //   fetchVariant();
      // }
      return "pro_det_model";
    } on Exception catch (e) {
      EasyLoading.dismiss();

      print('caught error $e');
    }
  }

  Future<String?> fetchadd() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      seller_name = prefs.getString('seller_name');
      seller_id = prefs.getString('seller_id');
      profile_name = prefs.getString("profile_name");
      return '';
    } catch (e) {
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

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

    Imagevw4(int index, productListModel) {
      if (productListModel!.products![index]!.data!.images!.length < 1) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                sh_no_img,
                fit: BoxFit.cover,
                height: width * 0.28,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(
                        'seller_pro_id',
                        productListModel!.products![index]!.data!.id
                            .toString());
                    // launchScreen(context, ProductUpdateScreen.tag);
                    // Navigator.pushNamed(context, ProductUpdateScreen.tag).then((_) => setState(() {}));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductUpdateScreen()),
                    ).then((_) {
                      final postMdl = Provider.of<SellerProfileProvider>(context, listen: false);
                      postMdl.getProduct('Newest to Oldest');
                    } );
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: boxDecoration(
                        bgColor: Colors.black.withOpacity(0.4),
                        radius: 4,
                        showShadow: true),
                    child: text(
                        productListModel!.products![index]!.data!.stockStatus ==
                                "instock"
                            ? "EDIT"
                            : "VIEW",
                        textColor: sh_white,
                        fontSize: 12.0,
                        isCentered: true,
                        fontFamily: 'Bold'),
                  ),
                ),
              ),
            )
          ],
        );
      } else {
        return Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(spacing_middle)),
                child: CachedNetworkImage(
                  imageUrl:
                      productListModel!.products![index]!.data!.images![0]!.src!,
                  fit: BoxFit.fill,
                  height: width * 0.28,
                  // width: width,
                  // memCacheWidth: width,
                  filterQuality: FilterQuality.low,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(
                        'seller_pro_id',
                        productListModel!.products![index]!.data!.id
                            .toString());
                    // launchScreen(context, ProductUpdateScreen.tag);
                    // Navigator.pushNamed(context, ProductUpdateScreen.tag).then((_) => setState(() {}));
                    // SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString(
                        'pro_id',
                        productListModel!.products![index]!.data!.id
                            .toString());
                    List<String> myimages = [];
                    for (var i = 0;
                        productListModel!
                                .products![index]!.data!.images!.length >
                            i;
                        i++) {
                      myimages.add(productListModel!
                          .products![index]!.data!.images![i]!.src!);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => productListModel!
                                      .products![index]!.data!.stockStatus ==
                                  "instock"
                              ? ProductUpdateScreen()
                              : ProductDetailScreen(
                                  proName: productListModel!
                                      .products![index]!.data!.name,
                                  proPrice: productListModel!
                                      .products![index]!.data!.price,
                                  proImage: myimages)),
                    ).then((_) => setState(() {}));
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: boxDecoration(
                        bgColor: Colors.black.withOpacity(0.4),
                        radius: 4,
                        showShadow: true),
                    child: text(
                        productListModel!.products![index]!.data!.stockStatus ==
                                "instock"
                            ? "EDIT"
                            : "VIEW",
                        textColor: sh_white,
                        fontSize: 12.0,
                        isCentered: true,
                        fontFamily: 'Bold'),
                  ),
                ),
              ),
            )
          ],
        );
      }
    }

    NewImagevw(int index, productListModel) {
      return Imagevw4(index, productListModel);
    }

    MyPrice(int index, productListModel) {
      var myprice2, myprice;
      if (productListModel!.products![index]!.data!.price == '') {
        myprice = '0.00';
      } else {
        myprice2 =
            double.parse(productListModel!.products![index]!.data!.price!);
        myprice = myprice2.toStringAsFixed(2);
      }
      return Row(
        children: [
          Text(
            "\$" + myprice,
            style: TextStyle(
                color: sh_black,
                fontFamily: fontSemibold,
                fontSize: textSizeSMedium),
          ),
        ],
      );
    }

    void _openCustomDialogReserve(String reserver, String prod_id) {
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
                    'Mark this listing as $reserver?',
                    style: TextStyle(
                        color: sh_colorPrimary2,
                        fontSize: 18,
                        fontFamily: 'Bold'),
                    textAlign: TextAlign.center,
                  )),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: () async {
                          // BecameSeller();
                          Navigator.of(context, rootNavigator: true).pop();
                          ChangeReserve(reserver, prod_id);
                          // _openCustomDialog2();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.only(top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2,
                              radius: 10,
                              showShadow: true),
                          child: text("Confirm",
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
                    'Mark this listing as sold?',
                    style: TextStyle(
                        color: sh_colorPrimary2,
                        fontSize: 18,
                        fontFamily: 'Bold'),
                    textAlign: TextAlign.center,
                  )),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: () async {
                          // BecameSeller();
                          Navigator.of(context, rootNavigator: true).pop();
                          ChangeSold(prod_id);
                          // _openCustomDialog2();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.only(top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2,
                              radius: 10,
                              showShadow: true),
                          child: text("Confirm",
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

    void _openCustomDialogDelete(String prod_id) {
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
                    'Do you want to delete this listing?',
                    style: TextStyle(
                        color: sh_colorPrimary2,
                        fontSize: 18,
                        fontFamily: 'Bold'),
                    textAlign: TextAlign.center,
                  )),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: () async {
                          // BecameSeller();
                          Navigator.of(context, rootNavigator: true).pop();
                          fetchDelete(prod_id);
                          // _openCustomDialog2();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.only(top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2,
                              radius: 10,
                              showShadow: true),
                          child: text("Confirm",
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

    CheckSoldReserve2(int index, productListModel) {
      if (productListModel!.products![index]!.data!.status != "publish" &&
          productListModel!.products![index]!.data!.stockStatus != "instock") {
        return Row(
          children: [
            Container(
              height: 16,
              width: 16,
              // padding: EdgeInsets.all(4.0),
              decoration: boxDecoration(
                  bgColor: myorange2, radius: 4, showShadow: true),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: text("R",
                        fontSize: 9.0,
                        textColor: sh_white,
                        isCentered: true,
                        fontFamily: fontBold),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 6,
            ),
            Container(
              height: 16,
              width: 16,
              // padding: EdgeInsets.all(4.0),
              decoration:
                  boxDecoration(bgColor: sh_red, radius: 4, showShadow: true),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: text("S",
                        fontSize: 9.0,
                        textColor: sh_white,
                        isCentered: true,
                        fontFamily: fontBold),
                  ),
                ],
              ),
            )
          ],
        );
      } else {
        if (productListModel!.products![index]!.data!.status != "publish") {
          return Container(
            height: 16,
            width: 16,
            // padding: EdgeInsets.all(4.0),
            decoration:
                boxDecoration(bgColor: myorange2, radius: 4, showShadow: true),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: text("R",
                      fontSize: 9.0,
                      textColor: sh_white,
                      isCentered: true,
                      fontFamily: fontBold),
                ),
              ],
            ),
          );
        } else if (productListModel!.products![index]!.data!.stockStatus !=
            "instock") {
          return Container(
            height: 16,
            width: 16,
            // padding: EdgeInsets.all(4.0),
            decoration:
                boxDecoration(bgColor: sh_red, radius: 4, showShadow: true),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: text("S",
                      fontSize: 9.0,
                      textColor: sh_white,
                      isCentered: true,
                      fontFamily: fontBold),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      }
    }

    CheckReserve(int index, productListModel) {
      if (productListModel!.products![index]!.data!.status == "publish") {
        return InkWell(
          onTap: () async {
            // BecameSeller();
            _openCustomDialogReserve("Reserved",
                productListModel!.products![index]!.data!.id.toString());
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: boxDecoration(
                bgColor: sh_btn_color, radius: 6, showShadow: true),
            child: text("Reserve",
                fontSize: 12.0,
                textColor: sh_colorPrimary2,
                isCentered: true,
                fontFamily: fontSemibold),
          ),
        );
      } else {
        return InkWell(
          onTap: () async {
            // BecameSeller();
            _openCustomDialogReserve("Unreserved",
                productListModel!.products![index]!.data!.id.toString());
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: boxDecoration(
                bgColor: sh_btn_color, radius: 6, showShadow: true),
            child: text("Unreserve",
                fontSize: 12.0,
                textColor: sh_colorPrimary2,
                isCentered: true,
                fontFamily: fontSemibold),
          ),
        );
      }
    }

    CheckSold(int index, productListModel) {
      if (productListModel!.products![index]!.data!.stockStatus == "instock") {
        return InkWell(
          onTap: () async {
            // BecameSeller();
            _openCustomDialogSold(
                productListModel!.products![index]!.data!.id.toString());
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: boxDecoration(
                bgColor: sh_btn_color, radius: 6, showShadow: true),
            child: text("Sold",
                fontSize: 12.0,
                textColor: sh_colorPrimary2,
                isCentered: true,
                fontFamily: fontSemibold),
          ),
        );
      } else {
        return InkWell(
          onTap: () async {
            // BecameSeller();
            // _openCustomDialogSold(productListModel[index].id.toString());
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
            decoration: boxDecoration(
                bgColor: sh_colorPrimary2, radius: 6, showShadow: true),
            child: text("Sold",
                fontSize: 12.0,
                textColor: sh_white,
                isCentered: true,
                fontFamily: fontSemibold),
          ),
        );
      }
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
            onTap: () async {
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
            margin: EdgeInsets.fromLTRB(26, 0, 26, 0),
            child: Column(
              children: [
                Consumer<ProfileProvider>(builder: ((context, value, child) {
                  return value.loader_profile_pic
                      ? Padding(
                          padding: const EdgeInsets.all(spacing_standard_new),
                          child: Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            elevation: spacing_standard,
                            margin: EdgeInsets.all(spacing_control),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: CircleAvatar(
                                  // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
                                  backgroundImage: NetworkImage(value.fnl_img),
                                  radius: 55,
                                )),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.bottomRight,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(spacing_standard),
                              child: Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                elevation: spacing_standard,
                                margin: EdgeInsets.all(spacing_control),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    // getImage();
                                    // _showPicker(context);
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: value.fnl_img == null
                                          ? CircleAvatar(
                                              // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
                                              backgroundImage: NetworkImage(
                                                  'https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),

                                              radius: 55,
                                            )
                                          : CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(value.fnl_img),
                                              radius: 55,
                                            )),
                                ),
                              ),
                            ),
                          ],
                        );
                })),
                Consumer<ProfileProvider>(builder: ((context, value, child) {
                  return value.loader_profile
                      ? Center(child: CircularProgressIndicator())
                      : InkWell(
                          onTap: () {
                            // launchScreen(context, ProfileScreen.tag);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileScreen()),
                            ).then((_) {
                              final postMdl = Provider.of<ProfileProvider>(
                                  context,
                                  listen: false);
                              postMdl.getProfile();
                              postMdl.getProfilePic();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(6, 4, 6, 4.0),
                            decoration: boxDecoration(
                                bgColor: sh_btn_color2,
                                radius: 6,
                                showShadow: true),
                            child: text(
                                value.profileModel!.data!.firstName! +
                                    " " +
                                    value.profileModel!.data!.lastName!,
                                fontSize: 13.0,
                                textColor: sh_colorPrimary2,
                                isCentered: true,
                                fontFamily: fontBold),
                          ));
                })),
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
                  height: 26,
                ),
                Container(
                  height: .5,
                  color: sh_colorPrimary2,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Listing",
                      style: TextStyle(
                          color: sh_colorPrimary2,
                          fontSize: 16,
                          fontFamily: fontSemibold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Consumer<SellerProfileProvider>(
                    builder: ((context, value, child) {
                  return CustomPopupMenu(
                    child: Row(
                      children: [
                        Image.asset(
                          sh_menu_filter,
                          color: sh_colorPrimary2,
                          height: 22,
                          width: 16,
                          fit: BoxFit.fill,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          value.filter_str!,
                          style:
                              TextStyle(color: sh_colorPrimary2, fontSize: 13),
                        )
                      ],
                    ),
                    menuBuilder: () => ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: sh_btn_color,
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: menuItems
                                .map(
                                  (item) => GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      print("onTap");
                                      _controller.hideMenu();

                                      // setState(() {
                                      toast("Please wait..");
                                      value.getProduct(item.title);
                                      filter_str = item.title;
                                      // });
                                    },
                                    child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.only(left: 10),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Text(
                                                item.title,
                                                style: TextStyle(
                                                  color: sh_colorPrimary2,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    pressType: PressType.singleClick,
                    verticalMargin: -10,
                    controller: _controller,
                  );
                })),
                SizedBox(
                  height: 6,
                ),
                Consumer<SellerProfileProvider>(
                    builder: ((context, value, child) {
                  return value.loader
                      ? Expanded(
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
                                                vertical: 2.0),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 8.0,
                                            color: Colors.white,
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 2.0),
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
                        )
                      : Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                                top: spacing_standard_new,
                                bottom: spacing_standard_new),
                            itemBuilder: (item, index) {
                              return Container(
                                color: sh_white,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: NewImagevw(
                                              index, value.productListModel),
                                        ),
                                        SizedBox(
                                          width: spacing_standard_new,
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Html(
                                                data: value
                                                    .productListModel!
                                                    .products![index]!
                                                    .data!
                                                    .name!,
                                                style: {
                                                  "body": Style(
                                                    maxLines: 2,
                                                    margin: EdgeInsets.zero, padding: EdgeInsets.zero,
                                                    fontSize: FontSize(16.0),
                                                    color: sh_colorPrimary2,
                                                    fontFamily: fontSemibold,
                                                  ),
                                                },
                                              ),
                                              // Text(
                                              //   value
                                              //       .productListModel!
                                              //       .products![index]!
                                              //       .data!
                                              //       .name!,
                                              //   style: TextStyle(
                                              //       color: sh_colorPrimary2,
                                              //       fontSize: 16,
                                              //       fontFamily: fontSemibold),
                                              // ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Row(
                                                children: [
                                                  MyPrice(index,
                                                      value.productListModel!),
                                                  SizedBox(
                                                    width: 6,
                                                  ),
                                                  CheckSoldReserve2(index,
                                                      value.productListModel),
                                                ],
                                              ),
                                              // text(currency! + cat_model!.cart![positions]!.productPrice!,
                                              //     textColor: sh_app_black, fontFamily: 'Bold'),
                                              // SizedBox(
                                              //   height: 4,
                                              // ),
                                              // CheckSoldReserve(index),
                                              SizedBox(
                                                height: 9,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CheckReserve(index,
                                                      value.productListModel),
                                                  CheckSold(index,
                                                      value.productListModel),
                                                  InkWell(
                                                    onTap: () async {
                                                      // BecameSeller();
                                                      _openCustomDialogDelete(
                                                          value
                                                              .productListModel!
                                                              .products![index]!
                                                              .data!
                                                              .id
                                                              .toString());
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      decoration: boxDecoration(
                                                          bgColor: sh_btn_color,
                                                          radius: 6,
                                                          showShadow: true),
                                                      child: text("Delete",
                                                          fontSize: 12.0,
                                                          textColor:
                                                              sh_colorPrimary2,
                                                          isCentered: true,
                                                          fontFamily:
                                                              fontSemibold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              );
                            },
                            shrinkWrap: true,
                            itemCount: value.productListModel!.products!.length,
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
                      child: FutureBuilder<String?>(
                        future: fetchadd(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(profile_name!,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontFamily: 'TitleCursive'));
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          // By default, show a loading spinner.
                          return CircularProgressIndicator();
                        },
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
