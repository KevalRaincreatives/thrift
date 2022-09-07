import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/retry.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/AdvModel.dart';
import 'package:thrift/model/CategoryModel.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/model/CheckUserModel.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:thrift/screens/AddressListScreen.dart';
import 'package:thrift/screens/BecameSellerScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/CreateProductScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/MyProfileScreen.dart';
import 'package:thrift/screens/OrderListScreen.dart';
import 'package:thrift/screens/ProductDetailScreen.dart';
import 'package:thrift/screens/ProductlistScreen.dart';
import 'package:thrift/screens/SearchScreen.dart';
import 'package:thrift/screens/TermsConditionScreen.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/ShStrings.dart';
import 'package:thrift/utils/T3Dialog.dart';
import 'package:badges/badges.dart';
import 'package:thrift/utils/custom_pop_up_menu.dart';
import 'package:sizer/sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';

class ItemModel {
  String title;

  ItemModel(this.title);
}

class HomeFragment extends StatefulWidget {
  const HomeFragment({Key? key}) : super(key: key);

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late List<ItemModel> menuItems;
  CustomPopupMenuController _controller = CustomPopupMenuController();

  final double runSpacing = 4;
  final double spacing = 4;
  final columns = 2;
  List<ProductListModel> productListModel = [];
  ProfileModel? profileModel;
  String? profile_name;
  CheckUserModel? checkUserModel;
  String? filter_str = 'Newest to Oldest';
  AdvModel? advModel;
  int? cart_count;
  Future<String?>? fetchDetailsMain;
  Future<List<ProductListModel>?>? fetchAlbumMain;
  int timer = 800, offset = 0;
  @override
  void initState() {
    menuItems = [
      ItemModel('Newest to Oldest'),
      ItemModel('Oldest to Newest'),
      ItemModel('Price High to Low'),
      ItemModel('Price Low to High'),
    ];
    // Timerss();
    fetchAdv();
    fetchDetailsMain=fetchDetails();
    // fetchAlbumMain=fetchAlbum();
    super.initState();
  }


  Future<String?> fetchDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      profile_name = prefs.getString("profile_name");

      print('sucess');

