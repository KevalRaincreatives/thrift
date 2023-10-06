import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'ShColors.dart';


 errorDialogue(BuildContext context,error){
    return Alert(
      context: context,
      type: AlertType.warning,
      title: "Reload",
      desc: error,
      buttons: [
        DialogButton(
          child: const Text(
            "Reload",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            Navigator.pop(context,'1');
          },
          color: sh_colorPrimary2,
        ),
      ],
    ).show();
  }
