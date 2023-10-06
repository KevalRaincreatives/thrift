import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import 'dart:convert';
import 'package:thrift/api_service/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/model/ProductListModel.dart';
import 'package:thrift/model/SearchModel.dart';
import 'package:thrift/provider/home_product_provider.dart';
import 'package:thrift/screens/ProductDetailScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:http/http.dart' as http;
import 'package:thrift/utils/ShExtension.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/custom_pop_up_menu.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';

import '../provider/search_provider.dart';
class ItemModel {
  String title;

  ItemModel(this.title);
}

class SearchNewScreen extends StatefulWidget {
  const SearchNewScreen({Key? key}) : super(key: key);

  @override
  State<SearchNewScreen> createState() => _SearchNewScreenState();
}

class _SearchNewScreenState extends State<SearchNewScreen> {
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
  // List<ProductListModel> productListModel = [];
  TextEditingController shopcontroller = TextEditingController();
  TextEditingController colorcontroller = TextEditingController();
  bool lasttime=true;
  List<String> _status = ["All","Popularity", "Latest", "Price Low to High", "Price High to Low"];
  // Future<String?>? fetchaddMain;
  late List<ItemModel> menuItems;
  CustomPopupMenuController _controller = CustomPopupMenuController();
  String? _selectsize;
  List<String> list_size=[];
  final FocusNode node = FocusNode();
  List<String> list_condition=[];
  String? _selectcondition;

  @override
  void initState() {
    super.initState();
    // SearchNewData();
    // fetchaddMain=fetchadd();
    menuItems = [
      ItemModel('Newest to Oldest'),
      ItemModel('Oldest to Newest'),
      ItemModel('Price High to Low'),
      ItemModel('Price Low to High'),
    ];
    startInit();
  }

  startInit()async{
    final postHome = Provider.of<HomeProductListProvider>(context, listen: false);
    final postMdl = Provider.of<SearchProvider>(context, listen: false);
    postMdl.fetchstart();
    postMdl.getDropVal();

   await postHome.fetchAttribute();
    for (var j = 0; j < postHome.attributeModel!.data!.attributes!.length; j++) {
      if (postHome.attributeModel!.data!.attributes![j]!.title=='Condition') {
        for (var k = 0; k < postHome.attributeModel!.data!.attributes![j]!.values!.length; k++) {
          list_condition.add(postHome.attributeModel!.data!.attributes![j]!.values![k]!.name!);
        }
      }else if (postHome.attributeModel!.data!.attributes![j]!.title=='Size') {
        for (var k = 0; k < postHome.attributeModel!.data!.attributes![j]!.values!.length; k++) {
          list_size.add(postHome.attributeModel!.data!.attributes![j]!.values![k]!.name!);
        }
      }
    }

  }

  Future<String?> fetchadd() async {
    try {
      if(firsttime!) {
        searchController.text = 'widget.serchdata!';
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
    // final searchpro = Provider.of<SearchProvider>(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    Imagevw4(int index,productListModel) {
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
          child: CachedNetworkImage(
            imageUrl: productListModel[index].images![0]!.src!,
            fit: BoxFit.cover,
            height: 130,
            alignment: Alignment.topCenter,
            width: width,
            // memCacheWidth: width,
            filterQuality: FilterQuality.low,
            placeholder: (context, url) =>
                Center(
                  child: SizedBox(
                      height: 30,
                      width: 30,
                      child:
                      CircularProgressIndicator()),
                ),
            errorWidget:
                (context, url, error) =>
            new Icon(Icons.error),
          )
        );
      }
    }

    NewImagevw(int index,productListModel) {
      return Imagevw4(index,productListModel);
    }