      return "profileModel";
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<AdvModel?> fetchAdv() async {
//    Dialogs.showLoadingDialog(context, _keyLoader);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      String? adv_image = prefs.getString('adv_image');

      print('Token : ${token}');

      if(adv_image=='0') {
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

        var response = await http.get(
            Uri.parse(
                "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/get_ads"),
            headers: headers);

        final jsonResponse = json.decode(response.body);
        print('not json image$jsonResponse');

        advModel = new AdvModel.fromJson(jsonResponse);
        // if (new_car == 0) {

        prefs.setString("adv_image", "1");
        if(advModel!.data!=null) {
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(advModel!.data!),
          );
        }
      }
      return advModel;
    } catch (e) {
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

      // String? user_country = "Barbados";
      // toast(cat_id);


      var response;
      if (filter_str == 'Newest to Oldest') {
        response = await http.get(Uri.parse(
            "https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=date&order=desc&per_page=100&country=$user_country"));
      } else if (filter_str == 'Oldest to Newest') {
        response = await http.get(Uri.parse(
            "https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=date&order=asc&per_page=100&country=$user_country"));
      } else if (filter_str == 'Price High to Low') {
        response = await http.get(Uri.parse(
            "https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=price&order=desc&per_page=100&country=$user_country"));
      } else if (filter_str == 'Price Low to High') {
        response = await http.get(Uri.parse(
            "https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products?stock_status=instock&status=publish&orderby=price&order=asc&per_page=100&country=$user_country"));
      }
      print('Response status2: ${response.statusCode}');
      print('Response body2: ${response.body}');
      productListModel.clear();
      final jsonResponse = json.decode(response.body);
      for (Map i in jsonResponse) {
        if (i["display_product"] == true) {
          productListModel.add(ProductListModel.fromJson(i));
        }
//        orderListModel = new OrderListModel2.fromJson(i);
      }
      if (productListModel.length > 0) {
        prefs.setString(
            "fnl_currency", productListModel[0].currency.toString());
      }

      return productListModel;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }

  Future<CheckUserModel?> fetchUserStatus() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print("https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/check_seller_status?user_id=$UserId");
      var response = await http.get(Uri.parse(
          "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/check_seller_status?user_id=$UserId",)
      ,headers: headers);

      final jsonResponse = json.decode(response.body);
      checkUserModel = new CheckUserModel.fromJson(jsonResponse);
      prefs.setString('is_store_owner', checkUserModel!.is_store_owner.toString());
      EasyLoading.dismiss();
      if(checkUserModel!.is_store_owner==0){
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
                          'You are not a seller yet!',
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
                            launchScreen(context, BecameSellerScreen.tag);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .7,
                            padding: EdgeInsets.only(top: 6, bottom: 10),
                            decoration: boxDecoration(
                                bgColor: sh_colorPrimary2,
                                radius: 10,
                                showShadow: true),
                            child: text("Become a Seller",
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
      else if (checkUserModel!.is_store_owner==1) {
        // launchScreen(context, BecameSellerScreen.tag);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateProductScreen(),
          ),
        ).then((_) => setState(() {}));
      } else if (checkUserModel!.is_store_owner==2) {
        toast("Your Seller Registration is Pending. You will be notified once approved.");
      }

      print('sucess');
      print('not json $jsonResponse');

      return checkUserModel;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
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


  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    Imagevw4(int index) {
      if (productListModel[index].images!.length < 1) {
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
          child: Image.network(
            productListModel[index].images![0]!.src!,
            fit: BoxFit.cover,
            height: 130,
            width: width,
          ),
        );
      }
    }

    NewImagevw(int index) {
      return Imagevw4(index);
    }

    MyPrice(int index) {
      var myprice2, myprice;
      if (productListModel[index].price == '') {
        myprice = '0.00';
      } else {
        myprice2 = double.parse(productListModel[index].price!);
        myprice = myprice2.toStringAsFixed(2);
      }
      return Row(
        children: [
          Text(
            "\$" + myprice+ " "+productListModel[index].currency!,
            style: TextStyle(
                color: sh_black,
                fontFamily: 'Medium',
                fontSize: textSizeSMedium2),
          ),
        ],
      );
    }

    void _openCustomDialog() {
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
                    'You are not a seller yet!',
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
                          launchScreen(context, BecameSellerScreen.tag);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .7,
                          padding: EdgeInsets.only(top: 6, bottom: 10),
                          decoration: boxDecoration(
                              bgColor: sh_colorPrimary2,
                              radius: 10,
                              showShadow: true),
                          child: text("Become a Seller",
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

    MyBadge() {
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

    listView() {
      if(productListModel.length == 0){
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
      }else {
        return Expanded(
          child: AnimationLimiter(
            child: GridView.count(
              childAspectRatio: 0.75,
              crossAxisCount: 2,
              crossAxisSpacing: 32.0,
              mainAxisSpacing: 10.0,
              children: List.generate(
                productListModel.length,
                    (int index) {
                  return AnimationConfiguration
                      .staggeredGrid(
                    position: index,
                    duration:
                    const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                            await SharedPreferences
                                .getInstance();
                            prefs.setString(
                                'pro_id',
                                productListModel[index]
                                    .id
                                    .toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailScreen()),).then((value) {   setState(() {
                              // refresh state
                            });});
                          },
                          child: Container(
                            decoration: boxDecoration4(
                                showShadow: false),
                            // margin: EdgeInsets.only(left: 16, bottom: 16),
                            // padding: EdgeInsets.fromLTRB(spacing_standard,spacing_standard,spacing_standard,spacing_control_half),
                            // padding:
                            // EdgeInsets.fromLTRB(0, 0, 0, spacing_control_half),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .stretch,
                              children: <Widget>[
                                NewImagevw(index),
                                SizedBox(
                                  height: 6,
                                ),
                                Padding(
                                  padding: const EdgeInsets
                                      .only(
                                      left:
                                      0,
                                      right:
                                      spacing_standard),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Text(
                                        productListModel[
                                        index]
                                            .name!,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color:
                                            sh_app_black,
                                            fontFamily:
                                            fontBold,
                                            fontSize:
                                            textSizeMedium),
                                      ),
                                      SizedBox(
                                        height: 4,
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

    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: FutureBuilder<String?>(
          future: fetchDetailsMain,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                profile_name!,
                style: TextStyle(
                    color: sh_white, fontSize: 20, fontFamily: 'TitleCursive'),
              );
            }
            return Center(child: CircularProgressIndicator(color: sh_white,));
          },
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
                child: MyBadge(),

              ),
              SizedBox(width: 16,)
            ],
          ),
        ],
      );
      double app_height = appBar.preferredSize.height;
      return Stack(children: <Widget>[
        Container(
          color: sh_colorPrimary2,
            height: 40,
            width: width,
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        // Background with gradient
        Container(
          margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
            height: 120,
            width: width,
            child: Image.asset(sh_upper2, fit: BoxFit.fill)
            // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
            ),

        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            // color: sh_green,
            padding: const EdgeInsets.fromLTRB(15,spacing_xxLarge,15,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (){
                        _scaffoldKey.currentState!.openDrawer();
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0,2,0,2),
                        child: IconButton(onPressed: () {
                          _scaffoldKey.currentState!.openDrawer();
                        }, icon: new Image.asset(sh_newmenu,height: 20,width: 20,),
                            // tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: FutureBuilder<String?>(
                        future: fetchDetailsMain,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              profile_name!,
                              style: TextStyle(
                                  color: sh_white, fontSize: 22, fontFamily: 'TitleCursive'),
                            );
                          }
                          return Center(child: CircularProgressIndicator(color: sh_white,));
                        },
                      ),
                    )
                  ],
                ),
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
                  child: MyBadge(),

                ),

              ],
            ),
          ),
        ),
        //Above card
        Container(
          height: height,
          // padding: EdgeInsets.fromLTRB(26,0,26,0),
          margin: EdgeInsets.fromLTRB(0, app_height + 40, 0, 0),
          // color: Colors.white,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: width,
                  color: Colors.transparent,
                  margin: EdgeInsets.fromLTRB(26, 0, 26, 0),
                  child: TextFormField(
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (value) async {
                      if (value.length > 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SearchScreen(serchdata: value)),
                        );
                      } else {
                        toast("Please enter more character");
                      }
                    },
                    style: TextStyle(
                        color: sh_colorPrimary2,
                        fontSize: textSizeSMedium,
                        fontFamily: "Bold"),
                    decoration: InputDecoration(
                      filled: true,
                      suffixIcon: Icon(
                        Icons.search,
                        color: sh_colorPrimary2,

                      ),
                      fillColor: sh_text_back,
                      contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      hintText: "Search",
                      hintStyle: TextStyle(color: sh_colorPrimary2),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: sh_transparent, width: 0.7),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: sh_transparent, width: 0.7),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: height - 168,
                  width: width,
                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                  padding: EdgeInsets.fromLTRB(26, 0, 26, 0),
                  color: sh_white,
                  child: Column(
                    children: [
                      CustomPopupMenu(
                        child: Wrap(
                          children: [Row(
                            children: [
                              Image.asset(
                                sh_menu_filter,
                                color: sh_colorPrimary2,
                                height: 22,
                                width: 16,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 12,),
                              Text(
                                filter_str!,
                                style: TextStyle(
                                    color: sh_colorPrimary2, fontSize: 13),
                              )
                            ],
                          )],
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
                                          // toast(item.title);
                                          _controller.hideMenu();
                                          setState(() {
                                            toast("Please wait..");
                                            filter_str=item.title;
                                          });
                                        },
                                        child: Container(
                                          height: 40,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 10),
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
                        position: PreferredPosition.bottom,
                        pressType: PressType.singleClick,
                        verticalMargin: -10,
                        controller: _controller,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      FutureBuilder<List<ProductListModel>?>(
                        future: fetchAlbum(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return listView();
                          }
                          // return Center(child: CircularProgressIndicator(color: sh_colorPrimary2));
                          return Expanded(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              direction: ShimmerDirection.ltr,
                              child: GridView.builder(
                                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20),
                                  itemCount: 8,
                                  itemBuilder: (BuildContext ctx, index) {
                                    offset +=50;
                                    timer = 800 + offset;
                                    print(timer);
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 46,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        // Positioned to take only AppBar size

      ]);
    }

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
        height: 100,
        width: 100,
        child: new RawMaterialButton(
          shape: new CircleBorder(),
          elevation: 0.0,
          child: Image.asset(
            sh_floating,
            fit: BoxFit.cover,
          ),
          onPressed: () async {
            fetchUserStatus();
            // SharedPreferences prefs = await SharedPreferences.getInstance();
            // if (prefs.getString("is_store_owner") == '0') {
            //   _openCustomDialog();
            // } else if (prefs.getString("is_store_owner") == '1') {
            //   launchScreen(context, CreateProductScreen.tag);
            // } else if (prefs.getString("is_store_owner") == '2') {
            //   toast("Approval is pending");
            // }
          },
        ),

        // FittedBox(
        //   child: FloatingActionButton(
        //     onPressed: () {
        //       launchScreen(context, CreateProductScreen.tag);
        //       // Add your onPressed code here!
        //     },
        //     // backgroundColor: sh_colorPrimary2,
        //     child:
        //         CircleAvatar(
        // radius: 50,
        // backgroundImage: AssetImage(sh_floating),)
        //         Image.asset(sh_floating,fit: BoxFit.cover,),
        // Icon(Icons.add,color: sh_white,size: 36,),
        //   ),
        // ),
      ),

      body: StreamProvider<NetworkStatus>(
        initialData: NetworkStatus.Online,
        create: (context) =>
        NetworkStatusService().networkStatusController.stream,
        child: NetworkAwareWidget(
          onlineChild: setUserForm(),
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

      drawer: T2Drawer(),
    );
  }
}

class T2Drawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return T2DrawerState();
  }
}

