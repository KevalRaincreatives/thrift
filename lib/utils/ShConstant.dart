/*fonts*/
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thrift/utils/ShColors.dart';

const fontRegular = 'Regular';
const fontMedium = 'Medium';
const fontSemibold = 'Semibold';
const fontBold = 'Bold';
const fontExtraBold = 'ExtraBold';
/* font sizes*/
const textSizeSmall = 12.0;
const textSizeSMedium2 = 13.0;
const textSizeSMedium = 14.0;
const textSizeMedium = 16.0;
const textSizeLargeMedium = 18.0;
const textSizeNormal = 20.0;
const textSizeXNormal = 22.0;
const textSizeLarge = 24.0;
const textSizeXLarge = 30.0;

const Color PRIMARY_COLOR = Color(0xffFBFBFB);
const String myimg="images/new_home.png";
const String myimg_home="images/home.png";
const sh_new_cart="images/new_cart.png";
const sh_no_img="images/no_images.png";
const sh_heart="images/heart.png";
const sh_search="images/new_search.png";
const food_ic_user1 = "images/food_ic_user1.png";

const sh_setting="images/settings5.png";
const sh_setting_dark="images/settings5_dark.png";
const sh_homes="images/home5.png";
const sh_homes_dark="images/home5_dark.png";
const sh_account="images/account5.png";
const sh_account_dark="images/account5_dark.png";
const sh_dollar="images/dollars.png";
const sh_dollar_dark="images/dollar_dark.png";

const sh_upper="images/cassie_landing_bg.png";
const sh_spls_upper2="images/spls_upper2.svg";
const sh_upper2="images/spls_upper.png";
const sh_app_logo="images/app_logo.png";
const sh_splsh2="images/splsh2.png";
const sh_toolbar="images/toolbar.png";

const sh_floating="images/floating.png";

// const sh_menu_filter="images/menu_filter.svg";
const sh_menu_filter="images/menu_filter2.png";

const sh_newmenu='images/newmenu.png';
const sh_add_image="images/add_image.png";
const sh_report_pro="images/problem_report.png";

/* margin */

const spacing_control_half = 2.0;
const spacing_control = 4.0;
const spacing_control_new = 6.0;
const spacing_standard = 8.0;
const spacing_middle = 10.0;
const spacing_middle4 = 12.0;
const spacing_standard_new = 16.0;
const spacing_large = 24.0;
const spacing_xlarge = 32.0;
const spacing_xxLarge = 40.0;

enum ConfirmAction { CANCEL, ACCEPT }

const defaultDuration = Duration(milliseconds: 250);

final otpInputDecoration = InputDecoration(
  contentPadding:
  EdgeInsets.symmetric(vertical: 10),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: sh_textColorSecondary),
  );
}

final kApiUrl = defaultTargetPlatform == TargetPlatform.android
    ? 'http://192.168.1.189:4242'
    : 'http://192.168.1.1:4242';


const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);