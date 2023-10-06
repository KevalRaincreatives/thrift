import 'package:flutter/material.dart';
import 'package:thrift/model/ProfileModel.dart';
import 'package:thrift/model/ViewProModel.dart';

import '../api_service/profile_api.dart';
import '../model/ReviewModel.dart';

class ProfileProvider with ChangeNotifier{
  ProfileModel? profileModel;

  bool _loader_profile = true;

  bool get loader_profile => _loader_profile;

  getProfile() async{
    profileModel=await ProfileApiService().fetchProfile();
    _loader_profile=false;
    notifyListeners();
  }


  ViewProModel? viewProModel;

  bool _loader_profile_pic = true;

  bool get loader_profile_pic => _loader_profile_pic;
  String fnl_img = 'https://secure.gravatar.com/avatar/598b1f668254d0f7097133846aa32daf?s=96&d=mm&r=g';
  getProfilePic() async{
    viewProModel=await ProfileApiService().ViewProfilePic();
    _loader_profile_pic=false;
    fnl_img = viewProModel!.profilePicture!;
    print(fnl_img);
    notifyListeners();
  }

  ReviewModel? reviewModel;

  bool _loader_review = true;

  bool get loader_review => _loader_review;
  getReview() async{
    reviewModel=await ProfileApiService().fetchReview();
    _loader_review=false;
    notifyListeners();
  }




}