    MyPrice(int index,productListModel){
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

    Future refineSheet(context) async {
      showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(

                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20,6,20,10),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filter By",
                            style: TextStyle(color:sh_colorPrimary2,fontSize: 24,fontWeight: FontWeight.w700),
                          ),
                          // const Spacer(),
                          Consumer<SearchProvider>(builder: ((context, value, child) {
                            return InkWell(
                              onTap: () {
                                // setState(() {
                                //   photographyProvider.loader = true;
                                // });
                                // this.setState(() {
                                //   editorcontroller.clear();
                                //   selectedCategory = null;
                                //   selectedBrand = null;
                                //   _priceValues = const RangeValues(100, 5000);
                                // });
                                setState(() {
                                  shopcontroller.text='';
                                  colorcontroller.text='';
                                  _selectsize=null;
                                  _selectcondition=null;
                                });

                                value.fetchSearch(searchController.text, value.filter_str!,'','',null,null);
                                Future.delayed(
                                  const Duration(seconds: 1),
                                      () {
                                    Navigator.pop(context);
                                  },
                                );
                                // load();
                                // Navigator.pop(context);
                              },
                              child: Text(
                                "Clear all",
                                style: TextStyle(color:sh_colorPrimary2,fontSize: 12,fontWeight: FontWeight.w500,decoration: TextDecoration.underline),
                              ),
                            );
                          }))

                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Enter Vendor Shop',
                        style: TextStyle(color:sh_colorPrimary2,fontWeight: FontWeight.w700),
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        controller: shopcontroller,
                        style: TextStyle(color:sh_colorPrimary2,fontSize: 14,),
                        decoration: inputDecoration(
                          context,
                          hint: "Vendor shop name",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Enter Color',
                        style: TextStyle(color:sh_colorPrimary2,fontWeight: FontWeight.w700),
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        controller: colorcontroller,

                        style: TextStyle(color:sh_colorPrimary2,fontSize: 14,),
                        decoration: inputDecoration(
                          context,
                          hint: "Enter Color",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter by Size',
                            style: TextStyle(color:sh_colorPrimary2,fontWeight: FontWeight.w700),
                          ),
                          InkWell(
                            onTap: () {

                              setState(() {
                                _selectsize=null;
                              });

                            },
                            child: Text(
                              "Clear",
                              style: TextStyle(color:sh_colorPrimary2,fontSize: 12,fontWeight: FontWeight.w500,decoration: TextDecoration.underline),
                            ),
                          )
                        ],),

