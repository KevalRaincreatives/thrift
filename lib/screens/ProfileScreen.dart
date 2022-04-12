import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:thrift/model/ProfileUpdateModel.dart';
import 'package:thrift/model/ViewProModel.dart';
import 'package:thrift/screens/BecameSellerScreen.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/ChangePasswordScreen.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/screens/NewNumberScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart';
import 'package:image_picker/image_picker.dart';
class ProfileScreen extends StatefulWidget {
  static String tag='/ProfileScreen';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var firstNameCont = TextEditingController();
  var lastNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var phoneCont= TextEditingController();
  ProfileModel? profileModel;
  ProfileUpdateModel? profileUpdateModel;
  final _formKey = GlobalKey<FormState>();
  String? is_store_owner;
  XFile? _image;
  String fnl_img = 'https://secure.gravatar.com/avatar/598b1f668254d0f7097133846aa32daf?s=96&d=mm&r=g';
  final picker = ImagePicker();
  ViewProModel? viewProModel;


  @override
  void initState() {
    super.initState();
    fetchDetails();

  }

  getLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', "");

    Route route = MaterialPageRoute(
        builder: (context) => LoginScreen());
    Navigator.pushReplacement(context, route);


  }

  Future<ProfileModel?> fetchDetails() async {
//    Dialogs.showLoadingDialog(context, _keyLoader);
    EasyLoading.show(status: 'Please wait...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');


      print('Token : ${token}');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Response response = await get(
      //   'https://encros.rcstaging.co.in/wp-json/wooapp/v3/profile',
      //   headers: headers
      // );

      var response =await http.get(Uri.parse("https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/profile"),
          headers: headers);


      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      EasyLoading.dismiss();

      profileModel = new ProfileModel.fromJson(jsonResponse);
      // if (new_car == 0) {
      firstNameCont.text = profileModel!.data!.firstName!;
      lastNameCont.text = profileModel!.data!.lastName!;
      emailCont.text = profileModel!.data!.userEmail!;
      phoneCont.text ="+"+
          profileModel!.data!.phoneCode! + profileModel!.data!.phone!;
      prefs.setString('pro_first', profileModel!.data!.firstName!);
      prefs.setString('pro_last', profileModel!.data!.lastName!);
      prefs.setString('pro_email', profileModel!.data!.userEmail!);

      //   addressCont2.text = profileModel.shipping.address2;
      //   cityCont.text = profileModel.shipping.city;
      //   pinCodeCont.text = profileModel.shipping.postcode;
      //   stateCont.text = profileModel.shipping.state;
      //   countryCont.text = profileModel.shipping.country;
      //   parishCont.text = profileModel.shipping.state;
      //
      //   countryname = profileModel.shipping.country;
      //   statename = profileModel.shipping.state;
      // }

      print('sucess');

      return profileModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<ProfileUpdateModel?> getUpdate() async {
    EasyLoading.show(status: 'Please wait...');
    try {

      String email = emailCont.text;
      String firstname = firstNameCont.text;
      String lastname = lastNameCont.text;
      String phone = profileModel!.data!.phone.toString();
      String country_code = profileModel!.data!.phoneCode.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({
        "user_email": email,
        "display_name":email,
        "user_url":"",
        "first_name": firstname,
        "last_name": lastname,
        "phone": phone,
        "phone_code":country_code
      });


      // String body = json.encode(data2);

      http.Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/edit_profile'),
          headers: headers,
          body: msg);
      EasyLoading.dismiss();

//
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      profileUpdateModel = new ProfileUpdateModel.fromJson(jsonResponse);
      toast(profileUpdateModel!.msg);

      // prefs.setString('login_name', firstname);

      return profileUpdateModel;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<String?> BecameSeller() async {
    EasyLoading.show(status: 'Please wait...');
    try {

      // String email = emailCont.text;
      // String firstname = firstNameCont.text;
      // String lastname = lastNameCont.text;
      // String phone = profileModel!.data!.phone.toString();
      // String country_code = profileModel!.data!.phoneCode.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final msg = jsonEncode({
        "shop_name": "Happy",
        "billing_first_name":"keval2",
        "billing_last_name":"Panchal2",
        "billing_email": "keval@gmail.com",
        "billing_phone": "7878392120",
        "billing_address_1": "Hill Colony",
        "billing_city":"Surat",
        "billing_state":"Gujarat",
        "billing_postcode":"393430",
        "billing_country":"India",
        "shipping_first_name":"keval2",
        "shipping_last_name":"Panchal2",
        "shipping_email": "keval@gmail.com",
        "shipping_phone": "7878392120",
        "shipping_address_1": "Hill Colony",
        "shipping_city":"Surat",
        "shipping_state":"Gujarat",
        "shipping_postcode":"393430",
        "shipping_country":"India",
      });

      // String body = json.encode(data2);

      http.Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/wooapp/v3/become_a_seller'),
          headers: headers,
          body: msg);
      EasyLoading.dismiss();

//
      final jsonResponse = json.decode(response.body);
      print('not json2 $jsonResponse');
      // profileUpdateModel = new ProfileUpdateModel.fromJson(jsonResponse);


      // prefs.setString('login_name', firstname);

      return null;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future<String?> fetchadd() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      is_store_owner = prefs.getString('is_store_owner');
      return is_store_owner;
    } catch (e) {
      print('caught error $e');
    }
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _imgFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = image;

      UploadPic();
    });
  }

  _imgFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      _image = image;


      UploadPic();
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Future<String?> UploadPic() async {
    EasyLoading.show(status: 'Uploading...');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      File fls = File(_image!.path);
      // String fileName = _image.toString().split('/').last;
      // print(fileName);
      // String img = _image!.path.toString().substring(0, _image!.path
      //     .toString()
      //     .length - 1);
      String fileName = _image!.path
          .toString()
          .split('/')
          .last;
      print(fileName);
      Uint8List bytes = fls.readAsBytesSync();
      String base64Image = base64Encode(bytes);

      final msg = jsonEncode({
        "customer_id": UserId,
        "name": fileName,
        "profile_picture": base64Image,
      });
      print(fileName);


      Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/v3/update_profile_picture'),
          headers: headers,
          body: msg);
      print('Response body: ${response.body}');
      EasyLoading.dismiss();
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');

      toast('Uploaded');
      // order_det_model = new OrderDetailModel.fromJson(jsonResponse);
      return null;
    } catch (e) {
      EasyLoading.dismiss();
      print('caught error $e');
    }
  }


  Future<ViewProModel?> ViewProfilePic() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };


      final msg = jsonEncode({
        "customer_id": UserId,
      });
      print(msg);

      Response response = await post(
          Uri.parse('https://thriftapp.rcstaging.co.in/wp-json/v3/view_profile_picture'),
          headers: headers,
          body: msg);
      print('Response body: ${response.body}');
      final jsonResponse = json.decode(response.body);
      print('not json $jsonResponse');
      viewProModel = new ViewProModel.fromJson(jsonResponse);

      fnl_img = viewProModel!.profile_picture!;



      return viewProModel;
    } catch (e) {
      // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print('caught error $e');
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


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final node = FocusScope.of(context);

    ValidSeller() {
      return InkWell(
        onTap: () async {
          // BecameSeller();
          launchScreen(context, BecameSellerScreen.tag);
        },
        child: Container(
          width: MediaQuery.of(context).size.width*.7,
          padding: EdgeInsets.only(
              top: 6, bottom: 10),
          decoration: boxDecoration(
              bgColor: sh_btn_color, radius: 10, showShadow: true),
          child: text("Became a Seller",
              fontSize: 16.0,
              textColor: sh_colorPrimary2,
              isCentered: true,
              fontFamily: 'Bold'),
        ),
      );
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
      }else{
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

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "My Account",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          GestureDetector(
            onTap: () async{
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
            child: Image.asset(sh_upper2,fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Container(
          height: height,
          width: width,
          color: sh_white,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          child:  Container(
            height: height,
            width: width,
            color: sh_white,
            child: SingleChildScrollView(
              child: Column(
                children: [

                  Form(
                    key: _formKey,
                    child: Container(
                      width: width*.7,
                      child: Column(
                        children: [
                          Center(
                            child: FutureBuilder<ViewProModel?>(
                              future: ViewProfilePic(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Stack(
                                    alignment: Alignment.bottomRight,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(spacing_standard_new),
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
                                              _showPicker(context);
                                            },
                                            child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: _image == null
                                                    ? CircleAvatar(
                                                  // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
                                                  backgroundImage: NetworkImage(
                                                      fnl_img),
                                                  radius: 55,
                                                )
                                                    : CircleAvatar(
                                                  // backgroundImage: NetworkImage('https://en.gravatar.com/avatar/491302567ea4eb1e519b54990b8da162'),
                                                  backgroundImage: FileImage(File(_image!.path)),
                                                  radius: 55,
                                                )),
                                          ),
                                        ),
                                      ),


                                      Container(
                                        padding: EdgeInsets.all(spacing_control),
                                        margin: EdgeInsets.only(bottom: 30, right: 20),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: sh_white,
                                            border: Border.all(color: sh_colorPrimary,
                                                width: 1)),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: sh_colorPrimary,
                                          size: 16,
                                        ),
                                      )
                                    ],
                                  );
                                }
                                return Padding(
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
                                          backgroundImage: NetworkImage(
                                              fnl_img),
                                          radius: 55,
                                        )),
                                  ),
                                );
                              },
                            ),

                          ),

                          TextFormField(
                            onEditingComplete: () =>
                                node.nextFocus(),
                            controller: firstNameCont,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Please Enter First name';
                              }
                              return null;
                            },
                            cursorColor: sh_colorPrimary2,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                              hintText: "First name",
                              hintStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                              labelText: "First name",
                              labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Bold'),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
                              ),
                            ),
                            maxLines: 1,
                            style: TextStyle(color: sh_black,fontFamily: 'Bold'),
                          ),
                          SizedBox(height: 16,),
                          TextFormField(
                            onEditingComplete: () =>
                                node.nextFocus(),
                            controller: lastNameCont,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Please Enter Last name';
                              }
                              return null;
                            },
                            cursorColor: sh_colorPrimary2,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                              hintText: "Last name",
                              hintStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                              labelText: "Last name",
                              labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Bold'),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
                              ),
                            ),
                            maxLines: 1,
                            style: TextStyle(color: sh_black,fontFamily: 'Bold'),
                          ),
                          SizedBox(height: 16,),
                          TextFormField(
                            onEditingComplete: () =>
                                node.nextFocus(),
                            controller: emailCont,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Please Enter Email';
                              }
                              return null;
                            },
                            cursorColor: sh_app_txt_color,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                              hintText: "Email",
                              hintStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                              labelText: "Email",
                              labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Bold'),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
                              ),
                            ),
                            maxLines: 1,
                            style: TextStyle(color: sh_black,fontFamily: 'Bold'),
                          ),
                          SizedBox(height: 16,),
                          Stack(
                            children: [TextFormField(
                              readOnly: true,
                              onEditingComplete: () =>
                                  node.nextFocus(),
                              controller: phoneCont,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Please Enter Number';
                                }
                                return null;
                              },
                              cursorColor: sh_colorPrimary2,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(2, 8, 4, 8),
                                hintText: "Mobile Number",
                                hintStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Regular'),
                                labelText: "Mobile Number",
                                labelStyle: TextStyle(color: sh_colorPrimary2,fontFamily: 'Bold'),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: sh_colorPrimary2, width: 1.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:  BorderSide(color: sh_colorPrimary2, width: 1.0),
                                ),
                              ),
                              maxLines: 1,
                              style: TextStyle(color: sh_black,fontFamily: 'Bold'),
                            ),
                              Positioned.fill(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () async{
                                        launchScreen(context, NewNumberScreen.tag);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 1, 1, 0),
                                        child: Center(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "Change",
                                              style: TextStyle(
                                                  color: sh_app_blue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Regular'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 36,),
                          InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                // TODO submit
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                getUpdate();

                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width*.7,
                              padding: EdgeInsets.only(
                                  top: 6, bottom: 10),
                              decoration: boxDecoration(
                                  bgColor: sh_btn_color, radius: 10, showShadow: true),
                              child: text("Update",
                                  fontSize: 16.0,
                                  textColor: sh_colorPrimary2,
                                  isCentered: true,
                                  fontFamily: 'Bold'),
                            ),
                          ),
                          SizedBox(height: 16,),
                          InkWell(
                            onTap: () async {
                              launchScreen(context, ChangePasswordScreen.tag);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width*.7,
                              padding: EdgeInsets.only(
                                  top: 6, bottom: 10),
                              decoration: boxDecoration(
                                  bgColor: sh_btn_color, radius: 10, showShadow: true),
                              child: text("Change Password",
                                  fontSize: 16.0,
                                  textColor: sh_colorPrimary2,
                                  isCentered: true,
                                  fontFamily: 'Bold'),
                            ),
                          ),
                          SizedBox(height: 16,),
                          FutureBuilder<String?>(
                            future: fetchadd(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {

                                return is_store_owner=='0' ? InkWell(
                                  onTap: () async {
                                    // BecameSeller();
                                    launchScreen(context, BecameSellerScreen.tag);
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width*.7,
                                    padding: EdgeInsets.only(
                                        top: 6, bottom: 10),
                                    decoration: boxDecoration(
                                        bgColor: sh_btn_color, radius: 10, showShadow: true),
                                    child: text("Became a Seller",
                                        fontSize: 16.0,
                                        textColor: sh_colorPrimary2,
                                        isCentered: true,
                                        fontFamily: 'Bold'),
                                  ),
                                ) : Container();
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }
                              // By default, show a loading spinner.
                              return CircularProgressIndicator();
                            },
                          ),
                          // InkWell(
                          //   onTap: () async {
                          //     // BecameSeller();
                          //     launchScreen(context, BecameSellerScreen.tag);
                          //   },
                          //   child: Container(
                          //     width: MediaQuery.of(context).size.width*.7,
                          //     padding: EdgeInsets.only(
                          //         top: 6, bottom: 10),
                          //     decoration: boxDecoration(
                          //         bgColor: sh_btn_color, radius: 10, showShadow: true),
                          //     child: text("Became a Seller",
                          //         fontSize: 16.0,
                          //         textColor: sh_colorPrimary2,
                          //         isCentered: true,
                          //         fontFamily: 'Bold'),
                          //   ),
                          // ),
                        ],
                      ),

                    ),
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
            padding: const EdgeInsets.fromLTRB(0,spacing_middle4,0,0),
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
                      child: Text("My Account",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Cursive'),),
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
      body: SafeArea(child: setUserForm()),
    );
  }
}
