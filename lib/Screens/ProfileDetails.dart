/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Components/AppBarWithoutSearch.dart';
import 'package:flutter_buycycle/Components/BottomBar.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

/*
For Personal Reference
* Elements Used here :
* Compress File
* ModalProgressHUD
*/

// My Personal TODO List
// TODO: Add more information in this portion

var profileEmail;

class ProfileDetails extends StatefulWidget {
  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
  ProfileDetails(String profilesEmail) {
    profileEmail = profilesEmail;
  }
}

class _ProfileDetailsState extends State<ProfileDetails>
    with TickerProviderStateMixin {
  FirebaseAuth fa = FirebaseAuth.instance;
  Firestore fs = Firestore.instance;
  FirebaseStorage fbs = FirebaseStorage.instance;
  String imgUrl;
  String name = '';
  String language = '';
  String email = '';
  AnimationController _resizableController;
  var loggedUser;
  File imageClicked;
  File imgFile;
  Image img = Image.asset('assets/profile.png');

  AnimatedBuilder getContainer() {
    return new AnimatedBuilder(
        animation: _resizableController,
        builder: (context, child) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(24),
              child: CircleAvatar(
                radius: 100,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                    color: Colors.blue,
                    width: _resizableController.value * 10 + 1),
              ),
            ),
          );
        });
  }

  void currentUser() async {
    loggedUser = await fa.currentUser();
    getData();
  }

  void getData() async {
    var uidSnap = await fs.collection('UIDS').document(profileEmail).get();
    var uid = await uidSnap.data['uid'];
    var data = await fs
        .collection('Users')
        .document(uid)
        .collection('Details')
        .document('Details')
        .get();
    String namea = await data.data['Name'];
    String emaila = await data.data['Email'];
    String imgUrla = await data.data['Profile Image'];
    String languagea = await data.data['Language'];

    setState(() {
      name = namea;
      language = languagea;
      email = emaila;
      imgUrl = imgUrla;
      if (imgUrl.isNotEmpty) {
        try {
          img = Image.network(imgUrl);
        } catch (e) {
          img = Image.asset('assets/profile.png');
        }
      }
    });
  }

  @override
  void initState() {
    currentUser();
    _resizableController = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );
    _resizableController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _resizableController.reverse();
          break;
        case AnimationStatus.dismissed:
          _resizableController.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _resizableController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBarWithoutSearch(ctx: context)
          .buildAppBarWithoutSearch(context, ' ', true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: WidgetCircularAnimator(
                innerIconsSize: 3,
                outerIconsSize: 3,
                innerAnimation: Curves.bounceIn,
                outerAnimation: Curves.bounceIn,
                innerColor: Colors.orangeAccent,
                reverse: false,
                outerColor: Colors.orangeAccent,
                innerAnimationSeconds: 10,
                outerAnimationSeconds: 10,
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(8.0),
                      // need to update this with proper crop system !!
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: img.image, // picked file
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Text(
                    email,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        ctx: context,
      ),
    );
  }
}
