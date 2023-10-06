import 'dart:async';
import 'dart:convert';
import 'dart:io' as i;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:badges/badges.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/retry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sizer/sizer.dart';
import 'package:thrift/model/AddProCategoryModel.dart';
import 'package:thrift/model/AddProMetaModel.dart';
import 'package:thrift/model/AddProMetaModel2.dart';
import 'package:thrift/model/AttributeModel.dart';
import 'package:thrift/model/CategoryModel.dart';
import 'package:thrift/model/CreateProModel.dart';
import 'package:thrift/model/MultiImageModel.dart';
import 'package:thrift/model/MyVariant.dart';
import 'package:thrift/model/NewAttributeModel.dart';
import 'package:thrift/model/NewCategoryModel.dart';
import 'package:thrift/model/NewSelectedCategoryModel.dart';
import 'package:thrift/model/UploadImageModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import '../provider/home_product_provider.dart';
import '../utils/data_manager.dart';
import 'EulaScreen.dart';
import 'package:thrift/api_service/Url.dart';

class CreateProductScreen extends StatefulWidget {
  static String tag = '/CreateProductScreen';

  const CreateProductScreen({Key? key}) : super(key: key);

  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  CategoryModel? categoryListModel;

  List<NewCategoryModel> categoryListModel2 = [];
  List<NewSelectedCategoryModel> selectedList = [];
  List<int> selectedReportList = [];
  bool ischange = false;
  bool ischange2 = false;
  var ProductNameCont = TextEditingController();
  var ShortDescCont = TextEditingController();
  var DescCont = TextEditingController();
  var PriceCont = TextEditingController();
  var EstPriceCont = TextEditingController();
  var QtyCont = TextEditingController();
  var BrandCont = TextEditingController();
  var FaultsCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AttributeModel? attributeModel;
  final List<NewAttributeModel>? itemsModel = [];
  NewAttributeModel? itModel;
  final List<AddProCategoryModel> addProCatModel = [];
  final List<AddProMetaModel> addProMetaModel = [];
  final List<AddProMetaModel2> addProMetaModel2 = [];
  final List<MultiImageModel> multimimageModel = [];
  List<XFile>? _imageFileList = [];
  final ImagePicker _picker = ImagePicker();
  final List<UploadImageModel> uploadModel = [];
  UploadImageModel? upModel;
  CreateProModel? createProModel;
  int? cart_count;
  String dropdownValue = 'NONE';
  bool _isVisible = false;
  var maxLength = 500;
  var textLength = 0;
  bool singleTap = true;
  int val = 1;
  Trace traceAddProduct = FirebasePerformance.instance.newTrace('AddProduct');
  Trace traceAddProductImage = FirebasePerformance.instance.newTrace('add_product_images');
  Trace traceAddEstPrice = FirebasePerformance.instance.newTrace('add_estimated_retail_price');

  @override
  void initState() {
    super.initState();
    // fetchDetail();
    fetchAlbum();

    // fetchAttribute();
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

  Future<List<NewCategoryModel>?> fetchAlbum() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? token = prefs.getString('token');
      String? user_default_country=prefs.getString('user_default_country');
      print("mycss"+user_default_country!);
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
//       var response = await http.get(
//           Uri.parse("https://encros.rcstaging.co.in/wp-json/wc/v3/products/categories"));
      if (!ischange) {
        final client = RetryClient(http.Client());
        var response;
        try {
          response = await client.get(Uri.parse(
              "${Url.BASE_URL}wp-json/wooapp/v3/woo_product_categories"));
        } finally {
          client.close();
        }
        // categoryListModel!.categories!.clear();
        categoryListModel2.clear();

        print('CreateProductScreen categories Response status2: ${response.statusCode}');
        print('CreateProductScreen categories Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        categoryListModel = new CategoryModel.fromJson(jsonResponse);

        for (var i = 0; i < categoryListModel!.categories!.length; i++) {
          categoryListModel2.add(new NewCategoryModel(
              catid: categoryListModel!.categories![i]!.id,
              name: categoryListModel!.categories![i]!.name,
              selected: false));
        }
      }
      fetchAttribute();
      return categoryListModel2;
    } on Exception catch (e) {
      EasyLoading.dismiss();
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Reload",
        desc: e.toString(),
        buttons: [
          DialogButton(
            child: const Text(
              "Reload",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            color: sh_colorPrimary2,
          ),
        ],
      ).show().then((value) {setState(() {
        fetchAlbum();
      });} );
      print('caught error $e');
    }
  }

  Future<AttributeModel?> fetchAttribute() async {
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
//       var response = await http.get(
//           Uri.parse("https://encros.rcstaging.co.in/wp-json/wc/v3/products/categories"));
      if (!ischange2) {
        final client = RetryClient(http.Client());
        var response;
        try {
          response = await client.get(Uri.parse(
              "${Url.BASE_URL}wp-json/wooapp/v3/attributes"));
        } finally {
          client.close();
        }
        attributeModel = null;
        itemsModel!.clear();

        print('CreateProductScreen attributes Response status2: ${response.statusCode}');
        print('CreateProductScreen attributes Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        attributeModel = new AttributeModel.fromJson(jsonResponse);
      }
      EasyLoading.dismiss();
      setState(() {});

      return attributeModel;
    } on Exception catch (e) {
      EasyLoading.dismiss();
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Reload",
        desc: e.toString(),
        buttons: [
          DialogButton(
            child: const Text(
              "Reload",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            color: sh_colorPrimary2,
          ),
        ],
      ).show().then((value) {setState(() {
        fetchAlbum();
      });} );
      print('caught error $e');
    }
  }

