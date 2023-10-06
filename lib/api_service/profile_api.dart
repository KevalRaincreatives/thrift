import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/api_service/Url.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:thrift/model/ViewProModel.dart';

import '../model/ProductListSellerModel.dart';
import '../model/ReviewModel.dart';

class ProfileApiService {
  ProfileModel? profileModel;

  Future<ProfileModel?> fetchProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? UserId = prefs.getString('UserId');
      String? token = prefs.getString('token');

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(
          Uri.parse("${Url.BASE_URL}wp-json/wooapp/v3/profile"),
          headers: headers);

      final jsonResponse = json.decode(response.body);
      print(
          'SellerEditProfileScreen profile Response status2: ${response.statusCode}');
      print('SellerEditProfileScreen profile Response body2: ${response.body}');

      profileModel = new ProfileModel.fromJson(jsonResponse);

      prefs.setString("seller_name",
          profileModel!.data!.firstName! + " " + profileModel!.data!.lastName!);

      return profileModel;
    } on Exception catch (e) {
      print('caught error $e');
    }
  }

  ViewProModel? viewProModel;

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
          Uri.parse('${Url.BASE_URL}wp-json/v3/view_profile_picture'),
          headers: headers,
          body: msg);
      print(
          'SellerEditProfileScreen view_profile_picture Response status2: ${response.statusCode}');
      print(
          'SellerEditProfileScreen view_profile_picture Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);

      viewProModel = new ViewProModel.fromJson(jsonResponse);

      return viewProModel;
    } on Exception catch (e) {
      print('caught error $e');
    }
  }

  ReviewModel? reviewModel;
  Future<ReviewModel?> fetchReview() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cat_id = prefs.getString('cat_id');
      String? seller_id = prefs.getString('UserId');
      // toast(cat_id);
      print("${Url.BASE_URL}wp-json/wooapp/v3/seller_reviews?seller_id=$seller_id");
      var response;
      response = await http.get(Uri.parse(
          "${Url.BASE_URL}wp-json/wooapp/v3/seller_reviews?seller_id=$seller_id"));
      print('SellerEditProfileScreen seller_reviews Response status2: ${response.statusCode}');
      print('SellerEditProfileScreen seller_reviews Response body2: ${response.body}');
      final jsonResponse = json.decode(response.body);
      reviewModel = new ReviewModel.fromJson(jsonResponse);


      return reviewModel;
    } on Exception catch (e) {

      print('caught error $e');
    }
  }




}
