
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';

callNext(var className, var context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => className),
  );
}

back(var context) {
  Navigator.pop(context);
}

// class SizeConfig {
//   static MediaQueryData _mediaQueryData;
//   static double screenWidth;
//   static double screenHeight;
//   static double defaultSize;
//   static Orientation orientation;
//
//   void init(BuildContext context) {
//     _mediaQueryData = MediaQuery.of(context);
//     screenWidth = _mediaQueryData.size.width;
//     screenHeight = _mediaQueryData.size.height;
//     orientation = _mediaQueryData.orientation;
//   }
// }

// double getProportionateScreenWidth(double inputWidth) {
//   double screenWidth = SizeConfig.screenWidth;
//   // 375 is the layout width that designer use
//   return (inputWidth / 375.0) * screenWidth;
// }
//
// double getProportionateScreenHeight(double inputHeight) {
//   double screenHeight = SizeConfig.screenHeight;
//   // 812 is the layout height that designer use
//   return (inputHeight / 812.0) * screenHeight;
// }

Widget text(var text, {var fontSize = textSizeLargeMedium, textColor = sh_app_black, var fontFamily = 'Regular', var isCentered = false, var maxLine = 1, var latterSpacing = 0.5}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: textColor, height: 1.5, letterSpacing: latterSpacing));
}

Widget text10(var text, {var fontSize = textSizeLargeMedium, textColor = sh_app_black, var fontFamily = 'Regular', var isCentered = false, var maxLine = 2, var latterSpacing = 0.5}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: textColor, height: 1.5, letterSpacing: latterSpacing));
}

Widget text4(var text, {var fontSize = textSizeLargeMedium, textColor = sh_app_black, var fontFamily = 'Regular', var isCentered = false, var latterSpacing = 0.5}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: textColor, height: 1.5, letterSpacing: latterSpacing));
}

Widget text7(var text,
    {var fontSize = textSizeMedium,
      textColor = sh_textColorSecondary,
      var fontFamily = fontRegular,
      var isCentered = false,
      var maxLine = 1,
      var latterSpacing = 0.2,
      var isLongText = false,
      var isJustify = false,
      var aDecoration}) {
  return Text(
    text,
    textAlign: isCentered ? TextAlign.center : isJustify ? TextAlign.justify : TextAlign.start,
    maxLines: isLongText ? 20 : maxLine,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
        fontFamily: fontFamily,
        decoration: aDecoration != null ? aDecoration : null,
        fontSize: double.parse(fontSize.toString()).toDouble(),
        height: 1.5,
        color: textColor.toString().isNotEmpty ? textColor : null,
        letterSpacing: latterSpacing),
  );
}

Widget text2(var text, {var fontSize = textSizeLargeMedium, textColor = sh_app_black, var fontFamily = fontRegular, var isCentered = false, var maxLine = 3, var latterSpacing = 0.5}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: textColor, height: 1.5, letterSpacing: latterSpacing));
}

Widget text8(String text,
    {var fontSize = textSizeMedium,
      textColor = sh_textColorPrimary,
      var fontFamily = 'Regular',
      var isCentered = false,
      var maxLine = 1,
      var lineThrough = false,
      var latterSpacing = 0.25,
      var textAllCaps = false,
      var isLongText = false}) {
  return Text(textAllCaps ? text.toUpperCase() : text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: isLongText ? null : maxLine,
      style: TextStyle(
          fontFamily: fontFamily, fontSize: fontSize, decoration: lineThrough ? TextDecoration.lineThrough : TextDecoration.none, color: textColor, height: 1.5, letterSpacing: latterSpacing));
}