  Future<List<AddProMetaModel>?> getUserNameSharedPreference(
      List<NewAttributeModel> itemsModel,
      List<AddProMetaModel> addProMetaModel) async {
    int myind = 0;
    for (var j = 0; j < itemsModel.length; j++) {
      if (itemsModel[j].options!.length > 0) {

        addProMetaModel.add(new AddProMetaModel(
            key: itemsModel[j].name!,
            value: itemsModel[j].options![0].toString()));
      }
      myind = j;
    }
    int myind2 = itemsModel.length - 1;
    if (myind == myind2) {
      Future.delayed(const Duration(seconds: 2), () {

        return addProMetaModel;
      });
    }
  }

  void _openCustomDialog2() {

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
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      semanticsLabel: 'Circular progress indicator',
                      color: sh_colorPrimary2,
                    ),
                SizedBox(height: 16,),
                Text(
                  'Please wait',
                  style: TextStyle(
                      color: sh_colorPrimary2,
                      fontSize: 18,
                      fontFamily: 'Bold'))
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

  Future<CreateProModel?> AddProduct() async {
    await traceAddProduct.start();
    // EasyLoading.show(status: 'Please wait...');
    Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog2(context,'Storing your product data on the server',false);
    try {
      addProMetaModel
          .add(new AddProMetaModel(key: "Brand", value: BrandCont.text));
      if (_isVisible) {
        addProMetaModel
            .add(new AddProMetaModel(key: "Fault (s)", value: FaultsCont.text));
      } else {
        addProMetaModel.add(new AddProMetaModel(key: "Fault (s)", value: "NONE"));
      }
      int completedCount = 0;
      // await getUserNameSharedPreference(itemsModel,addProMetaModel).then((value) async{
      for (var j = 0; j < attributeModel!.data!.attributes!.length; j++) {
        if (itemsModel![j].options!.length > 0) {

          addProMetaModel.add(new AddProMetaModel(
              key: itemsModel![j].name!,
              value: itemsModel![j].options![0].toString()));
          completedCount += 1;
        }
      }
      // toast(addProMetaModel[3].value);

      addProMetaModel2
          .add(new AddProMetaModel2(key: "attrs_val", value: addProMetaModel));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      print(token);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var body = json.encode({
        "name": ProductNameCont.text,
        "type": "simple",
        "description": DescCont.text,
        "short_description": "",
        "price": PriceCont.text,
        "manage_stock": true,
        "stock_quantity": "1",
        "stock_status": "instock",
        "regular_price": PriceCont.text,
        "categories": addProCatModel,
        "meta_data": addProMetaModel2
      });

      print(body);

      // }

      var response = await http.post(
          Uri.parse('${Url.BASE_URL}wp-json/wc/v3/products'),
          body: body,
          headers: headers);

      print('CreateProductScreen products Response status2: ${response.statusCode}');
      print('CreateProductScreen products Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);

      createProModel = new CreateProModel.fromJson(jsonResponse);

      // toast("Product Created Successfully");
      Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog2(context,'Storing your product data on the server',true);

      ItemAdd(createProModel!.id.toString());

      // }
      // );
      await traceAddProduct.stop();
      return createProModel;
    } on Exception catch (e) {
      await traceAddProduct.stop();
      Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog4(context,'Unable to save your product.\nPlease attempt again');
      // EasyLoading.dismiss();
// toast(e.toString());
      print('caught error $e');
    }
  }

  Future<String?> AddPhoto(String prodId) async {
    await traceAddProductImage.start();
    Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog2(context,'Uploading your product images to the server',false);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      print(token);

      // Response response = await get(
      //     'https://encros.rcstaging.co.in/wp-json/v3/wooapp_add_to_cart?product_id=$pro_id&quantity=1');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var body = json.encode({
        "product_id": prodId,
        "product_images": uploadModel,
      });

      // final msg = jsonEncode({"username": username, "password": password});
      print("uploadLength"+uploadModel.length.toString());
      print(body);
      var response = await http.post(
          Uri.parse(
              '${Url.BASE_URL}wp-json/wooapp/v3/add_product_images'),
          body: body,
          headers: headers);

