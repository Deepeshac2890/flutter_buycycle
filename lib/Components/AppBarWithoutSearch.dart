/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_buycycle/Screens/ProfileDetails.dart';
import 'package:flutter_buycycle/Screens/WelcomeScreen.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class AppBarWithoutSearch {
  final ctx;
  var photo;
  var profilePic;
  var isClickable = false;
  FirebaseAuth fa = FirebaseAuth.instance;
  var phoneNumber;

  AppBarWithoutSearch({this.ctx});

  // This is a named Constructor as in DART only one unnamed constructor can be made
  AppBarWithoutSearch.chatScreen(
      {this.ctx, this.photo, this.isClickable, this.phoneNumber});

  AppBar buildAppBarWithoutSearch(
      BuildContext context, String title, bool isActionLogout) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[actionWidget(isActionLogout)],
      title: buildTitle(title),
      backgroundColor: Colors.black,
    );
  }

  Widget actionWidget(isLogout) {
    if (isLogout) {
      return IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            logout();
          });
    } else {
      return IconButton(
          icon: Icon(Icons.call),
          onPressed: () {
            callPerson();
          });
    }
  }

  void callPerson() {
    if (phoneNumber != null) UrlLauncher.launch('tel:$phoneNumber');
  }

  Image getImage() {
    Image img;
    print('asd');
    if (photo.toString() != '') {
      print('Getting here');
      try {
        img = Image.network(photo);
      } catch (e) {
        // In case if error comes when trying to get the image from URL.
        img = Image.asset('assets/profile.png');
      }
    } else {
      // In case if image does not exist
      print('Getting Here 2');
      img = Image.asset('assets/profile.png');
    }
    return img;
  }

  Widget buildTitle(String title) {
    if (photo == null) {
      if (isClickable == true) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (ctx) => ProfileDetails(title),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title),
            ],
          ),
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
          ],
        );
      }
    } else {
      print(photo);
      if (isClickable) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (ctx) => ProfileDetails(title),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image(image: getImage().image),
              ),
              SizedBox(
                width: 5,
              ),
              Text(title),
            ],
          ),
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image(image: getImage().image),
            ),
            SizedBox(
              width: 5,
            ),
            Text(title),
          ],
        );
      }
    }
  }

  void logout() async {
    await fa.signOut();
    Navigator.popUntil(ctx, ModalRoute.withName(WelcomeScreen.id));
  }
}
