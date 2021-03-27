/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Components/AppBarWithoutSearch.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'ChatScreen.dart';

/*
For Personal Reference
* Elements Used here :
* RefreshIndicators
* GestureDetector
* ImageSlider
*/

FirebaseAuth fu = FirebaseAuth.instance;
Firestore fs = Firestore.instance;
String loggedInUser;
String uid;
List<String> chatRoomList = [];
List<ListItems> items = [];

class ChatDashboard extends StatefulWidget {
  @override
  _ChatDashboardState createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard> {
  bool loading = true;
  var listWidget;
  bool on = true;

  @override
  void initState() {
    currentUser();
    super.initState();
  }

  Future<void> chatRoomListGetter() async {
    try {
      await fs
          .collection('Users')
          .document(uid)
          .collection('Chats')
          .snapshots()
          .forEach((element) {
        element.documents.forEach((element) {
          var st = element.documentID;
          if (!chatRoomList.contains(st)) {
            chatRoomList.add(st);
            listMaker();
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void listMaker() async {
    List<ListItems> listItems = [];
    for (String chatId in chatRoomList) {
      var snap = await fs
          .collection('Messages')
          .document(chatId)
          .collection('Information')
          .document('Data')
          .get();
      String itemName = await snap.data['item'];
      String price = await snap.data['price'];
      String buyer = await snap.data['buyer'];
      String seller = await snap.data['seller'];
      String offerPrice = await snap.data['offered price'];
      var inSnap = await fs
          .collection('Messages')
          .document(chatId)
          .collection('Information')
          .document('Data')
          .collection('Images')
          .getDocuments();
      List<String> urls = [];
      var internalQuerySnaps = inSnap.documents;
      for (int j = 0; j < internalQuerySnaps.length; j++) {
        var b = internalQuerySnaps[j];
        var url = await b.data['url'];
        urls.add(url);
      }
      // Image img = await Image.network(imgUrl);
      bool isBuying = buyer == loggedInUser;
      String displayName = isBuying ? seller : buyer;
      ListItems ls = ListItems(
        itemName: itemName,
        price: price,
        emailFront: displayName,
        seller: seller,
        buyer: buyer,
        isBuying: isBuying,
        imgUrls: urls,
        offerPrice: offerPrice,
      );
      listItems.add(ls);
    }
    setState(() {
      items = listItems;
    });
  }

  Widget displayItems() {
    List<ListItems> ls = [];
    for (ListItems lo in items) {
      if (!on && lo.seller == loggedInUser) {
        ls.add(lo);
      } else if (on && lo.buyer == loggedInUser) {
        ls.add(lo);
      }
    }
    if (ls != null) {
      return ListView(
        children: ls,
      );
    } else
      return Container();
  }

  void currentUser() async {
    try {
      final user = await fu.currentUser();
      if (user != null) {
        loggedInUser = user.email;
        uid = user.uid;
        chatRoomListGetter();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBarWithoutSearch(ctx: context)
          .buildAppBarWithoutSearch(context, 'Inbox'),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      // Something will happen
                      setState(() {
                        on = true;
                      });
                    },
                    child: Text(
                      'Buying',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      //Something will happen
                      setState(() {
                        on = false;
                      });
                    },
                    child: Text(
                      'Selling',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 5,
                    color: on ? Colors.white : Colors.black,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 5,
                    color: on ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: RefreshIndicator(
                onRefresh: () async {
                  chatRoomListGetter();
                },
                child: displayItems()),
          ),
        ],
      ),
    );
  }
}

class ListItems extends StatelessWidget {
  final Image image = Image.asset('assets/default.png');
  final emailFront;
  final itemName;
  final price;
  final seller;
  final buyer;
  final isBuying;
  final imgUrls;
  final offerPrice;

  ListItems(
      {this.itemName,
      this.price,
      this.emailFront,
      this.seller,
      this.buyer,
      this.isBuying,
      this.imgUrls,
      this.offerPrice});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return ChatScreen(
                emailFront, itemName, price, false, isBuying, null, false);
          }),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        height: 100,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 10),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: imageSlider(context)),
              flex: 1,
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      emailFront,
                      style: TextStyle(color: Colors.white),
                    ),
                    // After Implementation of Make Offer Section
                    Text('Offered Price : ' + offerPrice,
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      scale: 1,
    );
  }
}