      print('CreateProductScreen add_product_images Response status2: ${response.statusCode}');
      print('CreateProductScreen add_product_images Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);

      if (EstPriceCont.text.length > 0) {
        AddEstPrice(prodId);

      } else {
        Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog2(context,'Uploading your product images to the server',true);
        Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog3(context,'Your product has been successfully saved');
        // Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog2(context,'product created successfully',true);
        // EasyLoading.dismiss();
        // Navigator.pop(context);
      }
      final postMdl = Provider.of<HomeProductListProvider>(context, listen: false);
      postMdl.getHomeProduct('Newest to Oldest',true);
      // EasyLoading.dismiss();
      // toast("Image Uploaded Successfully");
      await traceAddProductImage.stop();
      return "cat_model";
    } on Exception catch (e) {
      // EasyLoading.dismiss();
      await traceAddProductImage.stop();
      Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog4(context,'Unable to save your product.\nPlease attempt again');
// toast(e.toString());
      print('caught error $e');
    }
  }

  Future<String?> AddEstPrice(String prodId) async {
    await traceAddEstPrice.start();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? user_default_country=prefs.getString('user_default_country');
      print(token);

      // Response response = await get(
      //     'https://encros.rcstaging.co.in/wp-json/v3/wooapp_add_to_cart?product_id=$pro_id&quantity=1');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var body = json.encode({
        "product_id": prodId,
        "estimated_retail_price": EstPriceCont.text,
        "product_country":user_default_country
      });

      // final msg = jsonEncode({"username": username, "password": password});
      print(body);
      var response = await http.post(
          Uri.parse(
              '${Url.BASE_URL}wp-json/wooapp/v3/add_estimated_retail_price'),
          body: body,
          headers: headers);

      print('CreateProductScreen add_estimated_retail_price Response status2: ${response.statusCode}');
      print('CreateProductScreen add_estimated_retail_price Response body2: ${response.body}');

      final jsonResponse = json.decode(response.body);
      Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog2(context,'Uploading your product images to the server',true);
      Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog3(context,'Your product has been successfully saved');
      // EasyLoading.dismiss();

      // EasyLoading.dismiss();
      // toast("Image Uploaded Successfully");

      // Navigator.pop(context);
      await traceAddEstPrice.stop();
      return "cat_model";
    }  on Exception catch (e) {
      await traceAddEstPrice.stop();
      Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog4(context,'Unable to save your product.\nPlease attempt again');
      // EasyLoading.dismiss();
// toast(e.toString());
      print('caught error $e');
    }
  }

  void ItemAdd(String prodId) {
    for (var i = 0; i < multimimageModel.length; i++) {
      File fls = File(multimimageModel[i].path!);
      Uint8List bytes = fls.readAsBytesSync();
      String base64Image = base64Encode(bytes);
      upModel =
          UploadImageModel(name: multimimageModel[i].name!, file: base64Image);
      uploadModel.add(upModel!);
    }
    AddPhoto(prodId);

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: sh_colorPrimary2));

    // var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;

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



    final node = FocusScope.of(context);

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "New Listing",
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
            width: 100.w,
            child: Image.asset(sh_upper2, fit: BoxFit.fill)
            // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
            ),
        //Above card

        Container(
          height: 100.h,
          width: 100.w,
          color: sh_white,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    26, spacing_standard_new, 26, spacing_standard_new),
                child: Container(
                  color: sh_white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // text(" Product Name", textColor: sh_app_txt_color,fontFamily: "Bold"),
                      Row(
                        children: [
                          text(" Product Name",
                              textColor: sh_app_txt_color, fontFamily: "Bold"),
                          text("*", textColor: sh_red, fontFamily: "Bold"),
                        ],
                      ),
                      editTextStyle(
                          "Product Name",
                          ProductNameCont,
                          node,
                          "Please Enter Product Name",
                          sh_white,
                          sh_view_color,
                          1,
                          context),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      text(" Description",
                          textColor: sh_app_txt_color, fontFamily: "Bold"),
                      // text(" Description", textColor: sh_app_txt_color,fontFamily: "Bold"),
                      // editTextStyle2(
                      //     "Description",
                      //     DescCont,
                      //     node,
                      //     "Please Enter Description",
                      //     sh_white,
                      //     sh_view_color,
                      //     5,context),
                      // editTextStyle4(
                      //     "Description",
                      //     DescCont,
                      //     node,
                      //     "Please Enter Description",
                      //     sh_white,
                      //     sh_view_color,
                      //     5,
                      //     context),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: TextFormField(
                          autofocus: false,
                          onFieldSubmitted: (value) async {
                            FocusScope.of(context).unfocus();
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          maxLines: 5,
                          controller: DescCont,
                          onEditingComplete: () => node.nextFocus(),
                          style: TextStyle(
                              fontSize: textSizeMedium,
                              fontFamily: fontRegular),
                          cursorColor: sh_app_txt_color,
                          maxLength: maxLength,
                          onChanged: (value) {
                            setState(() {
                              textLength = value.length;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
                            // prefixIcon:Text("${textLength.toString()}/${maxLength.toString()}"),
                            // prefixText: "${textLength.toString()}/${maxLength.toString()}",
                            suffixText: '${textLength.toString()}/${maxLength.toString()}',
                            counterText: "",
                            hintText: "Description",
                            hintStyle: TextStyle(color: sh_app_txt_color),
                            filled: true,
                            fillColor: sh_white,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: sh_view_color, width: 1.0)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: sh_view_color, width: 1.0)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      // text(" Short Description",
                      //     textColor: sh_app_txt_color, fontFamily: "Bold"),
                      // editTextStyle2(
                      //     "Short Description",
                      //     ShortDescCont,
                      //     node,
                      //     "Please Enter Description",
                      //     sh_white,
                      //     sh_view_color,
                      //     2,
                      //     context),
                      // SizedBox(
                      //   height: spacing_standard_new,
                      // ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    text(" Price(USD)",
                                        textColor: sh_app_txt_color,
                                        fontFamily: "Bold"),
                                    text("*",
                                        textColor: sh_red, fontFamily: "Bold"),
                                  ],
                                ),
                                // text(" Price", textColor: sh_app_txt_color,fontFamily: "Bold"),
                                editTextStyle3(
                                    "Price(USD)",
                                    PriceCont,
                                    node,
                                    "Please Enter Price",
                                    sh_white,
                                    sh_view_color,
                                    1,
                                    context),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      text(" Estimated Retail Price(USD)",
                          textColor: sh_app_txt_color, fontFamily: "Bold"),
                      editTextStyle4(
                          "Estimated Retail Price(USD)",
                          EstPriceCont,
                          node,
                          "Please Enter Estimated Retail Price",
                          sh_white,
                          sh_view_color,
                          1,
                          context),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      Row(
                        children: [
                          text(" Brand Name",
                              textColor: sh_app_txt_color, fontFamily: "Bold"),
                          text("*", textColor: sh_red, fontFamily: "Bold"),
                        ],
                      ),
                      // text(" Brand Name", textColor: sh_app_txt_color,fontFamily: "Bold"),
                      editTextStyle(
                          "Enter Brand",
                          BrandCont,
                          node,
                          "Please Enter Brand",
                          sh_white,
                          sh_view_color,
                          1,
                          context),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      Row(
                        children: [
                          text(" Fault (s)",
                              textColor: sh_app_txt_color, fontFamily: "Bold"),
                          text("*", textColor: sh_red, fontFamily: "Bold"),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 8, 8, 0),
                          child: Container(
                            decoration: boxDecoration(
                                bgColor: sh_btn_color,
                                radius: 22,
                                showShadow: true),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
                              child: DropdownButton<String>(
                                underline: Container(),
                                value: dropdownValue,

                                elevation: 16,
                                // style: const TextStyle(color: Colors.deepPurple),

                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue == "Enter if any Faults") {
                                      _isVisible = true;
                                    } else {
                                      _isVisible = false;
                                    }
                                    dropdownValue = newValue!;
                                  });
                                },
                                items: <String>[
                                  'NONE',
                                  'Enter if any Faults'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          color: sh_textColorPrimary,
                                          fontFamily: fontRegular,
                                          fontSize: textSizeMedium),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      // text(" Faults", textColor: sh_app_txt_color,fontFamily: "Bold"),
                      Visibility(
                        visible: _isVisible,
                        child: editTextStyle(
                            "Enter if any Faults",
                            FaultsCont,
                            node,
                            "Please Enter Faults",
                            sh_white,
                            sh_view_color,
                            1,
                            context),
                      ),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      Row(
                        children: [
                          text(" Select Category",
                              textColor: sh_app_txt_color, fontFamily: "Bold"),
                          text("*", textColor: sh_red, fontFamily: "Bold"),
                        ],
                      ),

                      MultiSelectChip(
                        categoryListModel2,
                        onSelectionChanged: (selectedList) {
                          setState(() {
                            selectedReportList = selectedList;
                          });
                        },
                      ),
                      SizedBox(
                        height: spacing_standard_new,
                      ),

                      // text(" Select Attribute", textColor: t6textColorPrimary),
                      // CheckVariant(),
                      AttrWidget(attributeModel, itModel, itemsModel!,categoryListModel2),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      text(" Add Image (Maximum 5 images)",
                          textColor: sh_app_txt_color, fontFamily: "Bold"),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      PhotoWidget(
                          multimimageModel: multimimageModel,
                          picker: _picker,
                          imageFileList: _imageFileList),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 2,
                            groupValue: val,
                            onChanged: (int? value) {
                              setState(() {
                                val = value!;
                              });
                            },
                            activeColor: sh_colorPrimary2,
                          ),
                          Text('I agree to Seller EULA.',style: TextStyle(color: sh_black,fontSize: 12),),
                          Flexible(
                            child: InkWell(
                                onTap: () {
                                  launchScreen(context, EulaScreen.tag);
                                },
                                child: Text('Click here to view full EULA.',style: TextStyle(color: sh_colorPrimary2,fontSize: 12, decoration: TextDecoration.underline,),)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: spacing_standard_new,
                      ),
                      InkWell(
                        onTap: () async {
                          // Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog2(context,'Please wait uploading',false);
                          // Provider.of<HomeProductListProvider>(context, listen: false).openCustomDialog3(context,'Product Created Successfully');
                          if(val==2){
                              // Do something here
                              if (_formKey.currentState!.validate()) {
                                //   // TODO submit
                                FocusScope.of(context).requestFocus(FocusNode());
                                for (var i = 0;
                                i < selectedReportList.length;
                                i++) {
                                  addProCatModel.add(new AddProCategoryModel(
                                      id: selectedReportList[i]));
                                }
                                //                       toast(itemsModel!.length.toString());
                                //                     if(itemsModel![0].options!.length>0){
                                //                       print(itemsModel![0].name! +
                                //                           itemsModel![0].options![0].toString());
                                //                     }
                                // if(itemsModel![1].options!.length>0) {
                                //   print(itemsModel![1].name! + itemsModel![1].options![0].toString());
                                // }
                                // if(itemsModel![2].options!.length>0) {
                                //   print(itemsModel![2].name! + itemsModel![2].options![0].toString());
                                // }
                                // if(itemsModel![3].options!.length>0) {
                                //   print(itemsModel![3].name! + itemsModel![3].options![0].toString());
                                // }
                                if (multimimageModel.length > 0) {
      if (addProCatModel.isNotEmpty) {
                                  // AddProduct();
                                  int jj = 0;
                                  String mj = '';

                                  // itemsModel!.length = itemsModel.length - howMany;
                                  // itemsModel.length=attributeModel.data.attributes.length
                                  for (var j = 0;
                                  j < attributeModel!.data!.attributes!.length;
                                  j++) {
                                    if (itemsModel![j].required == '1') {
                                      if (itemsModel![j].options!.length == 0) {
                                        if(DataManager.getInstance().getIsShoesSelected()=='True'&&itemsModel![j].name=='Size'){

                                        }else if(DataManager.getInstance().getIsShoesSelected()=='False'&&itemsModel![j].name=='Footware Size'){

                                        }else if(itemsModel![j].type=='text'){

                                        }
                                        else {
                                          jj++;
                                          mj = itemsModel![j].name!;
                                          break;
                                        }
                                      }
                                    }
                                  }

                                  // toast(jj.toString());
                                  if (jj > 0) {
                                    toast("Please Select $mj");
                                  } else {
                                    // toast("Perfect");
                                    AddProduct();
                                  }
      } else {
        toast("Please Select Category");
      }
                                } else {
                                  toast("Please add a photo");
                                }
                              // setState(() {
                              //   singleTap = false; // update bool
                              // });
                            }

                          }else{
                            toast("Please agree to the seller EULA");
                          }


                        },
                        child: Container(
                          width: 100.w,
                          padding: EdgeInsets.only(
                              top: spacing_middle, bottom: spacing_middle),
                          decoration: boxDecoration(
                              bgColor: sh_app_background,
                              radius: 10,
                              showShadow: true),
                          child: text("Add Product",
                              textColor: sh_app_txt_color,
                              isCentered: true,
                              fontFamily: 'Bold'),
                        ),
                      ),
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
                        "New Listing",
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    // toast("value");
    return Sizer(
      builder: (context, orientation, deviceType) {
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
      },
    );
    return Scaffold(
      body: SafeArea(child: setUserForm()),
    );
  }
}

