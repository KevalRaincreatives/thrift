import 'package:flutter/material.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:thrift/utils/T6Colors.dart';



class T6Button extends StatefulWidget {
  var textContent;
  VoidCallback? onPressed;
  var isStroked = false;

  T6Button({
    @required this.textContent,
    @required this.onPressed,
    this.isStroked = false,
  });

  @override
  T6ButtonState createState() => T6ButtonState();
}

class T6ButtonState extends State<T6Button> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        alignment: Alignment.center,
        child: text(widget.textContent, textColor: widget.isStroked ? t6colorPrimary : t6white, isCentered: true, fontFamily: fontMedium),
        decoration: widget.isStroked ? boxDecoration(bgColor: Colors.transparent, color: t6colorPrimary) : boxDecoration(bgColor: t6colorPrimary, radius: 12),
      ),
    );
  }
}

Container T6EditTextStyle(var hintText, {isPassword = false}) {
  return Container(
    decoration: boxDecoration(radius: 12, showShadow: true, bgColor: t6white),
    child: TextFormField(
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      obscureText: isPassword,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(26, 18, 4, 18),
        hintText: hintText,
        filled: true,
        fillColor: t6white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: t6white, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: t6white, width: 0.0),
        ),
      ),
    ),
  );
}


TextFormField editTextStyle(var hintText, {isPassword = true}) {
  return TextFormField(
    style: TextStyle(fontSize: textSizeLargeMedium, fontFamily: fontRegular),
    obscureText: isPassword,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
      hintText: hintText,
      hintStyle: TextStyle(color: t6textColorSecondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: t6view_color, width: 0.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: t6view_color, width: 0.0),
      ),
    ),
  );
}




Widget shareIcon(String iconPath) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Image.asset(iconPath, width: 28, height: 28, fit: BoxFit.fill),
  );
}

BoxDecoration boxDecoration({double radius = 2, Color color = Colors.transparent, Color bgColor = t6white, var showShadow = false}) {
  return BoxDecoration(
      color: bgColor,
      //gradient: LinearGradient(colors: [bgColor, whiteColor]),
      boxShadow: showShadow ? [BoxShadow(color: t6ShadowColor, blurRadius: 10, spreadRadius: 2)] : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color),
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

Widget ring(String description) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150.0),
          border: Border.all(
            width: 16.0,
            color: t6colorPrimary,
          ),
        ),
      ),
      SizedBox(height: 16),
      text(description, textColor: t6textColorPrimary, fontSize: textSizeNormal, fontFamily: fontSemibold, isCentered: true, maxLine: 2)
    ],
  );
}

class ScrollingBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class Slider extends StatelessWidget {
  final String? file;

  Slider({Key? key, @required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Image.asset(file!, fit: BoxFit.fill),
      ),
    );
  }
}

Padding settingText(
  var text,
) {
  return Padding(
    padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: fontRegular,
        color: t6textColorPrimary,
        fontSize: textSizeMedium,
      ),
    ),
  );
}
