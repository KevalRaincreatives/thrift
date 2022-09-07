import 'dart:convert';
import 'dart:io' as i;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/retry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sizer/sizer.dart';
import 'package:thrift/model/AddProCategoryModel.dart';
import 'package:thrift/model/AddProMetaModel.dart';
import 'package:thrift/model/AddProMetaModel2.dart';
import 'package:thrift/model/AttributeModel.dart';
import 'package:thrift/model/CategoryModel.dart';
import 'package:thrift/model/CreateProModel.dart';
import 'package:thrift/model/EstPriceModel.dart';
import 'package:thrift/model/MultiImageModel.dart';
import 'package:thrift/model/MultiImageUploadModel.dart';
import 'package:thrift/model/MyVariant.dart';
import 'package:thrift/model/NewAttributeModel.dart';
import 'package:thrift/model/NewCategoryModel.dart';
import 'package:thrift/model/NewSelectedCategoryModel.dart';
import 'package:thrift/model/ProductDetailModel.dart';
import 'package:thrift/model/UploadImageModel.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';


class ProductUpdateScreen extends StatefulWidget {
  static String tag = '/ProductUpdateScreen';

  const ProductUpdateScreen({Key? key}) : super(key: key);

  @override
  _ProductUpdateScreenState createState() => _ProductUpdateScreenState();
}

class _ProductUpdateScreenState extends State<ProductUpdateScreen> {
  Widget? _form;
  List<CategoryModel> categoryListModel = [];

  List<NewCategoryModel> categoryListModel2 = [];
  List<NewSelectedCategoryModel> selectedList = [];
  List<int> selectedReportList = [];
  bool ischange = false;
  bool ischange2 = false;
  final ProductNameCont = TextEditingController();
  final ShortDescCont = TextEditingController();
  final DescCont = TextEditingController();
  final PriceCont = TextEditingController();
  final EstPriceCont=TextEditingController();
  final QtyCont = TextEditingController();
  final BrandCont = TextEditingController();
  final FaultsCont = TextEditingController();
  static final _formKey = GlobalKey<FormState>();
  AttributeModel? attributeModel;
  final List<NewAttributeModel> itemsModel = [];
  NewAttributeModel? itModel;
  final List<AddProCategoryModel> addProCatModel = [];
  final List<AddProMetaModel> addProMetaModel = [];
  final List<AddProMetaModel2> addProMetaModel2 = [];
  final List<MultiImageUploadModel> multimimageModel = [];
  List<XFile>? _imageFileList = [];
  final ImagePicker _picker = ImagePicker();
  final List<UploadImageModel> uploadModel = [];
  UploadImageModel? upModel;
  CreateProModel? createProModel;
  ProductDetailModel? pro_det_model;
  EstPriceModel? estPriceModel;
  int? cart_count;
  var maxLength = 500;
  var textLength = 0;