class GridItem extends StatefulWidget {
  final Key? key;
  final NewCategoryModel? item;
  final ValueChanged<bool>? isSelected;

  GridItem({this.item, this.isSelected, this.key});

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: InkWell(
        onTap: () {
          setState(() {
            isSelected = !isSelected;
            widget.isSelected!(isSelected);
          });
        },
        child: Container(
          color: Colors.blueGrey,
          height: 100,
          child: Stack(
            children: <Widget>[
              Text(widget.item!.name!),
              isSelected
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

// Padding editTextStyle(var hintText, var cn, final node, String alert,
//     Color sh_white, Color sh_view_color, int min_lne) {
//   return Padding(
//     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//     child: TextFormField(
//       maxLines: min_lne,
//       controller: cn,
//       onEditingComplete: () => node.nextFocus(),
//       style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
//       validator: (text) {
//         if (text == null || text.isEmpty) {
//           return alert;
//         }
//         return null;
//       },
//       cursorColor: sh_colorPrimary2,
//       decoration: InputDecoration(
//         contentPadding: EdgeInsets.fromLTRB(2, 16, 24, 6),
//         hintText: hintText,
//         hintStyle: TextStyle(color: sh_colorPrimary2, fontFamily: 'Regular'),
//         labelText: hintText,
//         labelStyle: TextStyle(color: sh_colorPrimary2, fontFamily: 'Bold'),
//         filled: true,
//         fillColor: sh_white,
//         enabledBorder: UnderlineInputBorder(
//             // borderRadius: BorderRadius.circular(20),
//             borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0)),
//         focusedBorder: UnderlineInputBorder(
//             // borderRadius: BorderRadius.circular(20),
//             borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0)),
//       ),
//     ),
//   );
// }
//
// Padding editTextStyle2(var hintText, var cn, final node, String alert,
//     Color sh_white, Color sh_view_color, int min_lne) {
//   return Padding(
//     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//     child: TextFormField(
//       maxLines: min_lne,
//       controller: cn,
//       onEditingComplete: () => node.nextFocus(),
//       style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
//       cursorColor: sh_app_txt_color,
//       decoration: InputDecoration(
//         contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
//         hintText: hintText,
//         hintStyle: TextStyle(color: sh_app_txt_color),
//         filled: true,
//         fillColor: sh_white,
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20),
//             borderSide: BorderSide(color: sh_view_color, width: 1.0)),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20),
//             borderSide: BorderSide(color: sh_view_color, width: 1.0)),
//       ),
//     ),
//   );
// }

Padding editTextStyle(var hintText, var cn, final node, String alert,
    Color sh_white, Color sh_view_color, int min_lne, context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      maxLines: min_lne,
      controller: cn,
      autofocus: false,
      onFieldSubmitted: (value) async {
        FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      // onEditingComplete: () => node.nextFocus(),
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      validator: (text) {
        if (text == null || text.isEmpty) {
          return alert;
        }
        return null;
      },
      cursorColor: sh_app_txt_color,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        hintText: hintText,
        hintStyle: TextStyle(color: sh_app_txt_color),
        filled: true,
        fillColor: sh_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
      ),
    ),
  );
}

Padding editTextStyle2(var hintText, var cn, final node, String alert,
    Color sh_white, Color sh_view_color, int min_lne, context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      autofocus: false,
      onFieldSubmitted: (value) async {
        FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      maxLines: min_lne,
      controller: cn,
      onEditingComplete: () => node.nextFocus(),
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      cursorColor: sh_app_txt_color,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        hintText: hintText,
        hintStyle: TextStyle(color: sh_app_txt_color),
        filled: true,
        fillColor: sh_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
      ),
    ),
  );
}

