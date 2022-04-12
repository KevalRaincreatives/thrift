import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/screens/OrderSuccessScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';

class PaymentScreen extends StatefulWidget {
  static String tag='/PaymentScreen';
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: sh_colorPrimary2,
        width: 2.0,
      ),
    );
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    Widget setUserForm() {
      AppBar appBar = AppBar(
        elevation: 0,
        backgroundColor: sh_colorPrimary2,
        title: Text(
          "Pay",
          style:
          TextStyle(color: sh_white, fontFamily: 'Cursive', fontSize: 40),
        ),
        iconTheme: IconThemeData(color: sh_white),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
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
            child: Image.asset(sh_upper2, fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        //Above card

        Container(
          height: height,
          width: width,
          color: sh_white,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  CreditCardWidget(
                    cardBgColor: sh_colorPrimary2,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    showBackView: isCvvFocused,
                    obscureCardNumber: true,
                    obscureCardCvv: true, onCreditCardWidgetChange: (CreditCardBrand ) {  },
                  ),
                  Column(
                    children: [
                    CreditCardForm(
                    formKey: formKey,
                    obscureCvv: true,
                    obscureNumber: true,
                    cardNumber: cardNumber,
                    cvvCode: cvvCode,
                    isHolderNameVisible: true,
                    isCardNumberVisible: true,
                    isExpiryDateVisible: true,
                    cardHolderName: cardHolderName,
                    expiryDate: expiryDate,
                    themeColor: sh_colorPrimary2,
                    textColor: sh_colorPrimary2,
                    cardNumberDecoration: InputDecoration(
                      labelText: 'Number',
                      hintText: 'XXXX XXXX XXXX XXXX',
                      hintStyle: const TextStyle(color: sh_colorPrimary2),
                      labelStyle: const TextStyle(color: sh_colorPrimary2),
                      focusedBorder: border,
                      enabledBorder: border,
                    ),
                    expiryDateDecoration: InputDecoration(
                      hintStyle: const TextStyle(color: sh_colorPrimary2),
                      labelStyle: const TextStyle(color: sh_colorPrimary2),
                      focusedBorder: border,
                      enabledBorder: border,
                      labelText: 'Expired Date',
                      hintText: 'XX/XX',
                    ),
                    cvvCodeDecoration: InputDecoration(
                      hintStyle: const TextStyle(color: sh_colorPrimary2),
                      labelStyle: const TextStyle(color: sh_colorPrimary2),
                      focusedBorder: border,
                      enabledBorder: border,
                      labelText: 'CVV',
                      hintText: 'XXX',
                    ),
                    cardHolderDecoration: InputDecoration(
                      hintStyle: const TextStyle(color: sh_colorPrimary2),
                      labelStyle: const TextStyle(color: sh_colorPrimary2),
                      focusedBorder: border,
                      enabledBorder: border,
                      labelText: 'Card Holder',
                    ),
                    onCreditCardModelChange: onCreditCardModelChange,
                  ),
                      SizedBox(height: 20,),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: const Text(
                            'Validate',
                            style: TextStyle(
                              color: sh_colorPrimary2,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        color: sh_btn_color,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            print('valid!');
                            _showValidDialog(context,"Valid","Your card successfully valid !!!");
launchScreen(context, OrderSuccessScreen.tag);
                          } else {
                            print('invalid!');
                          }
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 300,)
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
          child: appBar,
        ),
      ]);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: setUserForm(),
      ),
    );
  }
  Future <AlertDialog>? _showValidDialog(BuildContext context, String title, String content,) {
    showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xff1b447b),
          title: Text(title),
          content: Text(content),
          actions: [
            FlatButton(
                child: Text(
                  "Ok",
                  style: TextStyle(fontSize: 18,color: Colors.cyan),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