BoxDecoration boxDecoration({double radius = spacing_middle, Color color = Colors.transparent, Color bgColor = sh_white, var showShadow = false}) {
  return BoxDecoration(
      color: bgColor,
      boxShadow: showShadow ? [BoxShadow(color: sh_shadow_color, blurRadius: 10, spreadRadius: 2)] : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color),
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

BoxDecoration boxDecoration8({double radius = spacing_middle, Color color = Colors.transparent, Color bgColor = sh_white, var showShadow = false}) {
  return BoxDecoration(
      color: bgColor,
      boxShadow: showShadow ? [BoxShadow(color: sh_shadow_color, blurRadius: 10, spreadRadius: 2)] : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color),
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

BoxDecoration boxDecoration4({double radius = 0, Color color = Colors.transparent, Color bgColor = sh_white, var showShadow = false}) {
  return BoxDecoration(
      color: bgColor,
      boxShadow: showShadow ? [BoxShadow(color: sh_shadow_color, blurRadius: 10, spreadRadius: 2)] : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color),
  );
}

Widget title(var title, BuildContext context) {
  return Stack(
    children: <Widget>[
      Container(color: sh_colorPrimary, height: 70),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.width * 0.15,
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: sh_white,
                      ),
                      onPressed: () {
                        finish(context);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(spacing_standard, 0, 0, 0),
                      child: text(title, textColor: sh_white, fontSize: textSizeNormal, fontFamily: fontBold),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
            decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: sh_semi_white),
          ),
        ],
      )
    ],
  );
}

// class PinEntryTextField extends StatefulWidget {
//   final String lastPin;
//   final int fields;
//   final onSubmit;
//   final fieldWidth;
//   final fontSize;
//   final isTextObscure;
//   final showFieldAsBox;
//
//   PinEntryTextField({this.lastPin, this.fields: 4, this.onSubmit, this.fieldWidth: 40.0, this.fontSize: 16.0, this.isTextObscure: false, this.showFieldAsBox: false}) : assert(fields > 0);
//
//   @override
//   State createState() {
//     return PinEntryTextFieldState();
//   }
// }
//
// class PinEntryTextFieldState extends State<PinEntryTextField> {
//   List<String> _pin;
//   List<FocusNode> _focusNodes;
//   List<TextEditingController> _textControllers;
//
//   Widget textfields = Container();
//
//   @override
//   void initState() {
//     super.initState();
//     _pin = List<String>(widget.fields);
//     _focusNodes = List<FocusNode>(widget.fields);
//     _textControllers = List<TextEditingController>(widget.fields);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         if (widget.lastPin != null) {
//           for (var i = 0; i < widget.lastPin.length; i++) {
//             _pin[i] = widget.lastPin[i];
//           }
//         }
//         textfields = generateTextFields(context);
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _textControllers.forEach((TextEditingController t) => t.dispose());
//     super.dispose();
//   }
//
//   Widget generateTextFields(BuildContext context) {
//     List<Widget> textFields = List.generate(widget.fields, (int i) {
//       return buildTextField(i, context);
//     });
//
//     if (_pin.first != null) {
//       FocusScope.of(context).requestFocus(_focusNodes[0]);
//     }
//
//     return Row(mainAxisAlignment: MainAxisAlignment.center, verticalDirection: VerticalDirection.down, children: textFields);
//   }
//
//   void clearTextFields() {
//     _textControllers.forEach((TextEditingController tEditController) => tEditController.clear());
//     _pin.clear();
//   }
//
//   Widget buildTextField(int i, BuildContext context) {
//     if (_focusNodes[i] == null) {
//       _focusNodes[i] = FocusNode();
//     }
//     if (_textControllers[i] == null) {
//       _textControllers[i] = TextEditingController();
//       if (widget.lastPin != null) {
//         _textControllers[i].text = widget.lastPin[i];
//       }
//     }
//
//     _focusNodes[i].addListener(() {
//       if (_focusNodes[i].hasFocus) {}
//     });
//
//     final String lastDigit = _textControllers[i].text;
//
//     return Container(
//       width: widget.fieldWidth,
//       margin: EdgeInsets.only(right: 10.0),
//       child: TextField(
//         controller: _textControllers[i],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         maxLength: 1,
//         style: TextStyle(color: Colors.black, fontFamily: fontMedium, fontSize: widget.fontSize),
//         focusNode: _focusNodes[i],
//         obscureText: widget.isTextObscure,
//         decoration: InputDecoration(focusColor: sh_colorPrimary, counterText: "", border: widget.showFieldAsBox ? OutlineInputBorder(borderSide: BorderSide(width: 2.0)) : null),
//         onChanged: (String str) {
//           setState(() {
//             _pin[i] = str;
//           });
//           if (i + 1 != widget.fields) {
//             _focusNodes[i].unfocus();
//             if (lastDigit != null && _pin[i] == '') {
//               FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
//             } else {
//               FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
//             }
//           } else {
//             _focusNodes[i].unfocus();
//             if (lastDigit != null && _pin[i] == '') {
//               FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
//             }
//           }
//           if (_pin.every((String digit) => digit != null && digit != '')) {
//             widget.onSubmit(_pin.join());
//           }
//         },
//         onSubmitted: (String str) {
//           if (_pin.every((String digit) => digit != null && digit != '')) {
//             widget.onSubmit(_pin.join());
//           }
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return textfields;
//   }
// }