Padding editTextStyle3(var hintText, var cn, final node, String alert,
    Color sh_white, Color sh_view_color, int min_lne, context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      maxLines: min_lne,
      controller: cn,
      autofocus: false,
      keyboardType: TextInputType.numberWithOptions(decimal: true,signed: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) double.parse(text);
            return newValue;
          } catch (e) {}
          return oldValue;
        }),
      ],
      onFieldSubmitted: (value) async {
        FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      // onEditingComplete: () => node.nextFocus(),
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      validator: (text) {
        if (text == null || text.isEmpty) {
          return alert;
        }
        return null;
      },
      cursorColor: sh_app_txt_color,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 1/6),
        hintText: hintText,
        hintStyle: TextStyle(color: sh_app_txt_color),
        filled: true,
        fillColor: sh_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
      ),
    ),
  );
}

Padding editTextStyle4(var hintText, var cn, final node, String alert,
    Color sh_white, Color sh_view_color, int min_lne, context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: TextFormField(
      autofocus: false,
      onFieldSubmitted: (value) async {
        FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      keyboardType: TextInputType.numberWithOptions(decimal: true,signed: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) double.parse(text);
            return newValue;
          } catch (e) {}
          return oldValue;
        }),
      ],
      maxLines: min_lne,
      controller: cn,
      onEditingComplete: () => node.nextFocus(),
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      cursorColor: sh_app_txt_color,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        hintText: hintText,
        hintStyle: TextStyle(color: sh_app_txt_color),
        filled: true,
        fillColor: sh_white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sh_view_color, width: 1.0)),
      ),
    ),
  );
}