                      const SizedBox(
                        height: 4,
                      ),
                      Consumer<SearchProvider>(builder: ((context, value, child) {
                        return Row(
                          children: [
                            Expanded(
                              flex:5,
                              child: Container(
                                width: 50.w,
                                decoration:  BoxDecoration(
                                    border: Border(bottom: BorderSide(color: sh_colorPrimary2))),
                                child: Theme(
                                  data: Theme.of(context)
                                      .copyWith(dividerColor: Colors.transparent),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      iconEnabledColor: sh_colorPrimary2,
                                      iconDisabledColor: sh_colorPrimary2,
                                      underline: Container(),
                                      // decoration: InputDecoration(
                                      //     labelText: 'Change Country'
                                      // ),

                                      isExpanded: true,
                                      items: list_size.map((item) {
                                        return new DropdownMenuItem(
                                          child: Center(
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                  color: sh_colorPrimary2,
                                                  fontFamily: fontRegular,
                                                  fontSize: textSizeMedium),
                                            ),
                                          ),
                                          value: item,
                                        );
                                      }).toList(),
                                      hint: Text('Select Size',style: TextStyle(
                                          color: sh_colorPrimary2,
                                          fontFamily: fontRegular,
                                          fontSize: textSizeMedium)),
                                      value: _selectsize!=null || _selectsize!="" ? _selectsize : list_size[0],
                                      onChanged: (String? newVal) async{
                                        _selectsize=newVal;
                                        value.changeDropDownVal(newVal);

                                        // prefs.setString('user_selected_country', newVal.country!);

                                        // setState(() {
                                        //   selectedValue = newVal;
                                        //
                                        // });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        );
                      })),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter by Condition',
                            style: TextStyle(color:sh_colorPrimary2,fontWeight: FontWeight.w700),
                          ),
                          InkWell(
                            onTap: () {

                              setState(() {
                                _selectcondition=null;
                              });

                            },
                            child: Text(
                              "Clear",
                              style: TextStyle(color:sh_colorPrimary2,fontSize: 12,fontWeight: FontWeight.w500,decoration: TextDecoration.underline),
                            ),
                          )
                        ],),

                      const SizedBox(
                        height: 4,
                      ),
                      Consumer<SearchProvider>(builder: ((context, value, child) {
                        return Row(
                          children: [
                            Expanded(
                              flex:7,
                              child: Container(
                                width: 50.w,
                                decoration:  BoxDecoration(
                                    border: Border(bottom: BorderSide(color: sh_colorPrimary2))),
                                child: Theme(
                                  data: Theme.of(context)
                                      .copyWith(dividerColor: Colors.transparent),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      iconEnabledColor: sh_colorPrimary2,
                                      iconDisabledColor: sh_colorPrimary2,
                                      underline: Container(),
                                      // decoration: InputDecoration(
                                      //     labelText: 'Change Country'
                                      // ),

                                      isExpanded: true,
                                      items: list_condition.map((item) {
                                        return new DropdownMenuItem(
                                          child: Center(
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                  color: sh_colorPrimary2,
                                                  fontFamily: fontRegular,
                                                  fontSize: textSizeMedium),
                                            ),
                                          ),
                                          value: item,
                                        );
                                      }).toList(),
                                      hint: Text('Select Condition',style: TextStyle(
                                          color: sh_colorPrimary2,
                                          fontFamily: fontRegular,
                                          fontSize: textSizeMedium)),
                                      value: _selectcondition!=null || _selectcondition!="" ? _selectcondition : list_condition[0],
                                      onChanged: (String? newVal) async{
                                        _selectcondition=newVal;
                                        value.changeConditionDropDownVal(newVal);

                                        // prefs.setString('user_selected_country', newVal.country!);

                                        // setState(() {
                                        //   selectedValue = newVal;
                                        //
                                        // });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        );
                      })),

                      const SizedBox(
                        height: 50,
                      ),
                      Consumer<SearchProvider>(builder: ((context, value, child) {
                        return ElevatedButton(
                          onPressed: () async{
                            Navigator.pop(context);
                            if(shopcontroller.text==''&&colorcontroller.text==''&&_selectsize==null&&_selectcondition==null){
                              toast('Please apply any filter');
                            }else {
                              value.fetchSearch(
                                  searchController.text, value.filter_str!,
                                  shopcontroller.text, colorcontroller.text,
                                  _selectsize,_selectcondition);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(MediaQuery.of(context).size.width, 40),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(color: sh_white, width: 1),
                                borderRadius: BorderRadius.circular(2)),
                            backgroundColor: sh_colorPrimary2,
                          ),
                          child: Text(
                            'Apply',
                            style: TextStyle(color:sh_white,fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        );
                      }))
                      ,
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }


    searchList(productListModel){
      if (productListModel.length == 0) {
        if(shopcontroller.text==''&&colorcontroller.text==''&&_selectsize==null) {
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
        }else{
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SizedBox(height: 80,),
              text("No results found for \"" + searchController.text + "\"",
                  textColor: sh_textColorPrimary,
                  fontFamily: fontMedium,
                  fontSize: textSizeMedium),
              SizedBox(height: 6,),
              text10("Please change your filters or try a different keywords", fontFamily: fontMedium,
                  textColor: sh_textColorSecondary,
                  maxLine: 2,
                  isCentered: true,
                  fontSize: textSizeSMedium),

              SizedBox(height: 12,),
              InkWell(
                onTap: ()
                {
                  refineSheet(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      color: sh_colorPrimary2,
                  ),
                  padding: EdgeInsets.fromLTRB(8,10,8,12),
                  child:  Center(
                    child: text("Change Filters", fontFamily: fontMedium,
                        textColor: sh_white,
                        fontSize: textSizeSMedium),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              InkWell(
                onTap: () {

                  setState(() {
                    shopcontroller.text='';
                    colorcontroller.text='';
                    _selectsize=null;
                  });

                  Provider.of<SearchProvider>(context, listen: false).fetchSearch(searchController.text, Provider.of<SearchProvider>(context, listen: false).filter_str!,'','',null,null);

                },
                child: text("Clear all filters", fontFamily: fontMedium,
                    textColor: sh_colorPrimary2,
                    fontSize: textSizeSMedium),
              ),
          ],);
        }
      }
      else {
        return Flexible(
          child: AnimationLimiter(
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
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences
                                .getInstance();
                            prefs.setString(
                                'pro_id', productListModel[index].id.toString());
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
                                    builder: (context) =>
                                        ProductDetailScreen(
                                          proName: productListModel[index].name,
                                          proPrice: productListModel[index].price,
                                          proImage: myimages,)));
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
                                NewImagevw(index, productListModel),
                                SizedBox(
                                  height: 6,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: spacing_standard,
                                      right: spacing_standard),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Html(
                                        data: productListModel[index].name!,
                                        style: {
                                          "body": Style(
                                            maxLines: 1,
                                            margin: EdgeInsets.zero, padding: EdgeInsets.zero,
                                            fontSize: FontSize(16.0),
                                            fontWeight: FontWeight.bold,
                                            color: sh_black,
                                            fontFamily: fontBold,
                                          ),
                                        },
                                      ),
                                      // Text(
                                      //   productListModel[index].name!,
                                      //   maxLines: 1,
                                      //   style: TextStyle(
                                      //       color: sh_black,
                                      //       fontFamily: fontBold,
                                      //       fontSize: textSizeMedium),
                                      // ),
                                      SizedBox(
                                        height: 6,
                                      ),


                                      MyPrice(index, productListModel),

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
                // _scaffoldKey.currentState!.openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: Text(
          'profile_name'!,
          style: TextStyle(
              color: sh_white, fontSize: 20, fontFamily: 'TitleCursive'),
        ),
        iconTheme: IconThemeData(color: sh_white),

      );
      double app_height = appBar.preferredSize.height;
      return Stack(children: <Widget>[
        // Background with gradient
        Container(
          color: sh_colorPrimary2,
          height: 40,
          width: width,
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        Container(
            margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
            height: 120,
            width: width,
            child: Image.asset(sh_upper2,fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Consumer<SearchProvider>(builder: ((context, value, child) {
            return  Container(
              // color: sh_green,
              padding: const EdgeInsets.fromLTRB(15, spacing_xxLarge, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          // _scaffoldKey.currentState!.openDrawer();
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 2, 0, 2),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // _scaffoldKey.currentState!.openDrawer();
                            },
                            icon: new Icon(Icons.arrow_back_outlined,size: 26,color: sh_white,),
                            // tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
            //   AppBar(
            //   elevation: 0,
            //   backgroundColor: sh_colorPrimary2,
            //   title: value.isSearch ? TextFormField(
            //     onFieldSubmitted: (value) {
            //       Provider.of<SearchProvider>(context, listen: false).fetchSearch(value,"Newest to Oldest","","","");
            //       // setState(() {
            //       //   searchText = value;
            //       //   isEmpty = false;
            //       //   isLoadingMoreData = true;
            //       //   firsttime=false;
            //       // });
            //       // SearchData();
            //
            //     },
            //     controller: searchController,
            //     textInputAction: TextInputAction.search,
            //     style: TextStyle(fontSize: textSizeMedium, color: sh_white),
            //     decoration: InputDecoration( hintText: "Search",focusColor: sh_white,hintStyle: TextStyle(color: sh_white)),
            //     keyboardType: TextInputType.text,
            //     textAlign: TextAlign.start,
            //   ) : Text(searchController.text,style: TextStyle(color: sh_white,fontSize: 13.sp),),
            //   iconTheme: IconThemeData(color: sh_white),
            //   actions: <Widget>[
            //     value.isSearch
            //         ? Padding(
            //       padding: const EdgeInsets.fromLTRB(8.0,2,8,2),
            //       child: IconButton(
            //         icon: Icon(
            //           Icons.clear,
            //           color: sh_white,
            //         ),
            //         onPressed: () {
            //           Provider.of<SearchProvider>(context, listen: false).reverseSearch();
            //           // setState(() {
            //           //   firsttime=false;
            //           //   searchController.clear();
            //           //   productListModel.clear();
            //           //   isEmpty = false;
            //           //   isLoadingMoreData = false;
            //           // });
            //         },
            //       ),
            //     )
            //         : Padding(
            //       padding: const EdgeInsets.fromLTRB(8.0,2,8,2),
            //       child: IconButton(
            //         icon: Icon(
            //           Icons.search,
            //           color: sh_white,
            //         ),
            //         onPressed: () {
            //           Provider.of<SearchProvider>(context, listen: false).reverseSearch();
            //           // setState(() {
            //           //   firsttime=false;
            //           //   searchController.clear();
            //           //   productListModel.clear();
            //           //   isEmpty = false;
            //           //   isLoadingMoreData = false;
            //           // });
            //         },
            //       ),
            //     )
            //   ],
            // );
          })),

        ),

        Container(
          height: height,
          // width: width,
          // color: sh_white,
          margin: EdgeInsets.fromLTRB(0, app_height + 40, 0, 0),
          child: SingleChildScrollView(
            // physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: width,
                  color: Colors.transparent,
                  margin: EdgeInsets.fromLTRB(26, 0, 26, 0),
                  child: TextFormField(
                    controller: searchController,
// enabled: value.isSearch,
                    autofocus:true,
                    focusNode: node,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (value) async {
                      if (value.length > 1) {
                        setState(() {
                          shopcontroller.text='';
                          colorcontroller.text='';
                          _selectsize=null;
                        });
                        Provider.of<SearchProvider>(context, listen: false).fetchSearch(searchController.text,"Newest to Oldest",'','',null,null);
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
                      suffixIcon: InkWell(
                        onTap: () {
                          if (searchController.text.length > 1) {
                            setState(() {
                              shopcontroller.text='';
                              colorcontroller.text='';
                              _selectsize=null;
                            });
                            Provider.of<SearchProvider>(context, listen: false).fetchSearch(searchController.text,"Newest to Oldest",'','',null,null);
                          } else {
                            toast("Please enter more character");
                          }
                        },
                        child: Icon(
                          Icons.search,
                          color: sh_colorPrimary2,
                        ),
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
                  child:
                  Column(
                    children: [
                      Consumer<SearchProvider>(builder: ((context, value, child) {
                        return Visibility(
                          visible: value.isVisible,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomPopupMenu(
                                child: Wrap(
                                  children: [
                                    Row(
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
                                          style: TextStyle(
                                              color: sh_colorPrimary2, fontSize: 11.sp,fontFamily: 'Medium'),
                                        )
                                      ],
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
                                              // print("onTap");
                                              // toast(item.title);
                                              _controller.hideMenu();
                                              toast("Please wait..");
                                              value.fetchSearch(searchController.text,item.title,shopcontroller.text,colorcontroller.text,_selectsize,_selectcondition);

                                              // setState(() {
                                              //   toast("Please wait..");
                                              //   postMdl.filter_str = item.title;
                                              // });
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

                              InkWell(
                                onTap: () {
                                  refineSheet(context);
                                },
                                child: Row(children: [
                                  Icon(Icons.filter_list_alt,color: sh_colorPrimary2,size: 20,),
                                  Text(" Filter",style: TextStyle(fontSize: 11.sp,color: sh_colorPrimary2,fontFamily: 'Medium'),)
                                ],),
                              )
                            ],
                          ),
                        );
                      })),

                      SizedBox(
                        height: 10,
                      ),
                      Consumer<SearchProvider>(builder: ((context, value, child) {
                        return value.isFirst ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 80,
                            ),
                            text("", fontFamily: fontMedium,
                                fontSize: textSizeMedium)
                          ],
                        ) : searchList(value.productListModel);
                      })),
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

    return Sizer(
        builder: (context, orientation, deviceType) {
       return Scaffold(
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
       );
    });
  }
}
InputDecoration inputDecoration(BuildContext context, {String? hint,labeltext,suffix,priffix}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(vertical: 18),
    focusedBorder:  UnderlineInputBorder(
      borderSide: BorderSide(color: sh_colorPrimary2,width: 0.4),
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: sh_colorPrimary2,width: 0.4),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: sh_colorPrimary2,width: 0.4),
    ),
    hintText: hint,
    hintStyle:  TextStyle(color:sh_colorPrimary2,fontSize: 14),
    labelText: labeltext,
    labelStyle: TextStyle(color:sh_colorPrimary2,fontSize: 14),
    suffixIcon: suffix,
    prefixIcon: priffix,
  );
}