import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thrift/fragments/HomeFragment.dart';
import 'package:thrift/screens/DashboardScreen.dart';
import 'package:thrift/utils/ShConstant.dart';

class T3Dialog extends StatefulWidget {
  static var tag = "/T3Dialog";

  @override
  T3DialogState createState() => T3DialogState();
}

class T3DialogState extends State<T3Dialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(),
      );
    });
    return HomeFragment();
  }
}

class CustomDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}

dialogContent(BuildContext context) {
  return Container(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          ClipRRect(
            child: Image.asset(
              t3_ic_pizza_dialog,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(padding: EdgeInsets.all(16), alignment: Alignment.centerRight, child: Icon(Icons.close, color: Colors.white)),
              ),
//              Container(
//                alignment: Alignment.bottomCenter,
//                  child: text("This offer is valid till 30th november",textColor: t3_white))
            ],
          ),
        ],
      ));
}