class AttrWidget extends StatefulWidget {
  // final AttributeModel? pro_det_model;
  AttributeModel? attributeModel;
  NewAttributeModel? itModel;
  List<NewAttributeModel> itemsModel = [];
  final List<NewCategoryModel> reportList;

  AttrWidget(this.attributeModel, this.itModel, this.itemsModel,this.reportList);

  @override
  State<StatefulWidget> createState() {
    return _AttrWidgetState();
  }
}

class _AttrWidgetState extends State<AttrWidget> {
  // String selectedReportList = '';
  List<TextEditingController>? _textFieldRateControllers=[];

  @override
  void initState() {
    super.initState();
  }

  bool isBooksSelected() {
    for (var category in widget.reportList) {
      if (category.name == 'Shoes' && category.selected == true) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // var _value = widget.pro_det_model!.attributes![widget.index!]!.options!.isEmpty
    //     ? selectedItemValue
    //     : widget.pro_det_model!.attributes![widget.index!]!.options!.firstWhere((item) => item.toString() == selectedItemValue.toString());

    if (widget.attributeModel!.data!.attributes!.length > 0) {
      return Visibility(
        visible: DataManager.getInstance().getIsSelected()=='True'?true:false,
        // widget.reportList.any((item) => item.selected == true),
        child: Container(
          child: ListView.builder(
              itemCount: widget.attributeModel!.data!.attributes!.length,
              physics: NeverScrollableScrollPhysics(),
              // itemExtent: 50.0,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                widget.itModel = NewAttributeModel(
                    name: widget.attributeModel!.data!.attributes![index]!.title!,
                    position: 0,
                    variation: true,
                    visible: true,
                    options: [],
                    required: widget
                        .attributeModel!.data!.attributes![index]!.required!,
                type: widget
                    .attributeModel!.data!.attributes![index]!.type!);

                widget.itemsModel.add(widget.itModel!);
                // if(attributeModel!.data!.attributes![index]!.title!)
                _textFieldRateControllers!.add(new TextEditingController());
                bool isShoesShowMain=(DataManager.getInstance().getIsShoesSelected()=='True');
                bool isShoesShow=(DataManager.getInstance().getIsShoesSelected()=='True'&&widget.attributeModel!.data!.attributes![index]!.title=='Size');

                bool isMainSizeShow=(widget.attributeModel!.data!.attributes![index]!.title=='Footware Size');

                print('isShoesShowMain'+DataManager.getInstance().getIsShoesSelected()=='True');
                print('isShoesShow'+DataManager.getInstance().getIsShoesSelected()=='True'&&widget.attributeModel!.data!.attributes![index]!.title=='Size');
                print('isMainSizeShow'+'${widget.attributeModel!.data!.attributes![index]!.title=='Footware Size'}');
                return isShoesShowMain?
                  Visibility(
visible: widget.attributeModel!.data!.attributes![index]!.title=='Size'? false:true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          text(widget.attributeModel!.data!.attributes![index]!.type=='text'
                              ? " Add " +
                              widget.attributeModel!.data!.attributes![index]!
                                  .title!:
                              " Select " +
                                  widget.attributeModel!.data!.attributes![index]!
                                      .title!,
                              textColor: sh_app_txt_color,
                              fontFamily: "Bold"),
                          Visibility(
                            visible: widget.attributeModel!.data!.attributes![index]!.type=='text'? false:true,
                            child: text("*",
                                textColor: widget.attributeModel!.data!
                                            .attributes![index]!.required ==
                                        "1"
                                    ? sh_red
                                    : sh_transparent,
                                fontFamily: "Bold"),
                          ),
                        ],
                      ),
                      PlayerWidget(
                          pro_det_model: widget.attributeModel!,
                          index: index,
                          itemsModel: widget.itemsModel,textFieldRateControllers: _textFieldRateControllers![index]),
                      SizedBox(height: 10),
                    ],
                  ),
                ) : Visibility(
                  visible: widget.attributeModel!.data!.attributes![index]!.title=='Footware Size'? false:true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          text(widget.attributeModel!.data!.attributes![index]!.type=='text'
                              ? " Add " +
                              widget.attributeModel!.data!.attributes![index]!
                                  .title!:
                          " Select " +
                              widget.attributeModel!.data!.attributes![index]!
                                  .title!,
                              textColor: sh_app_txt_color,
                              fontFamily: "Bold"),
                          Visibility(
                            visible: widget.attributeModel!.data!.attributes![index]!.type=='text'? false:true,
                            child: text("*",
                                textColor: widget.attributeModel!.data!
                                    .attributes![index]!.required ==
                                    "1"
                                    ? sh_red
                                    : sh_transparent,
                                fontFamily: "Bold"),
                          ),
                        ],
                      ),
                      PlayerWidget(
                          pro_det_model: widget.attributeModel!,
                          index: index,
                          itemsModel: widget.itemsModel,textFieldRateControllers: _textFieldRateControllers![index]),
                      SizedBox(height: 10),
                    ],
                  ),
                );
              }),
        ),
      );
    } else {
      return Container();
    }
  }
}

