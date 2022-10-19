// import 'dart:convert';
// import 'dart:io' as i;
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:http/retry.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:thrift/model/AddProCategoryModel.dart';
// import 'package:thrift/model/AddProMetaModel.dart';
// import 'package:thrift/model/AddProMetaModel2.dart';
// import 'package:thrift/model/AttributeModel.dart';
// import 'package:thrift/model/CategoryModel.dart';
// import 'package:thrift/model/CreateProModel.dart';
// import 'package:thrift/model/MultiImageModel.dart';
// import 'package:thrift/model/MyVariant.dart';
// import 'package:thrift/model/NewAttributeModel.dart';
// import 'package:thrift/model/NewCategoryModel.dart';
// import 'package:thrift/model/NewSelectedCategoryModel.dart';
// import 'package:thrift/model/UploadImageModel.dart';
// import 'package:thrift/screens/CartScreen.dart';
// import 'package:thrift/utils/ShColors.dart';
// import 'package:thrift/utils/ShConstant.dart';
// import 'package:thrift/utils/ShExtension.dart';
// import 'package:http/http.dart' as http;
// import 'package:thrift/utils/T6Colors.dart';
//
// class CreateProductScreen extends StatefulWidget {
//   static String tag = '/CreateProductScreen';
//
//   const CreateProductScreen({Key? key}) : super(key: key);
//
//   @override
//   _CreateProductScreenState createState() => _CreateProductScreenState();
// }
//
// class _CreateProductScreenState extends State<CreateProductScreen> {
//   List<CategoryModel> categoryListModel = [];
//
//   List<NewCategoryModel> categoryListModel2 = [];
//   List<NewSelectedCategoryModel> selectedList = [];
//   List<int> selectedReportList = [];
//   bool ischange = false;
//   bool ischange2 = false;
//   var ProductNameCont = TextEditingController();
//   var ShortDescCont = TextEditingController();
//   var DescCont = TextEditingController();
//   var PriceCont = TextEditingController();
//   var QtyCont = TextEditingController();
//   var BrandCont = TextEditingController();
//   var FaultsCont = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   AttributeModel? attributeModel;
//   final List<NewAttributeModel> itemsModel = [];
//   NewAttributeModel? itModel;
//   final List<AddProCategoryModel> addProCatModel = [];
//   final List<AddProMetaModel> addProMetaModel = [];
//   final List<AddProMetaModel2> addProMetaModel2 = [];
//   final List<MultiImageModel> multimimageModel=[];
//   List<XFile>? _imageFileList=[];
//   final ImagePicker _picker = ImagePicker();
//   final List<UploadImageModel> uploadModel = [];
//   UploadImageModel? upModel;
//   CreateProModel? createProModel;
//
//   Future<List<NewCategoryModel>?> fetchAlbum() async {
//
//     try {
// //      prefs = await SharedPreferences.getInstance();
// //      String UserId = prefs.getString('UserId');
// //       var response = await http.get(
// //           Uri.parse("https://encros.rcstaging.co.in/wp-json/wc/v3/products/categories"));
//       if (!ischange) {
//         final client = RetryClient(http.Client());
//         var response;
//         try {
//           response = await client.get(Uri.parse(
//               "https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products/categories"));
//         } finally {
//           client.close();
//         }
//         categoryListModel.clear();
//         categoryListModel2.clear();
//
//         print('Response status2: ${response.statusCode}');
//         print('Response body2: ${response.body}');
//         final jsonResponse = json.decode(response.body);
//         for (Map i in jsonResponse) {
//           categoryListModel.add(CategoryModel.fromJson(i));
// //        orderListModel = new OrderListModel2.fromJson(i);
//         }
//
//         for (var i = 0; i < categoryListModel.length; i++) {
//           categoryListModel2.add(new NewCategoryModel(
//               catid: categoryListModel[i].id,
//               name: categoryListModel[i].name,
//               selected: false));
//         }
//       }
//
//       return categoryListModel2;
//     } catch (e) {
// //      return orderListModel;
//       print('caught error $e');
//     }
//   }
//
//   Future<AttributeModel?> fetchAttribute() async {
//     try {
// //      prefs = await SharedPreferences.getInstance();
// //      String UserId = prefs.getString('UserId');
// //       var response = await http.get(
// //           Uri.parse("https://encros.rcstaging.co.in/wp-json/wc/v3/products/categories"));
//       if (!ischange2) {
//         final client = RetryClient(http.Client());
//         var response;
//         try {
//           response = await client.get(Uri.parse(
//               "https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/attributes"));
//         } finally {
//           client.close();
//         }
//         attributeModel=null;
//         itemsModel.clear();
//
//         print('Response status2: ${response.statusCode}');
//         print('Response body2: ${response.body}');
//         final jsonResponse = json.decode(response.body);
//         attributeModel = new AttributeModel.fromJson(jsonResponse);
//
//
//       }
//
//       return attributeModel;
//     } catch (e) {
// //      return orderListModel;
//       print('caught error $e');
//     }
//   }
//
//   Future<List<AddProMetaModel>?> getUserNameSharedPreference() async{
//     for (var j = 0; j < itemsModel.length; j++) {
//       if(itemsModel[j].options!.length>0){
//         print(itemsModel[j].name! + itemsModel[j].options![0].toString());
//         addProMetaModel.add(new AddProMetaModel(key: itemsModel[j].name!,value: itemsModel[j].options![0].toString()));
//       }
//     }
//     return addProMetaModel;
//   }
//
//   Future<CreateProModel?> AddProduct() async {
//     EasyLoading.show(status: 'Please wait...');
//     try {
//
//         addProMetaModel.add(new AddProMetaModel(key: "Brand",value: BrandCont.text));
//         addProMetaModel.add(new AddProMetaModel(key: "Faults",value: FaultsCont.text));
//
//         await getUserNameSharedPreference().then((value) {
//
//         });
//
//         //  for (var j = 0; j < itemsModel.length; j++) {
//         //   if(itemsModel[j].options!.length>0){
//         //     print(itemsModel[j].name! + itemsModel[j].options![0].toString());
//         //     addProMetaModel.add(new AddProMetaModel(key: itemsModel[j].name!,value: itemsModel[j].options![0].toString()));
//         //   }
//         // }
//
//
//
//
//         // addProMetaModel.add(new AddProMetaModel(key: "color",value: "Black"));
//         // addProMetaModel.add(new AddProMetaModel(key: "condition",value: "Old"));
//         // addProMetaModel.add(new AddProMetaModel(key: "material",value: "Woolen"));
//         // addProMetaModel.add(new AddProMetaModel(key: "size",value: "L"));
//         // print(addProMetaModel.length.toString());
//         // print(addProMetaModel[2].key.toString()+addProMetaModel[2].value.toString());
//         // print(addProMetaModel[3].key.toString()+addProMetaModel[3].value.toString());
//         // print(addProMetaModel[4].key.toString()+addProMetaModel[4].value.toString());
//         // print(addProMetaModel[5].key.toString()+addProMetaModel[5].value.toString());
//
//
// addProMetaModel2.add(new AddProMetaModel2(key: "attrs_val",value: addProMetaModel));
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         String? token = prefs.getString('token');
//
//         print(token);
//
//
//         Map<String, String> headers = {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//         };
//
//         // var body2 = json.encode({
//         //
//         //   "key": "attrs_val",
//         //   "value": addProMetaModel
//         // });
//
//       var body = json.encode({
//         "name":ProductNameCont.text,
//         "type":"simple",
//         "description":DescCont.text,
//         "short_description":ShortDescCont.text,
//         "price":PriceCont.text,
//         "manage_stock":true,
//         "stock_quantity":"1",
//         "stock_status":"instock",
//         "regular_price":PriceCont.text,
//         "categories":addProCatModel,
//         // "attributes": itemsModel,
//         "meta_data": addProMetaModel2
//       });
//
//         print(body);
//         var response = await http.post(
//             Uri.parse(
//                 'https://thriftapp.rcstaging.co.in/wp-json/wc/v3/products'),
//             body: body,
//             headers: headers);
//
//         print('Response body: addcart${response.body}');
//         final jsonResponse = json.decode(response.body);
//         print('not json $jsonResponse');
//         createProModel = new CreateProModel.fromJson(jsonResponse);
//
//
//
//         toast("Product Created Successfully");
//         ItemAdd(createProModel!.id.toString());
//
//
//       return createProModel;
//     } catch (e) {
//       EasyLoading.dismiss();
//       print('caught error $e');
//     }
//   }
//
//   Future<String?> AddPhoto(String prodId) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');
//
//       print(token);
//
//       // Response response = await get(
//       //     'https://encros.rcstaging.co.in/wp-json/v3/wooapp_add_to_cart?product_id=$pro_id&quantity=1');
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//
//       var body = json.encode({
//         "product_id":prodId,
//         "product_images":uploadModel,
//       });
//
//       // final msg = jsonEncode({"username": username, "password": password});
//       print(body);
//       var response = await http.post(
//           Uri.parse(
//               'https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/add_product_images'),
//           body: body,
//           headers: headers);
//
//       print('Response body: addcart${response.body}');
//       final jsonResponse = json.decode(response.body);
//       print('not json $jsonResponse');
//       EasyLoading.dismiss();
//
//       EasyLoading.dismiss();
//       toast("Image Uploaded Successfully");
//
//       Navigator.pop(context);
//
//       return "cat_model";
//     } catch (e) {
//       EasyLoading.dismiss();
//       print('caught error $e');
//     }
//   }
//
//   void ItemAdd(String prodId) {
//     for (var i = 0; i < multimimageModel.length; i++) {
//       File fls = File(multimimageModel[i].path!);
//       Uint8List bytes = fls.readAsBytesSync();
//       String base64Image = base64Encode(bytes);
//       upModel =
//           UploadImageModel(name: multimimageModel[i].name!, file: base64Image);
//       uploadModel.add(upModel!);
//     }
//     AddPhoto(prodId);
//     print('object');
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     // multimimageModel.add(MultiImageModel("",""));
//     // _imageFileList!.add(XFile(""));
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     Widget prepareList(int k) {
//       return Card(
//         child: Hero(
//           tag: "text$k",
//           child: Material(
//             child: InkWell(
//               onTap: () {},
//               child: Container(
//                 color: Colors.blueGrey,
//                 height: 100,
//                 child: Stack(
//                   children: [
//                     Center(
//                         child: Text(
//                       categoryListModel2[k].name!,
//                       style: TextStyle(color: Colors.white, fontSize: 20),
//                     )),
//                     Positioned(
//                         child: Checkbox(
//                       value: categoryListModel2[k].selected,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           if (!value!) categoryListModel2[k].selected = value;
//                         });
//                       },
//                     ))
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     List<Widget> techChips() {
//       List<Widget> chips = [];
//       for (int i = 0; i < categoryListModel2.length; i++) {
//         Widget item = Padding(
//           padding: const EdgeInsets.only(left: 5, right: 5),
//           child: FilterChip(
//             label: Text(categoryListModel2[i].name!),
//             labelStyle: TextStyle(color: Colors.white),
//             backgroundColor: Colors.grey,
//             selectedColor: Colors.blue.shade800,
//             disabledColor: Colors.blue.shade400,
//             selected: categoryListModel2[i].selected!,
//             onSelected: (bool value) {
//               ischange = true;
//               setState(() {
//                 categoryListModel2[i].selected = value;
//               });
//             },
//           ),
//         );
//         chips.add(item);
//       }
//       return chips;
//     }
//
//
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//
//     CheckVariant() {
//       if (attributeModel!.data!.attributes!.length > 0) {
//         return Container(
//           child: ListView.builder(
//               itemCount: attributeModel!.data!.attributes!.length,
//               physics: NeverScrollableScrollPhysics(),
//               // itemExtent: 50.0,
//               shrinkWrap: true,
//               itemBuilder: (BuildContext context, int index) {
//                 // itModel = MyVariant(
//                 //     attr_name:  pro_det_model!.attributes![index]!.name!,
//                 //     attr_optn:  "");
//                 // itemsModel.add(itModel!);
//                 // itemsModel.clear();
//                 itModel = NewAttributeModel(
//                     name :  attributeModel!.data!.attributes![index]!.title!,
//                 position: 0,
//                 variation: true,
//                 visible: true,
//                 options: []);
//                 itemsModel.add(itModel!);
//
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     // Text(
//                     //   "Select "+attributeModel!.data!.attributes![index]!.title!,
//                     //   style: TextStyle(
//                     //       fontSize: 16,
//                     //       fontFamily: 'Bold',
//                     //       color: sh_textColorPrimary),
//                     // ),
//                     text(" Select "+attributeModel!.data!.attributes![index]!.title!, textColor: sh_app_txt_color,fontFamily: "Bold"),
//                     PlayerWidget(
//                         pro_det_model: attributeModel!,
//                         index: index,
//                         itemsModel: itemsModel),
//                     SizedBox(height: 10),
//
//                     // DropdownButton(
//                     //   underline: SizedBox(),
//                     //   isExpanded: true,
//                     //   items: pro_det_model!.attributes![index]!.options!
//                     //       .map((item) {
//                     //     return new DropdownMenuItem(
//                     //       child: Text(
//                     //         item.toString(),
//                     //         style: TextStyle(
//                     //             color: sh_textColorPrimary,
//                     //             fontFamily: fontRegular,
//                     //             fontSize: textSizeNormal),
//                     //       ),
//                     //       value: item,
//                     //     );
//                     //   }).toList(),
//                     //   hint: Text('Select'),
//                     //   value: selectedValue,
//                     //   onChanged: (String? newVal) {
//                     //     selectedValue = newVal!;
//                     //     setState(() {});
//                     //   },
//                     // ),
//                   ],
//                 );
//               }),
//         );
//       } else {
//         return Container();
//       }
//     }
//
//     final node = FocusScope.of(context);
//
//     Widget setUserForm() {
//       AppBar appBar = AppBar(
//         elevation: 0,
//         backgroundColor: sh_colorPrimary2,
//         title: Text(
//           "New Listing",
//           style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
//         ),
//         iconTheme: IconThemeData(color: sh_white),
//         actions: <Widget>[
//           GestureDetector(
//             onTap: () {
//               launchScreen(context, CartScreen.tag);
//             },
//             child: Image.asset(
//               sh_new_cart,
//               height: 50,
//               width: 50,
//               color: sh_white,
//             ),
//
//           ),
//           SizedBox(
//             width: 22,
//           ),
//         ],
//       );
//       double app_height = appBar.preferredSize.height;
//       return Stack(children: <Widget>[
//         // Background with gradient
//         Container(
//             height: 120,
//             width: width,
//             child: Image.asset(sh_upper2,fit: BoxFit.fill)
//           // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
//         ),
//         //Above card
//
//         Container(
//           height: height,
//           width: width,
//           color: sh_white,
//           margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Padding(
//                 padding: const EdgeInsets.all(spacing_standard_new),
//                 child: Container(
//                   color: sh_white,
//                   child: Column(
//
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       text(" Product Name", textColor: sh_app_txt_color,fontFamily: "Bold"),
//                       editTextStyle("Product Name", ProductNameCont, node,
//                           "Please Enter Product Name", sh_white, sh_view_color, 1),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//                       text(" Description", textColor: sh_app_txt_color,fontFamily: "Bold"),
//                       editTextStyle("Description", DescCont, node,
//                           "Please Enter Description", sh_white, sh_view_color, 5),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//                       text(" Short Description", textColor: sh_app_txt_color,fontFamily: "Bold"),
//                       editTextStyle("Short Description", ShortDescCont, node,
//                           "Please Enter Description", sh_white, sh_view_color, 2),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//                       Row(
//                         children: <Widget>[
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 text(" Price", textColor: sh_app_txt_color,fontFamily: "Bold"),
//                                 editTextStyle("Price", PriceCont, node,
//                                     "Please Enter Price", sh_white, sh_view_color, 1),
//                               ],
//                             ),
//                           ),
//
//                         ],
//                       ),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//                       text(" Brand Name", textColor: sh_app_txt_color,fontFamily: "Bold"),
//                       editTextStyle("Enter Brand", BrandCont, node,
//                           "Please Enter Brand", sh_white, sh_view_color, 1),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//                       text(" Faults", textColor: sh_app_txt_color,fontFamily: "Bold"),
//                       editTextStyle2("Enter if any Faults", FaultsCont, node,
//                           "Please Enter Faults", sh_white, sh_view_color, 1),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//                       text(" Select Category", textColor: sh_app_txt_color,fontFamily: "Bold"),
//                       FutureBuilder<List<NewCategoryModel>?>(
//                         future: fetchAlbum(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return MultiSelectChip(
//                               categoryListModel2,
//                               onSelectionChanged: (selectedList) {
//                                 setState(() {
//                                   selectedReportList = selectedList;
//                                 });
//                               },
//                             );
//                             // GridView.builder(
//                             //   itemCount: categoryListModel2.length,
//                             //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             //       crossAxisCount: 4,
//                             //       childAspectRatio: 1.0,
//                             //       crossAxisSpacing: 2,
//                             //       mainAxisSpacing: 2),
//                             //   itemBuilder: (context, index) {
//                             //     return GridItem(
//                             //         item: categoryListModel2[index],
//                             //         isSelected: (bool value) {
//                             //           setState(() {
//                             //             if (value) {
//                             //               selectedList.add(new NewSelectedCategoryModel(selcatid: categoryListModel2[index].catid!));
//                             //             } else {
//                             //               selectedList.remove(new NewSelectedCategoryModel(selcatid: categoryListModel2[index].catid!));
//                             //             }
//                             //           });
//                             //           print("$index : $value");
//                             //         },
//                             //         key: Key(categoryListModel2[index].catid.toString()));
//                             //   });
//                             //   GridView.builder(
//                             //   shrinkWrap: true,
//                             //   itemBuilder: (ctx,index){
//                             //     return prepareList(index);
//                             //   },
//                             //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount
//                             //     (crossAxisCount: 3),
//                             //   itemCount: categoryListModel.length,
//                             // );
//                           }
//                           return Center(child: CircularProgressIndicator());
//                         },
//                       ),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//
//                       // text(" Select Attribute", textColor: t6textColorPrimary),
//                       FutureBuilder<AttributeModel?>(
//                         future: fetchAttribute(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return CheckVariant();
//                             // GridView.builder(
//                             //   itemCount: categoryListModel2.length,
//                             //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             //       crossAxisCount: 4,
//                             //       childAspectRatio: 1.0,
//                             //       crossAxisSpacing: 2,
//                             //       mainAxisSpacing: 2),
//                             //   itemBuilder: (context, index) {
//                             //     return GridItem(
//                             //         item: categoryListModel2[index],
//                             //         isSelected: (bool value) {
//                             //           setState(() {
//                             //             if (value) {
//                             //               selectedList.add(new NewSelectedCategoryModel(selcatid: categoryListModel2[index].catid!));
//                             //             } else {
//                             //               selectedList.remove(new NewSelectedCategoryModel(selcatid: categoryListModel2[index].catid!));
//                             //             }
//                             //           });
//                             //           print("$index : $value");
//                             //         },
//                             //         key: Key(categoryListModel2[index].catid.toString()));
//                             //   });
//                             //   GridView.builder(
//                             //   shrinkWrap: true,
//                             //   itemBuilder: (ctx,index){
//                             //     return prepareList(index);
//                             //   },
//                             //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount
//                             //     (crossAxisCount: 3),
//                             //   itemCount: categoryListModel.length,
//                             // );
//                           }
//                           return Center(child: CircularProgressIndicator());
//                         },
//                       ),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//                       text(" Add Photo", textColor: sh_app_txt_color,fontFamily: "Bold"),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//                       Container(
//                         child: GridView.builder(
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3),
//                           itemCount: multimimageModel.length+1,
//                           itemBuilder: (context, index) {
//                             if (multimimageModel.length != 0) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: index == multimimageModel.length ? IconButton(
//                                     color: sh_app_txt_color,
//                                     icon: Icon(Icons.add_box,size: 80,),
//                                     onPressed: () async {
//                                       final pickedFileList = await _picker.pickMultiImage();
//                                       setState(() {
//                                         _imageFileList = pickedFileList;
//                                         for (var i = 0; i < pickedFileList!.length; i++) {
//                                           multimimageModel.add(new MultiImageModel(pickedFileList[i].name,pickedFileList[i].path));
//                                         }
//                                       });
//                                       // if (bool) {
//                                       //   fetchData();
//                                       // }
//                                     }) : Stack(
//                                   children: [ClipRRect(
//                                       borderRadius:
//                                       BorderRadius.all(Radius.circular(spacing_middle)),
//                                       child: Image.file(File(multimimageModel[index].path!),fit: BoxFit.cover,height: 300,width: 300,)),
//                                     Positioned(
//                                       top: 0,
//                                       right: 0,
//                                       child: GestureDetector(
//                                         onTap: (){
//                                           toast('delete image from List');
//
//                                           setState((){
//                                             multimimageModel.removeAt(index);
//
//                                             print('set new state of images');
//                                           });
//                                         },
//                                         child: Icon(
//                                           Icons.delete,
//                                           color: sh_red,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             } else {
//                               return IconButton(
//                                   color: sh_app_txt_color,
//                                   icon: Icon(Icons.add_box,size: 80,),
//                                   onPressed: () async {
//                                     final pickedFileList = await _picker.pickMultiImage();
//                                     setState(() {
//                                       _imageFileList = pickedFileList;
//                                       for (var i = 0; i < pickedFileList!.length; i++) {
//                                         multimimageModel.add(new MultiImageModel(pickedFileList[i].name,pickedFileList[i].path));
//
//                                       }
//                                     });
//                                     // if (bool) {
//                                     //   fetchData();
//                                     // }
//                                   });
//                             }
//                           },
//                         ),
//                       ),
//                       SizedBox(
//                         height: spacing_middle,
//                       ),
//                       InkWell(
//                         onTap: () async {
//                           if (_formKey.currentState!.validate()) {
//                             //   // TODO submit
//                             FocusScope.of(context).requestFocus(FocusNode());
//                             for (var i = 0; i < selectedReportList.length; i++) {
//                               addProCatModel.add(new AddProCategoryModel(
//                                   id: selectedReportList[i]));
//                             }
//                             toast(itemsModel.length.toString());
//                           if(itemsModel[0].options!.length>0){
//                             print(itemsModel[0].name! +
//                                 itemsModel[0].options![0].toString());
//                           }
//       if(itemsModel[1].options!.length>0) {
//         print(itemsModel[1].name! + itemsModel[1].options![0].toString());
//       }
//       if(itemsModel[2].options!.length>0) {
//         print(itemsModel[2].name! + itemsModel[2].options![0].toString());
//       }
//       if(itemsModel[3].options!.length>0) {
//         print(itemsModel[3].name! + itemsModel[3].options![0].toString());
//       }
//                             if (multimimageModel.length > 0) {
//                               AddProduct();
//                             }else{
//                               toast("Please add a photo");
//                             }
//                           }
//                         },
//                         child: Container(
//                           width: MediaQuery.of(context).size.width,
//                           padding: EdgeInsets.only(
//                               top: spacing_middle, bottom: spacing_middle),
//                           decoration: boxDecoration(
//                               bgColor: sh_app_background, radius: 10, showShadow: true),
//                           child: text("Add Product",
//                               textColor: sh_app_txt_color,
//                               isCentered: true,
//                               fontFamily: 'Bold'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         // Positioned to take only AppBar size
//         Positioned(
//           top: 0.0,
//           left: 0.0,
//           right: 0.0,
//           child: Container(
//             padding: const EdgeInsets.fromLTRB(0,spacing_middle4,0,0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(6.0,2,6,2),
//                       child: IconButton(onPressed: () {
//                         Navigator.pop(context);
//                       }, icon: Icon(Icons.chevron_left_rounded,color: Colors.white,size: 36,)),
//                     ),
//
//                     Padding(
//                       padding: const EdgeInsets.all(6.0),
//                       child: Text("New Listing",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Cursive'),),
//                     )
//                   ],
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     launchScreen(context, CartScreen.tag);
//                   },
//                   child: Container(
//                     padding: EdgeInsets.fromLTRB(4, 0, 20, 0),
//                     child: Image.asset(
//                       sh_new_cart,
//                       height: 50,
//                       width: 50,
//                       color: sh_white,
//                     ),
//                   ),
//
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//       ]);
//     }
//
//     return Scaffold(
//
//       body: SafeArea(child: setUserForm()),
//     );
//   }
// }
//
// class GridItem extends StatefulWidget {
//   final Key? key;
//   final NewCategoryModel? item;
//   final ValueChanged<bool>? isSelected;
//
//   GridItem({this.item, this.isSelected, this.key});
//
//   @override
//   _GridItemState createState() => _GridItemState();
// }
//
// class _GridItemState extends State<GridItem> {
//   bool isSelected = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100,
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             isSelected = !isSelected;
//             widget.isSelected!(isSelected);
//           });
//         },
//         child: Container(
//           color: Colors.blueGrey,
//           height: 100,
//           child: Stack(
//             children: <Widget>[
//               Text(widget.item!.name!),
//               isSelected
//                   ? Align(
//                       alignment: Alignment.bottomRight,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Icon(
//                           Icons.check_circle,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     )
//                   : Container()
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
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
// cursorColor: sh_app_txt_color,
//
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
//
// class PlayerWidget extends StatefulWidget {
//   final AttributeModel? pro_det_model;
//   final int? index;
//   final List<NewAttributeModel>? itemsModel;
//
//   PlayerWidget({
//     Key? key,
//     this.pro_det_model,
//     this.index,
//     this.itemsModel
//   }) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() {
//     return _PlayerWidgetState();
//   }
// }
//
// class _PlayerWidgetState extends State<PlayerWidget> {
//   String? selectedItemValue=null;
//   List<String> selectedReportList = [];
//
//
//
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     // var _value = widget.pro_det_model!.attributes![widget.index!]!.options!.isEmpty
//     //     ? selectedItemValue
//     //     : widget.pro_det_model!.attributes![widget.index!]!.options!.firstWhere((item) => item.toString() == selectedItemValue.toString());
//
//     List<Widget> techChips2(StateSetter setState2) {
//       List<Widget> chips = [];
//       for (int i = 0; i < widget.pro_det_model!.data!.attributes![widget.index!]!.values!.length; i++) {
//         Widget item = Padding(
//           padding: const EdgeInsets.only(left: 5, right: 5),
//           child: FilterChip(
//             label: Text(widget.pro_det_model!.data!.attributes![widget.index!]!.values![i]!.name!),
//             labelStyle: TextStyle(color: Colors.white),
//             backgroundColor: Colors.grey,
//             selectedColor: Colors.blue.shade800,
//             disabledColor: Colors.blue.shade400,
//             // selected: categoryListModel2[i].selected!,
//             onSelected: (bool value) {
//               // ischange = true;
//               setState2(() {
//                 // categoryListModel2[i].selected = value;
//               });
//             },
//           ),
//         );
//         chips.add(item);
//       }
//       return chips;
//     }
//
//     return StatefulBuilder(
//         builder: (BuildContext context, StateSetter setState2) {
//
//
//
//           return MultiAttributeChip(
//             widget.pro_det_model!.data!.attributes![widget.index!]!.values!,
//             widget.index!,
//               widget.itemsModel,
//             onSelectionChanged: (selectedList) {
//               setState2(() {
//                 selectedReportList = selectedList;
//               });
//             },
//           );
//           //   Wrap(
//           //   spacing: 8,
//           //   direction: Axis.horizontal,
//           //   children: techChips2(setState2),
//           // );
//         })
//
//     ;
//   }
// }
//
// class MultiSelectChip extends StatefulWidget {
//   final List<NewCategoryModel> reportList;
//   final Function(List<int>)? onSelectionChanged;
//
//   MultiSelectChip(this.reportList, {this.onSelectionChanged});
//
//   @override
//   _MultiSelectChipState createState() => _MultiSelectChipState();
// }
//
// class _MultiSelectChipState extends State<MultiSelectChip> {
//   // String selectedChoice = "";
//   List<int> selectedChoices = [];
//
//   _buildChoiceList() {
//     List<Widget> choices = [];
//
//     widget.reportList.forEach((item) {
//       choices.add(Container(
//         padding: const EdgeInsets.all(2.0),
//         child: ChoiceChip(
//           label: Text(item.name!),
//           selected: selectedChoices.contains(item.catid),
//           onSelected: (selected) {
//               setState(() {
//                 selectedChoices.contains(item.catid)
//                     ? selectedChoices.remove(item.catid)
//                     : selectedChoices.add(item.catid!);
//                 widget.onSelectionChanged?.call(selectedChoices);
//               });
//
//           },
//         ),
//       ));
//     });
//
//     return choices;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       children: _buildChoiceList(),
//     );
//   }
// }
//
// class MultiAttributeChip extends StatefulWidget {
//   final List<AttributeModelDataAttributesValues?> reportList;
//   final Function(List<String>)? onSelectionChanged;
//   final List<NewAttributeModel>? itemsModel;
//   final int? index;
//
//   MultiAttributeChip(this.reportList,this.index,this.itemsModel, {this.onSelectionChanged});
//
//   @override
//   _MultiAttributeChipState createState() => _MultiAttributeChipState();
// }
//
// class _MultiAttributeChipState extends State<MultiAttributeChip> {
//   // String selectedChoice = "";
//   List<String> selectedChoices = [];
//
//   RemoveOther(String names) async{
//     // for (var j = 0; j < widget.itemsModel!.length; j++) {
//       // if(j==widget.index){
//       //   widget.itemsModel![widget.index!].options!.add(names);
//       // }else{
//       //   widget.itemsModel![widget.index!].options!.remove(names);
//       // }
//
//      // }
//
//
//     // for (var j = 0; j < widget.itemsModel![widget.index!].options!.length; j++) {
//     //   widget.itemsModel![widget.index!].options![j].removeAllWhiteSpace();
//     // }
//
//     widget.itemsModel![widget.index!].options!.clear();
//
//     widget.itemsModel![widget.index!].options!.add(names);
//
//   }
//
//   RemoveOther2(String names) async{
// selectedChoices.clear();
// selectedChoices.add(names);
//   }
//
//   _buildChoiceList() {
//     List<Widget> choices = [];
//
//     widget.reportList.forEach((item) {
//       choices.add(Container(
//         padding: const EdgeInsets.all(2.0),
//         child: ChoiceChip(
//           label: Text(item!.name!),
//           selected: selectedChoices.contains(item.name),
//           onSelected: (selected) {
//             setState(() {
// print("myccc"+widget.index!.toString());
//               widget.itemsModel![widget.index!].options!.contains(item.name)
//                   ? widget.itemsModel![widget.index!].options!.remove(item.name)
//                   : RemoveOther(item.name!);
//
//               selectedChoices.contains(item.name)
//                   ? selectedChoices.remove(item.name)
//                   : RemoveOther2(item.name!);
//               widget.onSelectionChanged?.call(selectedChoices);
//             });
//
//           },
//         ),
//       ));
//     });
//
//     return choices;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       children: _buildChoiceList(),
//     );
//   }
// }