class T2DrawerState extends State<T2Drawer> {
  var selectedItem = -1;
  List<CategoryModel> categoryListModel = [];
  Future<List<CategoryModel>?>? fetchAlbumMain;

  @override
  void initState() {
    super.initState();
    fetchAlbumMain=fetchAlbum();
  }

  Future<List<CategoryModel>?> fetchAlbum() async {
    try {
      if (categoryListModel.length == 0) {
        final client = RetryClient(http.Client());
        var response;
        try {
          response = await client.get(Uri.parse(
              "https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/categories?per_page=25"));
        } finally {
          client.close();
        }

        print('Response status2: ${response.statusCode}');
        print('Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        for (Map i in jsonResponse) {
          categoryListModel.add(CategoryModel.fromJson(i));
//        orderListModel = new OrderListModel2.fromJson(i);
        }
      }

      return categoryListModel;
    } catch (e) {
//      return orderListModel;
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(topRight: Radius.circular(36)),
            color: sh_text_back),
        child: SingleChildScrollView(
          child: Container(
            // width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 58,
            // color: sh_text_back,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  elevation: 3,
                  shadowColor: Colors.grey.shade200,
                  color: sh_text_back,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(36)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18.0, 16, 0, 16),
                    child: Text("Main Menu",
                        style: TextStyle(
                            color: sh_colorPrimary2,
                            fontSize: 20,
                            fontFamily: 'Bold')),
                  ),
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   decoration: BoxDecoration(
                //     boxShadow: <BoxShadow>[
                //       BoxShadow(
                //           color: sh_app_background,
                //           blurRadius: 15.0,
                //           offset: Offset(0.0, 0.75)
                //       )
                //     ],
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(18.0,20,0,16),
                //     child: Text("Main Menu",style: TextStyle(color: sh_colorPrimary2,fontSize: 22,fontFamily: 'Bold')),
                //   ),
                // ),
                //      Container(height: 0.5,
                //      color: sh_colorPrimary2,),

                FutureBuilder<List<CategoryModel>?>(
                  future: fetchAlbumMain,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var unescape = HtmlUnescape();
                      return Expanded(
                        child: ListView.builder(
                          // physics:
                          // NeverScrollableScrollPhysics(),

                          scrollDirection: Axis.vertical,
                          itemCount: categoryListModel.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  prefs.setString('cat_id',
                                      categoryListModel[index].id.toString());
                                  prefs.setString('cat_names',
                                      categoryListModel[index].name.toString());
                                  launchScreen(context, ProductlistScreen.tag);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      18.0, 12, 12, 12),
                                  child: Text(  unescape.convert(categoryListModel[index].name!),
                                      style: TextStyle(
                                          color: sh_colorPrimary2,
                                          fontSize: 15.sp,
                                          fontFamily: 'Bold')),
                                )
                              // text(categoryListModel[index].name, textColor: t1TextColorPrimary, fontFamily: fontBold, fontSize: textSizeLargeMedium, maxLine: 2),
                            );
                          },
                        ),
                      );
                    }
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      direction: ShimmerDirection.ltr,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(12,12,50,12),
                        child: Column(
                          children: [
                            Container(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        18.0, 12, 12, 12),
                                    child:                             Container(
                                      width: double.infinity,
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
                                      width: double.infinity,
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
                                      width: double.infinity,
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
                                      width: double.infinity,
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
                                      width: double.infinity,
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

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getDrawerItem(String icon, String name, int pos) {
    return GestureDetector(
      onTap: () async {
        toast(pos.toString());
        if (pos == 1) {
          launchScreen(context, MyProfileScreen.tag);
        } else if (pos == 2) {
          launchScreen(context, OrderListScreen.tag);
        } else if (pos == 3) {
          launchScreen(context, AddressListScreen.tag);
        } else if (pos == 5) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          // String UserId = prefs.getString('UserId');
          prefs.setString('final_token', '');
          prefs.setString('token', '');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
            ModalRoute.withName('/LoginScreen'),
          );
        } else if (pos == 6) {
          launchScreen(context, TermsConditionScreen.tag);
        } else if (pos == 7) {
          launchScreen(context, CreateProductScreen.tag);
        } else {
          setState(() {
            selectedItem = pos;
          });
        }
      },
      child: Container(
        color: selectedItem == pos ? t2_colorPrimaryLight : sh_white,
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: <Widget>[
            Image.asset(myimg, width: 20, height: 20),
            SizedBox(width: 20),
            text(name,
                textColor:
                    selectedItem == pos ? sh_colorPrimary2 : sh_colorPrimary2,
                fontSize: textSizeLargeMedium,
                fontFamily: fontMedium)
          ],
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  CustomDialog(this.yourData);

  final String yourData;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context,yourData),
    );
  }
}

dialogContent(BuildContext context,String myimage) {
  return Container(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          ClipRRect(
            child: Image.network(
              // t3_ic_pizza_dialog,
                myimage
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(padding: EdgeInsets.all(16), alignment: Alignment.centerRight, child: Icon(Icons.close, color: Colors.white)),
              ),
//              Container(
//                alignment: Alignment.bottomCenter,
//                  child: text("This offer is valid till 30th november",textColor: t3_white))
            ],
          ),
        ],
      ));
}