class PlayerWidget extends StatefulWidget {
  final AttributeModel? pro_det_model;
  final int? index;
  final List<NewAttributeModel>? itemsModel;
  final TextEditingController? textFieldRateControllers;

  PlayerWidget({Key? key, this.pro_det_model, this.index, this.itemsModel,this.textFieldRateControllers})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String? selectedItemValue = null;
  String selectedReportList = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState2) {
          if(widget.itemsModel![widget.index!].type=='text'){
            return TextFormField(
              maxLines: 1,
              controller: widget.textFieldRateControllers,
              autofocus: false,
              onFieldSubmitted: (value) async {
                FocusScope.of(context).unfocus();
                FocusScope.of(context).requestFocus(new FocusNode());
                widget.itemsModel![widget.index!].options!.clear();
                widget.itemsModel![widget.index!].options!.add(value);
              },
              onChanged:  (text) {
                widget.itemsModel![widget.index!].options!.clear();
                widget.itemsModel![widget.index!].options!.add(text);
              },
              // onEditingComplete: () => node.nextFocus(),
              style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
              // validator: (text) {
              //   if (text == null || text.isEmpty) {
              //     return "alert";
              //   }
              //   return null;
              // },
              cursorColor: sh_app_txt_color,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 16),
                hintText: "Add "+widget.itemsModel![widget.index!].name!,
                hintStyle: TextStyle(color: sh_app_txt_color),
                filled: true,
                fillColor: sh_white,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: sh_view_color, width: 1.0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: sh_view_color, width: 1.0)),
              ),
            );
          }else {
            return MultiAttributeChip(
              widget.pro_det_model!.data!.attributes![widget.index!]!.values!,
              widget.index!,
              widget.itemsModel,
              onSelectionChanged: (selectedList) {
                setState2(() {
                  selectedReportList = selectedList;
                });
              },
            );
          }
      //   Wrap(
      //   spacing: 8,
      //   direction: Axis.horizontal,
      //   children: techChips2(setState2),
      // );
    });
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<NewCategoryModel> reportList;
  final Function(List<int>)? onSelectionChanged;

  MultiSelectChip(this.reportList, {this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  // String selectedChoice = "";
  List<int> selectedChoices = [];



  _buildChoiceList() {
    var unescape = HtmlUnescape();
    List<Widget> choices = [];

    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(unescape.convert(item.name!)),
          selected: selectedChoices.contains(item.catid),
          labelStyle: TextStyle(
              color:
                  selectedChoices.contains(item.catid) ? sh_white : sh_black),
          selectedColor: sh_colorPrimary2,
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item.catid)
                  ? selectedChoices.remove(item.catid)
                  : selectedChoices.add(item.catid!);

              if(selectedChoices.isNotEmpty){
                DataManager.getInstance().setIsSelected('True');
              }else{
                DataManager.getInstance().setIsSelected('False');
              }

              if(selectedChoices.contains(188)){
                DataManager.getInstance().setIsShoesSelected('True');
              }else{
                DataManager.getInstance().setIsShoesSelected('False');
              }

              if((selectedChoices.contains(191)||selectedChoices.contains(195)
                  ||selectedChoices.contains(205)||selectedChoices.contains(193)||selectedChoices.contains(190)
                  ||selectedChoices.contains(192)||selectedChoices.contains(194))){
                DataManager.getInstance().setIsRequired('False');
              }else{
                DataManager.getInstance().setIsRequired('True');
              }


              widget.onSelectionChanged?.call(selectedChoices);

            });
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}

class MultiAttributeChip extends StatefulWidget {
  final List<AttributeModelDataAttributesValues?> reportList;
  final Function(String)? onSelectionChanged;
  final List<NewAttributeModel>? itemsModel;
  final int? index;