void finish(context) {
  Navigator.pop(context);
}

void hideKeyboard(context) {
  FocusScope.of(context).requestFocus(FocusNode());
}


launchScreen(context, String tag, {Object? arguments}) {
  if (arguments == null) {
    Navigator.pushNamed(context, tag);
  } else {
    Navigator.pushNamed(context, tag, arguments: arguments);
  }
}

void launchScreenWithNewTask(context, String tag) {
  Navigator.pushNamedAndRemoveUntil(context, tag, (r) => false);
}

Color hexStringToHexInt(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff' + hex : hex;
  int val = int.parse(hex, radix: 16);
  return Color(val);
}

/*
String parseHtmlString(String htmlString) {
  return parse(parse(htmlString).body.text).documentElement.text;
}*/
Future<String> loadContentAsset(String path) async {
  return await rootBundle.loadString(path);
}



Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}
class AppTheme {
  const AppTheme();
  static ThemeData lightTheme = ThemeData(
      backgroundColor: background,
      primaryColor: background,
      cardTheme: CardTheme(color: background),
      textTheme: TextTheme(headline1: TextStyle(color: black)),
      iconTheme: IconThemeData(color: iconColor),
      bottomAppBarColor: background,
      dividerColor: lightGrey,
      primaryTextTheme: TextTheme(
          bodyText1: TextStyle(color:sh_app_black)
      )
  );

  static TextStyle titleStyle = const TextStyle(color: sh_app_black, fontSize: 16);
  static TextStyle subTitleStyle = const TextStyle(color: sh_textColorSecondary, fontSize: 12);

  static TextStyle h1Style = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static TextStyle h2Style = const TextStyle(fontSize: 22);
  static TextStyle h3Style = const TextStyle(fontSize: 20);
  static TextStyle h4Style = const TextStyle(fontSize: 18);
  static TextStyle h5Style = const TextStyle(fontSize: 16);
  static TextStyle h6Style = const TextStyle(fontSize: 14);

  static List<BoxShadow> shadow =  <BoxShadow>[
    BoxShadow(color: Color(0xfff8f8f8), blurRadius: 10, spreadRadius: 15),
  ];


  static EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static EdgeInsets hPadding = const EdgeInsets.symmetric(horizontal: 10,);

  static double fullWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }
  static double fullHeight(BuildContext context){
    return MediaQuery.of(context).size.height;
  }
}

// class TitleText extends StatelessWidget {
//   final String text;
//   final double fontSize;
//   final Color color;
//   final FontWeight fontWeight;
//   const TitleText(
//       {Key key,
//         this.text,
//         this.fontSize = 18,
//         this.color = titleTextColor,
//         this.fontWeight = FontWeight.w800
//       })
//       : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Text(text,
//         style: TextStyle(
//           fontFamily: 'ExtraBold',
//             fontSize: fontSize, fontWeight: fontWeight, color: color));
//   }
// }
//
// class TitleText2 extends StatelessWidget {
//   final String text;
//   final double fontSize;
//   final Color color;
//   final FontWeight fontWeight;
//   const TitleText2(
//       {Key key,
//         this.text,
//         this.fontSize = 16,
//         this.color = titleTextColor,
//         this.fontWeight = FontWeight.w800
//       })
//       : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Text(text,
//         style: TextStyle(
//             fontFamily: 'Bold',
//             fontSize: fontSize, fontWeight: fontWeight, color: color));
//   }
// }

