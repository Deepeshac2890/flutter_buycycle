/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_buycycle/Components/BottomBar.dart';
import 'package:flutter_buycycle/Screens/ItemScreen.dart';
import 'package:flutter_buycycle/Screens/WelcomeScreen.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../Constants.dart';

/*
For Personal Reference
* Elements Used here :
* It is a copy of DashBoard with some minor tweaks.
 */
Firestore fs = Firestore.instance;
FirebaseAuth fa = FirebaseAuth.instance;
var loggedInUser;

class MyAdsPage extends StatefulWidget {
  static String id = 'My_Ads_Page_Screen';
  @override
  _MyAdsPageState createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  List<CustomItem> items = <CustomItem>[];
  bool isSpinning = true;
  String searchString = '';

  @override
  void initState() {
    // TODO: implement initState
    getCurrentUser();
    streamData();
    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = await fa.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(user.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void logout() async {
    await fa.signOut();
    Navigator.popUntil(context, ModalRoute.withName(WelcomeScreen.id));
  }

  void streamData() async {
    var currentUser = await fa.currentUser();

    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("Cycle").getDocuments();

    var querySnaps = querySnapshot.documents;
    String adTitle;
    String adInfo;
    String location;
    String seller;
    String price;
    List<CustomItem> items = <CustomItem>[];
    for (int i = 0; i < querySnaps.length; i++) {
      var a = querySnaps[i];
      seller = await a.data['Seller'];
      // This page only has this change != to == so need to modularize!!!!
      if (seller == currentUser.email) {
        adTitle = await a.data['AdTitle'];
        adInfo = await a.data['AdInfo'];
        location = await a.data['Location'];
        price = await a.data['Price'];
        var docId = await a.documentID;
        List<String> urls = [];
        QuerySnapshot internalQS = await fs
            .collection('Cycle')
            .document(docId)
            .collection('Images')
            .getDocuments();
        var internalQuerySnaps = internalQS.documents;
        for (int j = 0; j < internalQuerySnaps.length; j++) {
          var b = internalQuerySnaps[j];
          var url = await b.data['url'];
          urls.add(url);
        }
        if (adTitle.contains(searchString)) {
          CustomItem item = CustomItem(
            adTitle: adTitle,
            date: a.data['Date'].toString().substring(0, 10),
            price: price,
            imgUrls: urls,
            location: location,
            adInfo: adInfo,
            seller: seller,
          );
          items.add(item);
        }
      }
    }
    if (items != null) {
      setState(() {
        // Here we do this as global items is being used in build and we need to
        // change it to rebuild it. This is Important concept !!!!
        this.items = items;
        isSpinning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isSpinning,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Expanded(
              child: GestureDetector(
                onHorizontalDragDown: (dragDown) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    // Do something
                    searchString = value;
                    streamData();
                  },
                  decoration: kMessageTextFieldDecoration.copyWith(
                    hintText: 'Find Your Desired Item',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  logout();
                }),
          ],
          backgroundColor: Colors.black,
        ),
        body: GestureDetector(
          child: GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(10.0),
            children: items,
          ),
        ),
        bottomNavigationBar: BottomBar(
          ctx: context,
        ),
      ),
    );
  }
}

class CustomItem extends StatelessWidget {
  final price;
  final adTitle;
  final date;
  final List<String> imgUrls;
  final adInfo;
  final location;
  final url;
  final seller;
  CustomItem(
      {this.adTitle,
      this.date,
      this.price,
      this.imgUrls,
      this.adInfo,
      this.seller,
      this.location,
      this.url});

  Swiper imageSlider(context) {
    return new Swiper(
      autoplay: true,
      loop: false,
      itemBuilder: (BuildContext context, int index) {
        if (imgUrls.length != 0) {
          return new Image.network(
            imgUrls[index],
            fit: BoxFit.fitHeight,
          );
        } else {
          return new Image.asset('default.png');
        }
      },
      itemCount: imgUrls.length,
      viewportFraction: 0.5,
      scale: 0.8,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return ItemScreen(
                imgUrls, price, adTitle, adInfo, location, date, seller);
          }),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: imageSlider(context),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              price,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              adTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              date,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
