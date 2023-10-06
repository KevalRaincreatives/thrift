import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrift/screens/LoginScreen.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/network_status_service.dart';
import 'package:thrift/utils/NetworkAwareWidget.dart';
import 'package:provider/provider.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/ShExtension.dart';

class EmailExistVerifyScreen extends StatefulWidget {
  static String tag = '/EmailExistVerifyScreen';
  const EmailExistVerifyScreen({Key? key}) : super(key: key);

  @override
  State<EmailExistVerifyScreen> createState() => _EmailExistVerifyScreenState();
}

class _EmailExistVerifyScreenState extends State<EmailExistVerifyScreen> {
  bool isEmailVerified= false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified=FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isEmailVerified){
      sendVerificationEmail();

      timer =Timer.periodic(const Duration(seconds: 3), (timer) {
        checkEmailVerified();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified()  async{

    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified=FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if(isEmailVerified) timer?.cancel();

  }

  Future sendVerificationEmail()  async{
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    }catch(e){
      print(e.toString());
      toast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return isEmailVerified? const LoginScreen():
    Scaffold(
      backgroundColor: Colors.white,
      body: StreamProvider<NetworkStatus>(
        initialData: NetworkStatus.Online,
        create: (context) =>
        NetworkStatusService().networkStatusController.stream,
        child: NetworkAwareWidget(
          onlineChild: Stack(
            children: [
              SizedBox(
                  height: 200,
                  width: width,
                  child: Image.asset(sh_upper,fit: BoxFit.fill)
                // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
              ),
              SizedBox(
                height: height,
                width: width,
                child: Column(
                  children: [
                    const SizedBox(height: 36,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: IconButton(onPressed: () {
                            Navigator.pop(context);
                          }, icon: const Icon(Icons.keyboard_arrow_left,color: Colors.white,size: 36,)),
                        ),

                        const Center(child: Text("Verify Email",style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'TitleCursive',fontWeight: FontWeight.normal),))
                      ],
                    ),
                    const SizedBox(height: 50,),
                    Center(
                      child: SizedBox(
                        width: width*.7,
                        height: height*.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            const Text("This email is already registered with us. Please verify your email to proceed.\n\nA Verification email has been sent to your email.",style: TextStyle(color: sh_textColorPrimary,fontSize: 18),textAlign: TextAlign.center,),
                            const SizedBox(height: 50,),
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                                onPressed: sendVerificationEmail, icon: const Icon(Icons.email,size: 32,color: sh_white,), label: const Text('Resend Email',style: TextStyle(color: sh_white,fontSize: 24)))

                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              )
            ],
          ),
          offlineChild: Center(
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

    );
  }
}
