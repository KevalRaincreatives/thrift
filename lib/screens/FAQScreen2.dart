import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:thrift/screens/CartScreen.dart';
import 'package:thrift/utils/ShColors.dart';
import 'package:thrift/utils/ShConstant.dart';
import 'package:thrift/utils/ShExtension.dart';
import 'package:badges/badges.dart';

class FAQScreen extends StatefulWidget {
  static String tag='/FAQScreen';
  const FAQScreen({Key? key}) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {

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
          "FAQ's",
          style: TextStyle(color: sh_white,fontFamily: 'Cursive',fontSize: 40),
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
            child: Image.asset(sh_upper2,fit: BoxFit.fill)
          // SvgPicture.asset(sh_spls_upper2,fit: BoxFit.cover,),
        ),
        Container(
          height: height,
          width: width,
          color: sh_white,
          margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
          child:   Container(
            height: height,
            width: width,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: width*.8,
                    height: height,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("How does Cassie work?",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: 'Bold')),
                          SizedBox(height: 12,),
                          Text("The app allows consignors to sell as many items as they would like on the platform by uploading images of the items and filling form fields with the required information as to allow for maximum transparency for the buyer. ",style: TextStyle(color: sh_black,fontSize: 14,fontFamily: 'SemiBold')),
                          SizedBox(height: 26,),
                          Text("What is the Platform Fee?",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: 'Bold')),
                          SizedBox(height: 12,),
                          Text("\$2.50 USD for all items under \$10 USD and 20% for all items over \$ 10 USD.",style: TextStyle(color: sh_black,fontSize: 14,fontFamily: 'SemiBold')),
                          SizedBox(height: 26,),
                          Text("When does Cassie release the funds to sellers?",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: 'Bold')),
                          SizedBox(height: 12,),
                          Text("Funds will typically be released within 1-5 days of the item delivery, after the buyer has confirmed they have received the item. It is recommended that the buyer checks the item first before hitting “received”.",style: TextStyle(color: sh_black,fontSize: 14,fontFamily: 'SemiBold')),
                          SizedBox(height: 26,),
                          Text("How do I know what items have been ordered?",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: 'Bold')),
                          SizedBox(height: 12,),
                          Text("A sale card will be emailed to you with all the relevant information needed to ship your item. Along with the shipped button to notify the buyer that their item is on their way.",style: TextStyle(color: sh_black,fontSize: 14,fontFamily: 'SemiBold')),
                          SizedBox(height: 26,),
                          Text("How to confirm you have recieved your package(s)?",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: 'Bold')),
                          SizedBox(height: 12,),
                          Text("An email should be sent to you when the items have been shipped or dropped off. Upon receipt/collection of your item hit the “received” button attached to your confirmation email.",style: TextStyle(color: sh_black,fontSize: 14,fontFamily: 'SemiBold')),
                          SizedBox(height: 26,),
                          Text("Does Cassie refund /return?",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: 'Bold')),
                          SizedBox(height: 12,),
                          Text("Items can ONLY be returned if the buyer received an item that was advertised incorrectly (For example, if you advertise adidas shoes and the buyer receives a Nike/Item advertised as new and is clearly used & has faults after being advertised as having none etc).Sellers will incur a charge of \$ 10 USD per returns.It is recommended that you call our customer help desk and file a dispute to be refunded. Be sure to have all of your purchase details ready.",style: TextStyle(color: sh_black,fontSize: 14,fontFamily: 'SemiBold')),
                          SizedBox(height: 26,),
                          Text("How many days does the seller have to ship/drop the items off? ",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: 'Bold')),
                          SizedBox(height: 12,),
                          Text("The seller has up to five (5) days to ship the items. ",style: TextStyle(color: sh_black,fontSize: 14,fontFamily: 'SemiBold')),
                          SizedBox(height: 26,),
                          Text("How long does the buyer have to collect thier item?",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: 'Bold')),
                          SizedBox(height: 12,),
                          Text("The buyer has up to five (5) days to collect and input their collection status. Failing to do so will result in a charge of \$ 5 USD per day to the buyer.",style: TextStyle(color: sh_black,fontSize: 14,fontFamily: 'SemiBold')),
                          SizedBox(height: 26,),
                          Text("Can you pay for your items(s) in cash on Cassie?",style: TextStyle(color: sh_colorPrimary2,fontSize: 16,fontFamily: 'Bold')),
                          SizedBox(height: 12,),
                          Text("Currently the option to pay for your items in cash is available. However, this option is only available in Barbados. Buyers should also note that this option is not going to be available in the long run and is subject to change. ",style: TextStyle(color: sh_black,fontSize: 14,fontFamily: 'SemiBold')),
                          SizedBox(height: 46,),
                        ],
                      ),
                    ),

                  ),
                ),

              ],
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
                      child: Text("FAQ's",style: TextStyle(color: Colors.white,fontSize: 40,fontFamily: 'Cursive'),),
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: setUserForm()),
    );
  }
}