  @override
  void initState() {
    super.initState();
    fetchDetail();
    // fetchAlbum();
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
    try {
//      prefs = await SharedPreferences.getInstance();
//      String UserId = prefs.getString('UserId');
//       var response = await http.get(
//           Uri.parse("https://encros.rcstaging.co.in/wp-json/wc/v3/products/categories"));
      if (!ischange) {
        final client = RetryClient(http.Client());
        var response;
        try {
          response = await client.get(Uri.parse(
              "https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/categories?per_page=25"));
        } finally {
          client.close();
        }
        categoryListModel.clear();
        categoryListModel2.clear();

        print('Response status2: ${response.statusCode}');
        print('Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        for (Map i in jsonResponse) {
          categoryListModel.add(CategoryModel.fromJson(i));
//        orderListModel = new OrderListModel2.fromJson(i);
        }

        for (var i = 0; i < categoryListModel.length; i++) {
          var product2;
          try {
            product2 = pro_det_model!.categories!.firstWhere(
                  (product) => product!.id == categoryListModel[i].id,
            );
          } catch (e) {
            print('caught error $e');
          }
          if (product2 == null) {
            categoryListModel2.add(new NewCategoryModel(
                catid: categoryListModel[i].id,
                name: categoryListModel[i].name,
                selected: false));
          } else {
            selectedReportList.add(categoryListModel[i].id!);
            categoryListModel2.add(new NewCategoryModel(
                catid: categoryListModel[i].id,
                name: categoryListModel[i].name,
                selected: true));
          }
          // categoryListModel2.add(new NewCategoryModel(
          //     catid: categoryListModel[i].id,
          //     name: categoryListModel[i].name,
          //     selected: false));

        }
      }

      fetchAttribute();

      return categoryListModel2;
    } catch (e) {
      EasyLoading.dismiss();
//      return orderListModel;
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
              "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/attributes"));
        } finally {
          client.close();
        }
        attributeModel = null;
        itemsModel.clear();


        print('Response status2: ${response.statusCode}');
        print('Response body2: ${response.body}');
        final jsonResponse = json.decode(response.body);
        attributeModel = new AttributeModel.fromJson(jsonResponse);
      }
      EasyLoading.dismiss();

      setState(() {
        // _form==null;
      });
      return attributeModel;
    } catch (e) {
      EasyLoading.dismiss();
//      return orderListModel;
      print('caught error $e');
    }
  }

  Future<EstPriceModel?> fetchEstPrice() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');
      String? pro_id = prefs.getString('seller_pro_id');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(Uri.parse(
          'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/view_estimated_retail_price?product_id=$pro_id'),headers: headers);
      final jsonResponse = json.decode(response.body);
      print('not json prpr$jsonResponse');
      estPriceModel = new EstPriceModel.fromJson(jsonResponse);
      EstPriceCont.text = estPriceModel!.estimatedRetailPrice!;


      return estPriceModel;
    } catch (e) {
      // EasyLoading.dismiss();
//      return orderListModel;
      print('caught error $e');
    }
  }

  Future<CreateProModel?> AddProduct() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      addProMetaModel
          .add(new AddProMetaModel(key: "Brand", value: BrandCont.text));
      addProMetaModel
          .add(new AddProMetaModel(key: "Faults", value: FaultsCont.text));

      for (var j = 0; j < attributeModel!.data!.attributes!.length; j++) {
        if (itemsModel[j].options!.length > 0) {
          print(itemsModel[j].name! + itemsModel[j].options![0].toString());
          addProMetaModel.add(new AddProMetaModel(
              key: itemsModel[j].name!,
              value: itemsModel[j].options![0].toString()));
        }
      }

      // addProMetaModel.add(new AddProMetaModel(key: "color",value: "Black"));
      // addProMetaModel.add(new AddProMetaModel(key: "condition",value: "Old"));
      // addProMetaModel.add(new AddProMetaModel(key: "material",value: "Woolen"));
      // addProMetaModel.add(new AddProMetaModel(key: "size",value: "L"));
      // print(addProMetaModel.length.toString());
      // print(addProMetaModel[2].key.toString()+addProMetaModel[2].value.toString());
      // print(addProMetaModel[3].key.toString()+addProMetaModel[3].value.toString());
      // print(addProMetaModel[4].key.toString()+addProMetaModel[4].value.toString());
      // print(addProMetaModel[5].key.toString()+addProMetaModel[5].value.toString());

      addProMetaModel2
          .add(new AddProMetaModel2(key: "attrs_val", value: addProMetaModel));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? pro_id = prefs.getString('seller_pro_id');

      print(token);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // var body2 = json.encode({
      //
      //   "key": "attrs_val",
      //   "value": addProMetaModel
      // });

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
        // "attributes": itemsModel,
        "meta_data": addProMetaModel2
      });

      print(body);
      // var response = await http.put(
      //     Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/$pro_id'),
      //     body: body,
      //     headers: headers);

      var response = await http.post(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/$pro_id?_method=PUT'),
          body: body,
          headers: headers);

      print('Response body: addcart${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      createProModel = new CreateProModel.fromJson(jsonResponse);
      // EasyLoading.dismiss();
      toast("Product Update Successfully");
      ItemAdd(pro_id!);

      return createProModel;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  Future<String?> AddEstPrice(String prodId) async {
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
        "estimated_retail_price": EstPriceCont.text,
      });

      // final msg = jsonEncode({"username": username, "password": password});
      print(body);
      var response = await http.post(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/edit_estimated_retail_price'),
          body: body,
          headers: headers);

      print('Response body: addprice${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      EasyLoading.dismiss();

      // EasyLoading.dismiss();
      // toast("Image Uploaded Successfully");

      Navigator.pop(context);

      return "cat_model";
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  Future<String?> AddPhoto(String prodId) async {
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

      // toast(uploadModel.length.toString());

      var body = json.encode({
        "product_id": prodId,
        "product_images": uploadModel,
      });

      // final msg = jsonEncode({"username": username, "password": password});
      print(body);
      var response = await http.post(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/add_product_images'),
          body: body,
          headers: headers);

      print('Response body: addpic${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      if(EstPriceCont.text.length>0){
        AddEstPrice(prodId);
      }else{
        EasyLoading.dismiss();
        Navigator.pop(context);
      }

      return "cat_model";
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  Future<String?> DeletePhoto(String ImageId, int index) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? pro_id = prefs.getString('seller_pro_id');
      print(token);

      // Response response = await get(
      //     'https://encros.rcstaging.co.in/wp-json/v3/wooapp_add_to_cart?product_id=$pro_id&quantity=1');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };


      var body = json.encode({
        "product_id": pro_id,
        "image_id": ImageId,
      });

      // final msg = jsonEncode({"username": username, "password": password});
      print(body);
      var response = await http.post(
          Uri.parse(
              'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/delete_product_image'),
          body: body,
          headers: headers);

      print('Response body: delpic${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      EasyLoading.dismiss();

      toast("Image Deleted");
      setState(() {
        multimimageModel
            .removeAt(index);

        print(
            'set new state of images');
      });

      // Navigator.pop(context);

      return "cat_model";
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  void ItemAdd(String prodId) {
    for (var i = 0; i < multimimageModel.length; i++) {
      if (multimimageModel[i].newImage == "1") {
        File fls = File(multimimageModel[i].path!);
        Uint8List bytes = fls.readAsBytesSync();
        String base64Image = base64Encode(bytes);
        upModel =
            UploadImageModel(
                name: multimimageModel[i].name!, file: base64Image);
        uploadModel.add(upModel!);
      }
    }
    AddPhoto(prodId);
    print('object');
  }

  Future<ProductDetailModel?> fetchDetail() async {
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pro_id = prefs.getString('seller_pro_id');
      // toast(pro_id);
      print(
          "https://thriftapp.rcstaging.co.in//wp-json/wc/v3/products/$pro_id");
      var response = await http.get(Uri.parse(
          'https://thriftapp.rcstaging.co.in//wp-json/wc/v3/products/$pro_id'));
      final jsonResponse = json.decode(response.body);
      print('not json prpr$jsonResponse');
      pro_det_model = new ProductDetailModel.fromJson(jsonResponse);

      ProductNameCont.text = pro_det_model!.name!;
      // ShortDescCont.text = pro_det_model!.shortDescription!;
      DescCont.text = pro_det_model!.description!;
      textLength=pro_det_model!.description!.length;
      PriceCont.text = pro_det_model!.price!;
      BrandCont.text = pro_det_model!.metaData![0]!.value[0]!.value;
      FaultsCont.text = pro_det_model!.metaData![0]!.value[1]!.value;
      // pro_det_model!.images!.length

      for (var i = 0; i < pro_det_model!.images!.length;
      i++) {
        multimimageModel.add(
            new MultiImageUploadModel(
                pro_det_model!.images![i]!.src!,
                "", "0", pro_det_model!.images![i]!.id!.toString()));
      }

      fetchAlbum();
      fetchEstPrice();


      return pro_det_model;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;


    // toast("value");


    void _openCustomDialog(String ImageID, int index) {
      showGeneralDialog(barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            return Sizer(
                builder: (context, orientation, deviceType) {
                  return
                    Transform.scale(
                      scale: a1.value,
                      child: Opacity(
                        opacity: a1.value,
                        child: AlertDialog(
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          title: Center(child: Text(
                            'Are you sure you want to Delete?\n This action cannot be undone',
                            style: TextStyle(color: sh_colorPrimary2,
                                fontSize: 18,
                                fontFamily: 'Bold'),
                            textAlign: TextAlign.center,)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 16,),
                              InkWell(
                                onTap: () async {
                                  // BecameSeller();
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  DeletePhoto(ImageID, index);
                                  // _openCustomDialog2();
                                },
                                child: Container(
                                  width: 100.w,
                                  padding: EdgeInsets.only(
                                      top: 6, bottom: 10),
                                  decoration: boxDecoration(
                                      bgColor: sh_colorPrimary2,
                                      radius: 10,
                                      showShadow: true),
                                  child: text("Delete",
                                      fontSize: 16.0,
                                      textColor: sh_white,
                                      isCentered: true,
                                      fontFamily: 'Bold'),
                                ),
                              ),
                              SizedBox(height: 10,),
                              InkWell(
                                onTap: () async {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Container(
                                  width: 100.w,
                                  padding: EdgeInsets.only(
                                      top: 6, bottom: 10),
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
                }
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
            cart_count.toString(), style: TextStyle(color: sh_white,fontSize: 8),),
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

    // CheckVariant() {
    //   if (attributeModel!.data!.attributes!.length > 0) {
    //     return Container(
    //       child: ListView.builder(
    //           itemCount: attributeModel!.data!.attributes!.length,
    //           physics: NeverScrollableScrollPhysics(),
    //           // itemExtent: 50.0,
    //           shrinkWrap: true,
    //           itemBuilder: (BuildContext context, int index) {
    //             int? my_index = -1;
    //             for (var i = 0; i < pro_det_model!.metaData!.length; i++) {
    //               if (pro_det_model!.metaData![i]!.key == "attrs_val") {
    //                 my_index = i;
    //               }
    //             }
    //
    //             int? my_index2 = -1;
    //             for (var i = 0; i <
    //                 pro_det_model!.metaData![my_index!]!.value!.length; i++) {
    //               if (pro_det_model!.metaData![my_index]!.value![i]!.key ==
    //                   attributeModel!.data!.attributes![index]!.title!) {
    //                 my_index2 = i;
    //               }
    //             }
    //             if (my_index2 == -1) {
    //               itModel = NewAttributeModel(
    //                   name: attributeModel!.data!.attributes![index]!.title!,
    //                   position: 0,
    //                   variation: true,
    //                   visible: true,
    //                   options: [],
    //                   required:
    //                   attributeModel!.data!.attributes![index]!.required!);
    //             } else {
    //               itModel = NewAttributeModel(
    //                   name: attributeModel!.data!.attributes![index]!.title!,
    //                   position: 0,
    //                   variation: true,
    //                   visible: true,
    //                   options: [
    //                     pro_det_model!.metaData![my_index]!.value![my_index2]!
    //                         .value
    //                   ],
    //                   required:
    //                   attributeModel!.data!.attributes![index]!.required!
    //               );
    //             }
    //             itemsModel.add(itModel!);
    //             // if(attributeModel!.data!.attributes![index]!.title!)
    //
    //
    //             if (my_index2 == -1) {
    //               return Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[
    //                   text(
    //                       " Select " +
    //                           attributeModel!.data!.attributes![index]!.title!,
    //                       textColor: sh_app_txt_color,
    //                       fontFamily: "Bold"),
    //                   PlayerWidget(
    //                       pro_det_model: attributeModel!,
    //                       index: index,
    //                       selectedReportList: '',
    //                       itemsModel: itemsModel),
    //                   SizedBox(height: 10),
    //
    //                   // DropdownButton(
    //                   //   underline: SizedBox(),
    //                   //   isExpanded: true,
    //                   //   items: pro_det_model!.attributes![index]!.options!
    //                   //       .map((item) {
    //                   //     return new DropdownMenuItem(
    //                   //       child: Text(
    //                   //         item.toString(),
    //                   //         style: TextStyle(
    //                   //             color: sh_textColorPrimary,
    //                   //             fontFamily: fontRegular,
    //                   //             fontSize: textSizeNormal),
    //                   //       ),
    //                   //       value: item,
    //                   //     );
    //                   //   }).toList(),
    //                   //   hint: Text('Select'),
    //                   //   value: selectedValue,
    //                   //   onChanged: (String? newVal) {
    //                   //     selectedValue = newVal!;
    //                   //     setState(() {});
    //                   //   },
    //                   // ),
    //                 ],
    //               );
    //             } else {
    //               return Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[
    //
    //                   text(
    //                       " Select " +
    //                           attributeModel!.data!.attributes![index]!.title!,
    //                       textColor: sh_app_txt_color,
    //                       fontFamily: "Bold"),
    //                   PlayerWidget(
    //                       pro_det_model: attributeModel!,
    //                       index: index,
    //                       selectedReportList:
    //                       pro_det_model!.metaData![my_index]!.value![my_index2]!
    //                           .value,
    //                       itemsModel: itemsModel),
    //                   SizedBox(height: 10),
    //
    //                   // DropdownButton(
    //                   //   underline: SizedBox(),
    //                   //   isExpanded: true,
    //                   //   items: pro_det_model!.attributes![index]!.options!
    //                   //       .map((item) {
    //                   //     return new DropdownMenuItem(
    //                   //       child: Text(
    //                   //         item.toString(),
    //                   //         style: TextStyle(
    //                   //             color: sh_textColorPrimary,
    //                   //             fontFamily: fontRegular,
    //                   //             fontSize: textSizeNormal),
    //                   //       ),
    //                   //       value: item,
    //                   //     );
    //                   //   }).toList(),
    //                   //   hint: Text('Select'),
    //                   //   value: selectedValue,
    //                   //   onChanged: (String? newVal) {
    //                   //     selectedValue = newVal!;
    //                   //     setState(() {});
    //                   //   },
    //                   // ),
    //                 ],
    //               );
    //             }
    //           }),
    //     );
    //   } else {
    //     return Container();
    //   }
    // }

    final node = FocusScope.of(context);


    Single2(int index) {
      if(index>4){
        // toast("abc");
        return Container();
      }
      else if (multimimageModel.length > 0 ||multimimageModel.length < 4) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: index == multimimageModel.length
              ? IconButton(
              color: sh_app_txt_color,
              icon: Icon(
                Icons.add_box,
                size: 80,
              ),
              onPressed: () async {
                final pickedFileList =
                await _picker
                    .pickMultiImage();
                if(pickedFileList!.length+multimimageModel.length>5){
                  toast("Maximum limit is 5");
                }else {
                  setState(() {
                    _imageFileList =
                        pickedFileList;
                    for (var i = 0;
                    i <
                        pickedFileList
                            .length;
                    i++) {
                      multimimageModel.add(
                          new MultiImageUploadModel(
                              pickedFileList[i]
                                  .name,
                              pickedFileList[i]
                                  .path, "1", ""));
                    }
                  });
                }
                // if (bool) {
                //   fetchData();
                // }
              })
              : Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius
                      .all(Radius.circular(
                      spacing_middle)),
                  child: multimimageModel[index]
                      .newImage == "1" ?
                  Image.file(
                    File(multimimageModel[
                    index]
                        .path!),
                    fit: BoxFit.cover,
                    height: 300,
                    width: 300,
                  ) : Image.network(
                    multimimageModel[index].name!,
                    fit: BoxFit.cover,
                    height: 300,
                    width: 300,)),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    if (multimimageModel[index]
                        .newImage == "1") {
                      toast(
                          'delete image from List');

                      setState(() {
                        multimimageModel
                            .removeAt(index);

                        print(
                            'set new state of images');
                      });
                    } else {
                      _openCustomDialog(
                          multimimageModel[index]
                              .ImageId!, index);
                    }
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
              Icons.add_box,
              size: 80,
            ),
            onPressed: () async {
              final pickedFileList =
              await _picker.pickMultiImage();
              if(pickedFileList!.length+multimimageModel.length>5){
                toast("Maximum limit is 5");
              }else {
                setState(() {
                  _imageFileList = pickedFileList;
                  for (var i = 0;
                  i < pickedFileList.length;
                  i++) {
                    multimimageModel.add(
                        new MultiImageUploadModel(
                            pickedFileList[i].name,
                            pickedFileList[i].path, "1",
                            ""));
                  }
                });
              }
              // if (bool) {
              //   fetchData();
              // }
            });
      }
    }

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Update Product",
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
                padding: const EdgeInsets.fromLTRB(26,spacing_standard_new,26,spacing_standard_new),
                child: Container(
                  color: sh_white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        text(" Product Name",
                            textColor: sh_app_txt_color,
                            fontFamily: "Bold"),
                        text("*",
                            textColor: sh_red,
                            fontFamily: "Bold"),
                      ],),
                      // text(" Product Name",
                      //     textColor: sh_app_txt_color,
                      //     fontFamily: "Bold"),
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
                        height: spacing_middle,
                      ),
                      text(" Description",
                          textColor: sh_app_txt_color,
                          fontFamily: "Bold"),
                      // editTextStyle2(
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
                        height: spacing_middle,
                      ),
                      // text(" Short Description",
                      //     textColor: sh_app_txt_color,
                      //     fontFamily: "Bold"),
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
                      //   height: spacing_middle,
                      // ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  text(" Price",
                                      textColor: sh_app_txt_color,
                                      fontFamily: "Bold"),
                                  text("*",
                                      textColor: sh_red,
                                      fontFamily: "Bold"),
                                ],),
                                // text(" Price*",
                                //     textColor: sh_app_txt_color,
                                //     fontFamily: "Bold"),
                                editTextStyle3(
                                    "Price",
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
                        height: spacing_middle,
                      ),
                      text(" Estimated Retail Price",
                          textColor: sh_app_txt_color,
                          fontFamily: "Bold"),
                      editTextStyle4(
                          "Estimated Retail Price",
                          EstPriceCont,
                          node,
                          "Please Enter Estimated Retail Price",
                          sh_white,
                          sh_view_color,
                          1,
                          context),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Row(children: [
                        text(" Brand Name",
                            textColor: sh_app_txt_color,
                            fontFamily: "Bold"),
                        text("*",
                            textColor: sh_red,
                            fontFamily: "Bold"),
                      ],),
                      // text(" Brand Name",
                      //     textColor: sh_app_txt_color,
                      //     fontFamily: "Bold"),
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
                        height: spacing_middle,
                      ),
                      Row(children: [
                        text(" Faults",
                            textColor: sh_app_txt_color,
                            fontFamily: "Bold"),
                        text("*",
                            textColor: sh_red,
                            fontFamily: "Bold"),
                      ],),
                      // text(" Faults",
                      //     textColor: sh_app_txt_color,
                      //     fontFamily: "Bold"),
                      editTextStyle(
                          "Enter if any Faults",
                          FaultsCont,
                          node,
                          "Please Enter Faults",
                          sh_white,
                          sh_view_color,
                          1,
                          context),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      text(" Select Category",
                          textColor: sh_app_txt_color,
                          fontFamily: "Bold"),
                      MultiSelectChip(
                        categoryListModel2,
                        selectedReportList,
                        onSelectionChanged: (selectedList) {
                          // setState(() {
                          //   selectedReportList = selectedList;
                          // });
                        },
                      ),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      // CheckVariant(),
                      AttrWidget(
                          attributeModel,
                          pro_det_model,
                          itModel,
                          itemsModel
                      ),
                      // text(" Select Attribute", textColor: t6textColorPrimary),
                      // FutureBuilder<AttributeModel?>(
                      //   future: fetchAttribute(),
                      //   builder: (context, snapshot) {
                      //     if (snapshot.hasData) {
                      //       return CheckVariant();
                      //     }
                      //     return Center(
                      //         child: CircularProgressIndicator());
                      //   },
                      // ),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      text(" Add Photo",
                          textColor: sh_app_txt_color,
                          fontFamily: "Bold"),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Container(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                          itemCount: multimimageModel.length + 1,
                          itemBuilder: (context, index) {
                            return Single2(index);
                            // if (multimimageModel.length != 0) {
                            //   return Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: index == multimimageModel.length
                            //         ? IconButton(
                            //         color: sh_app_txt_color,
                            //         icon: Icon(
                            //           Icons.add_box,
                            //           size: 80,
                            //         ),
                            //         onPressed: () async {
                            //           final pickedFileList =
                            //           await _picker
                            //               .pickMultiImage();
                            //           setState(() {
                            //             _imageFileList =
                            //                 pickedFileList;
                            //             for (var i = 0;
                            //             i <
                            //                 pickedFileList!
                            //                     .length;
                            //             i++) {
                            //               multimimageModel.add(
                            //                   new MultiImageUploadModel(
                            //                       pickedFileList[i]
                            //                           .name,
                            //                       pickedFileList[i]
                            //                           .path, "1", ""));
                            //             }
                            //           });
                            //           // if (bool) {
                            //           //   fetchData();
                            //           // }
                            //         })
                            //         : Stack(
                            //       children: [
                            //         ClipRRect(
                            //             borderRadius: BorderRadius
                            //                 .all(Radius.circular(
                            //                 spacing_middle)),
                            //             child: multimimageModel[index]
                            //                 .newImage == "1" ?
                            //             Image.file(
                            //               File(multimimageModel[
                            //               index]
                            //                   .path!),
                            //               fit: BoxFit.cover,
                            //               height: 300,
                            //               width: 300,
                            //             ) : Image.network(
                            //               multimimageModel[index].name!,
                            //               fit: BoxFit.cover,
                            //               height: 300,
                            //               width: 300,)),
                            //         Positioned(
                            //           top: 0,
                            //           right: 0,
                            //           child: GestureDetector(
                            //             onTap: () async {
                            //               if (multimimageModel[index]
                            //                   .newImage == "1") {
                            //                 toast(
                            //                     'delete image from List');
                            //
                            //                 setState(() {
                            //                   multimimageModel
                            //                       .removeAt(index);
                            //
                            //                   print(
                            //                       'set new state of images');
                            //                 });
                            //               } else {
                            //                 _openCustomDialog(
                            //                     multimimageModel[index]
                            //                         .ImageId!, index);
                            //               }
                            //             },
                            //             child: Icon(
                            //               Icons.delete,
                            //               color: sh_red,
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   );
                            // } else {
                            //   return IconButton(
                            //       color: sh_app_txt_color,
                            //       icon: Icon(
                            //         Icons.add_box,
                            //         size: 80,
                            //       ),
                            //       onPressed: () async {
                            //         final pickedFileList =
                            //         await _picker.pickMultiImage();
                            //         setState(() {
                            //           _imageFileList = pickedFileList;
                            //           for (var i = 0;
                            //           i < pickedFileList!.length;
                            //           i++) {
                            //             multimimageModel.add(
                            //                 new MultiImageUploadModel(
                            //                     pickedFileList[i].name,
                            //                     pickedFileList[i].path, "1",
                            //                     ""));
                            //           }
                            //         });
                            //         // if (bool) {
                            //         //   fetchData();
                            //         // }
                            //       });
                            // }
                          },
                        ),
                      ),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            //   // TODO submit
                            FocusScope.of(context).requestFocus(FocusNode());
                            for (var i = 0; i <
                                selectedReportList.length; i++) {
                              addProCatModel.add(new AddProCategoryModel(
                                  id: selectedReportList[i]));
                            }
                            // toast(itemsModel.length.toString());
                            // if (itemsModel[0].options!.length > 0) {
                            //   print(itemsModel[0].name! +
                            //       itemsModel[0].options![0].toString());
                            // }
                            // if (itemsModel[1].options!.length > 0) {
                            //   print(itemsModel[1].name! +
                            //       itemsModel[1].options![0].toString());
                            // }
                            // if (itemsModel[2].options!.length > 0) {
                            //   print(itemsModel[2].name! +
                            //       itemsModel[2].options![0].toString());
                            // }
                            // if (itemsModel[3].options!.length > 0) {
                            //   print(itemsModel[3].name! +
                            //       itemsModel[3].options![0].toString());
                            // }
                            // if (multimimageModel.length > 0) {
                            int jj = 0;
                            String mj = '';

                            for (var j = 0; j < attributeModel!.data!.attributes!.length; j++) {
                              if (itemsModel[j].required == '1') {
                                if (itemsModel[j].options!.length == 0) {
                                  jj++;
                                  mj = itemsModel[j].name!;
                                  break;
                                }
                              }
                            }
                            // toast(jj.toString());
                            if (jj > 0) {
                              toast("Please Select $mj");
                            } else {
                              AddProduct();
                            }
                            // AddProduct();
                            // }else{
                            //   toast("Please add a photo");
                            // }
                          }
                        },
                        child: Container(
                          width: 100.w,
                          padding: EdgeInsets.only(
                              top: spacing_middle,
                              bottom: spacing_middle),
                          decoration: boxDecoration(
                              bgColor: sh_app_background,
                              radius: 10,
                              showShadow: true),
                          child: text("UPDATE",
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
                      padding: const EdgeInsets.fromLTRB(0,6,6,6.0),
                      child: Text(
                        "Update Product",
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
                        SharedPreferences prefs = await SharedPreferences
                            .getInstance();
                        prefs.setInt("shiping_index", -2);
                        prefs.setInt("payment_index", -2);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CartScreen()),).then((value) {
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

    return Sizer(
        builder: (context, orientation, deviceType) {
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
        FocusScope.of(context).requestFocus(new
        FocusNode());
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
        FocusScope.of(context).requestFocus(new
        FocusNode());
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
  ProductDetailModel? pro_det_model;
  NewAttributeModel? itModel;
  List<NewAttributeModel> itemsModel = [];

  AttrWidget(this.attributeModel, this.pro_det_model, this.itModel,
      this.itemsModel)
  ;

  @override
  State<StatefulWidget> createState() {
    return _AttrWidgetState();
  }
}

class _AttrWidgetState extends State<AttrWidget> {
  // String selectedReportList = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var _value = widget.pro_det_model!.attributes![widget.index!]!.options!.isEmpty
    //     ? selectedItemValue
    //     : widget.pro_det_model!.attributes![widget.index!]!.options!.firstWhere((item) => item.toString() == selectedItemValue.toString());

    if (widget.attributeModel!.data!.attributes!.length > 0) {
      return Container(
        child: ListView.builder(
            itemCount: widget.attributeModel!.data!.attributes!.length,
            physics: NeverScrollableScrollPhysics(),
            // itemExtent: 50.0,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              int? my_index = -1;
              for (var i = 0; i < widget.pro_det_model!.metaData!.length; i++) {
                if (widget.pro_det_model!.metaData![i]!.key == "attrs_val") {
                  my_index = i;
                }
              }

              int? my_index2 = -1;
              for (var i = 0; i <
                  widget.pro_det_model!.metaData![my_index!]!.value!
                      .length; i++) {
                if (widget.pro_det_model!.metaData![my_index]!.value![i]!.key ==
                    widget.attributeModel!.data!.attributes![index]!.title!) {
                  my_index2 = i;
                }
              }
              if (my_index2 == -1) {
                widget.itModel = NewAttributeModel(
                    name: widget.attributeModel!.data!.attributes![index]!
                        .title!,
                    position: 0,
                    variation: true,
                    visible: true,
                    options: [],
                    required:
                    widget.attributeModel!.data!.attributes![index]!.required!);
              } else {
                widget.itModel = NewAttributeModel(
                    name: widget.attributeModel!.data!.attributes![index]!
                        .title!,
                    position: 0,
                    variation: true,
                    visible: true,
                    options: [
                      widget.pro_det_model!.metaData![my_index]!
                          .value![my_index2]!.value
                    ],
                    required:
                    widget.attributeModel!.data!.attributes![index]!.required!);
              }
              widget.itemsModel.add(widget.itModel!);
              // if(attributeModel!.data!.attributes![index]!.title!)


              if (my_index2 == -1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(children: [
                      text(
                          " Select " +
                              widget.attributeModel!.data!.attributes![index]!
                                  .title!,
                          textColor: sh_app_txt_color,
                          fontFamily: "Bold"),
                      text("*",
                          textColor: widget.attributeModel!.data!.attributes![index]!
                              .required=="1" ? sh_red:sh_transparent,
                          fontFamily: "Bold"),
                    ],),

                    PlayerWidget(
                        pro_det_model: widget.attributeModel!,
                        index: index,
                        selectedReportList: '',
                        itemsModel: widget.itemsModel),
                    SizedBox(height: 10),


                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(children: [
                      text(
                          " Select " +
                              widget.attributeModel!.data!.attributes![index]!
                                  .title!,
                          textColor: sh_app_txt_color,
                          fontFamily: "Bold"),
                      text("*",
                          textColor: widget.attributeModel!.data!.attributes![index]!
                              .required=="1" ? sh_red:sh_transparent,
                          fontFamily: "Bold"),
                    ],),
                    // text(
                    //     " Select " +
                    //         widget.attributeModel!.data!.attributes![index]!
                    //             .title!,
                    //     textColor: sh_app_txt_color,
                    //     fontFamily: "Bold"),
                    PlayerWidget(
                        pro_det_model: widget.attributeModel!,
                        index: index,
                        selectedReportList:
                        widget.pro_det_model!.metaData![my_index]!
                            .value![my_index2]!.value,
                        itemsModel: widget.itemsModel),
                    SizedBox(height: 10),


                  ],
                );
              }
            }),
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
  String? selectedReportList;

  PlayerWidget(
      {Key? key, this.pro_det_model, this.index, this.selectedReportList, this.itemsModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String? selectedItemValue = null;

  // String selectedReportList = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var _value = widget.pro_det_model!.attributes![widget.index!]!.options!.isEmpty
    //     ? selectedItemValue
    //     : widget.pro_det_model!.attributes![widget.index!]!.options!.firstWhere((item) => item.toString() == selectedItemValue.toString());

    List<Widget> techChips2(StateSetter setState2) {
      List<Widget> chips = [];
      for (int i = 0;
      i <
          widget.pro_det_model!.data!.attributes![widget.index!]!.values!
              .length;
      i++) {
        Widget item = Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: FilterChip(
            label: Text(widget.pro_det_model!.data!.attributes![widget.index!]!
                .values![i]!.name!),
            labelStyle: TextStyle(color: Colors.white),
            backgroundColor: Colors.grey,
            selectedColor: Colors.blue.shade800,
            disabledColor: Colors.blue.shade400,
            // selected: categoryListModel2[i].selected!,
            onSelected: (bool value) {
              // ischange = true;
              setState2(() {
                // categoryListModel2[i].selected = value;
              });
            },
          ),
        );
        chips.add(item);
      }
      return chips;
    }

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState2) {
          return MultiAttributeChip(
            widget.pro_det_model!.data!.attributes![widget.index!]!.values!,
            widget.index!,
            widget.itemsModel,
            widget.selectedReportList,
            onSelectionChanged: (selectedList) {
              setState2(() {
                widget.selectedReportList = selectedList;
              });
            },
          );
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
  List<int> selectedChoices;

  MultiSelectChip(this.reportList, this.selectedChoices,
      {this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  // String selectedChoice = "";
  // List<int> selectedChoices = [];

  _buildChoiceList() {
    var unescape = HtmlUnescape();
    List<Widget> choices = [];

    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(unescape.convert(item.name!)),
          selected: widget.selectedChoices.contains(item.catid),
          labelStyle: TextStyle(
              color: widget.selectedChoices.contains(item.catid)
                  ? sh_white
                  : sh_black),
          selectedColor: sh_colorPrimary2,
          onSelected: (selected) {
            setState(() {
              widget.selectedChoices.contains(item.catid)
                  ? widget.selectedChoices.remove(item.catid)
                  : widget.selectedChoices.add(item.catid!);
              widget.onSelectionChanged?.call(widget.selectedChoices);
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
  String? selectedChoices;

  MultiAttributeChip(this.reportList, this.index, this.itemsModel,
      this.selectedChoices,
      {this.onSelectionChanged});

  @override
  _MultiAttributeChipState createState() => _MultiAttributeChipState();
}

class _MultiAttributeChipState extends State<MultiAttributeChip> {
  // String selectedChoices = "";
  // List<String> selectedChoices = [];

  RemoveOther(String names) async {
    widget.itemsModel![widget.index!].options!.clear();

    widget.itemsModel![widget.index!].options!.add(names);
  }

  // RemoveOther2(String names) async {
  //   selectedChoices.clear();
  //   selectedChoices.add(names);
  // }

  _buildChoiceList() {
    List<Widget> choices = [];

    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item!.name!),
          labelStyle: TextStyle(
              color: widget.selectedChoices == item.name ? sh_white : sh_black),
          selected: widget.selectedChoices == item.name,
          selectedColor: sh_colorPrimary2,
          onSelected: (selected) {
            setState(() {
              if (widget.selectedChoices == item.name!) {
                widget.selectedChoices = '';
              } else {
                widget.selectedChoices = item.name!;
              }
              print("myccc" + widget.index!.toString());
              widget.itemsModel![widget.index!].options!.contains(item.name)
                  ? widget.itemsModel![widget.index!].options!.remove(item.name)
                  : RemoveOther(item.name!);

              // selectedChoices.contains(item.name)
              //     ? selectedChoices.remove(item.name)
              //     : RemoveOther2(item.name!);
              widget.onSelectionChanged?.call(widget.selectedChoices!);
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