  MultiAttributeChip(this.reportList, this.index, this.itemsModel,
      {this.onSelectionChanged});

  @override
  _MultiAttributeChipState createState() => _MultiAttributeChipState();
}

class _MultiAttributeChipState extends State<MultiAttributeChip> {
  String selectedChoices = "";

  // List<String> selectedChoices = [];

  RemoveOther(String names) async {

    widget.itemsModel![widget.index!].options!.clear();

    widget.itemsModel![widget.index!].options!.add(names);
  }


  _buildChoiceList() {
    List<Widget> choices = [];

    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child:
        ChoiceChip(
          label: Text(item!.name!),
          labelStyle: TextStyle(
              color: selectedChoices == item.name ? sh_white : sh_black),
          selected: selectedChoices == item.name,
          selectedColor: sh_colorPrimary2,
          onSelected: (selected) {
            setState(() {
              if (selectedChoices == item.name!) {
                selectedChoices = '';
              } else {
                selectedChoices = item.name!;
              }
              print("myccc" + widget.index!.toString());
              widget.itemsModel![widget.index!].options!.contains(item.name)
                  ? widget.itemsModel![widget.index!].options!.remove(item.name)
                  : RemoveOther(item.name!);

              widget.onSelectionChanged?.call(selectedChoices);
            });
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}

class PhotoWidget extends StatefulWidget {
  List<MultiImageModel>? multimimageModel;
  final ImagePicker? picker;
  List<XFile>? imageFileList;

  PhotoWidget(
      {Key? key, this.multimimageModel, this.picker, this.imageFileList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PhotoWidgetState();
  }
}

class _PhotoWidgetState extends State<PhotoWidget> {
  @override
  void initState() {
    super.initState();
  }

  Future<String> testCompressAndGetFile(String filePath) async {
    // final filePath = file.absolute.path;
    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      filePath, outPath,
      quality: 60,
    );

    // print(file.lengthSync());
    print(result!.lengthSync());
    print(result.path.toString());

    return result.path;
  }

  @override
  Widget build(BuildContext context) {
    // var _value = widget.pro_det_model!.attributes![widget.index!]!.options!.isEmpty
    //     ? selectedItemValue
    //     : widget.pro_det_model!.attributes![widget.index!]!.options!.firstWhere((item) => item.toString() == selectedItemValue.toString());

    Single2(StateSetter setState2, int index) {
      if(index>4){
        // toast("abc");
        return Container();
      }
      else if (widget.multimimageModel!.length > 0 ||widget.multimimageModel!.length < 4) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: index == widget.multimimageModel!.length
              ? IconButton(
              color: sh_app_txt_color,
              icon: Image.asset(sh_add_image,width: 60,height: 60,fit: BoxFit.fill,color: sh_colorPrimary2,),
              onPressed: () async {
                // final pickedFileList =
                // await widget.picker!.pickMultiImage();
                final pickedFileList =
                await widget.picker!.pickMultiImage();
                if(pickedFileList!.length+widget.multimimageModel!.length>5){
                 toast("Maximum limit is 5");
                }else {
                  widget.imageFileList = pickedFileList;
                  for (var i = 0; i < pickedFileList.length; i++) {
                    widget.multimimageModel!.add(new MultiImageModel(
                        pickedFileList[i].name, await testCompressAndGetFile(pickedFileList[i].path)));
                  }
                  setState(() {

                  });
                }
                // if (bool) {
                //   fetchData();
                // }
              })
              : Stack(
            children: [
              ClipRRect(
                  borderRadius:
                  BorderRadius.all(Radius.circular(spacing_middle)),
                  child: Image.file(
                    File(widget.multimimageModel![index].path!),
                    fit: BoxFit.cover,
                    height: 300,
                    width: 300,
                  )),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    toast('delete image from List');

                    setState(() {
                      widget.multimimageModel!.removeAt(index);

                      print('set new state of images');
                    });
                  },
                  child: Icon(
                    Icons.delete,
                    color: sh_red,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      else {
        return IconButton(
            color: sh_app_txt_color,
            icon: Icon(
              Icons.add_circle_outline,
              size: 60,
            ),
            onPressed: () async {
              final pickedFileList = await widget.picker!.pickMultiImage();
              if(pickedFileList!.length+widget.multimimageModel!.length>5){
                toast("Maximum limit is 5");
              }else {
                widget.imageFileList = pickedFileList;
                for (var i = 0; i < pickedFileList.length; i++) {
                  widget.multimimageModel!.add(new MultiImageModel(
                      pickedFileList[i].name, await testCompressAndGetFile(pickedFileList[i].path)));
                }
                setState(() {
                  // widget.imageFileList = pickedFileList;
                  // for (var i = 0; i < pickedFileList.length; i++) {
                  //   widget.multimimageModel!.add(new MultiImageModel(
                  //       pickedFileList[i].name, pickedFileList[i].path));
                  // }
                });
              }
              // if (bool) {
              //   fetchData();
              // }
            });
      }
    }

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState2) {
      return Container(
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: widget.multimimageModel!.length + 1,
          itemBuilder: (context, index) {
            return Single2(setState2, index);
          },
        ),
      );
      //   Wrap(
      //   spacing: 8,
      //   direction: Axis.horizontal,
      //   children: techChips2(setState2),
      // );
    });

    ;
  }
}
