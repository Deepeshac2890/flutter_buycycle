/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Constants.dart';
import 'package:flutter_buycycle/Screens/ChatScreen.dart';
import 'package:flutter_buycycle/Screens/WelcomeScreen.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

/*
For Personal Reference
* Elements Used here :
* InkWell
* GestureDetector
* Builder for Scaffold body
* ImageSlider
*/
String gUrl;
List<String> urlList;
String gPrice;
String gAdTitle;
String gAdInfo;
String gLocation;
String gDate;
String gSeller;

Firestore fs = Firestore.instance;
FirebaseStorage fbs = FirebaseStorage.instance;
FirebaseAuth fa = FirebaseAuth.instance;

class ItemScreen extends StatefulWidget {
  static String id = 'Item_Screen';
  ItemScreen(url, price, adTitle, adInfo, location, date, seller) {
    urlList = url;
    gPrice = price;
    gAdTitle = adTitle;
    gAdInfo = adInfo;
    gLocation = location;
    gDate = date;
    gSeller = seller;
  }
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  Image img = Image.asset('assets/default.png');
  String price = 'N.A';
  String productName = '';
  String desc = '';
  String location = '';
  String date = '';
  String sellers;
  bool loading = true;

  @override
  void initState() {
    initData();
    super.initState();
  }

  // All the data is coming from previous Screen
  void initData() {
    setState(() {
      this.price = gPrice;
      this.productName = gAdTitle;
      this.desc = gAdInfo;
      this.location = gLocation;
      this.date = gDate.toString().substring(0, 10);
      sellers = gSeller;
      loading = false;
    });
  }

  void logout() async {
    await fa.signOut();
    Navigator.popUntil(context, ModalRoute.withName(WelcomeScreen.id));
  }

  Swiper imageSlider(context) {
    return new Swiper(
      autoplay: true,
      loop: false,
      itemBuilder: (BuildContext context, int index) {
        if (urlList.length != 0) {
          return new Image.network(
            urlList[index],
            fit: BoxFit.fitHeight,
          );
        } else {
          return new Image.asset('default.png');
        }
      },
      itemCount: urlList.length,
      viewportFraction: 0.7,
      scale: 0.8,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                logout();
              }),
        ],
        backgroundColor: Colors.black,
      ),
      body: Builder(
        builder: (context) => Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Container(
              child: Expanded(
                child: imageSlider(context),
                flex: 6,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      price == null ? 'N.A' : price,
                      style: kSendButtonTextStyle.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      productName,
                      style: kSendButtonTextStyle.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      desc,
                      style: kSendButtonTextStyle.copyWith(
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              flex: 2,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () {
                          showLocation(context, location);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.location_pin),
                            Expanded(
                              child: Text(
                                location,
                                overflow: TextOverflow.ellipsis,
                                style: kSendButtonTextStyle.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: kSendButtonTextStyle.copyWith(
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Material(
                elevation: 10,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                color: Colors.white, // button color
                child: InkWell(
                  splashColor: Colors.red, // inkwell color
                  child:
                      SizedBox(width: 56, height: 56, child: Icon(Icons.chat)),
                  onTap: () {
                    // This is Chat Button
                    if (loading == false) {
                      if (sellers != null && productName != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return ChatScreen(sellers, productName, price, true,
                                false, urlList, false);
                          }),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: Material(
                elevation: 10,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                color: Colors.white, // button color
                child: InkWell(
                  splashColor: Colors.red, // inkwell color
                  child: SizedBox(
                      width: 56, height: 56, child: Icon(Icons.local_offer)),
                  onTap: () {
                    // This is Offer Button
                    if (loading == false) {
                      if (sellers != null && productName != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return ChatScreen(sellers, productName, price, true,
                                false, urlList, true);
                          }),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLocation(var context, var locationName) {
    // This gives that non interruptive alert known as toast in Android.
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(locationName),
      ),
    );
  }
}
