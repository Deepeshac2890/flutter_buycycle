/*
Created By: Deepesh Acharya
Maintained By: Deepesh Acharya
*/

import 'package:flutter/material.dart';
import 'package:flutter_buycycle/Screens/ChatDashboard.dart';
import 'package:flutter_buycycle/Screens/Dashboard.dart';
import 'package:flutter_buycycle/Screens/MyAdsPage.dart';
import 'package:flutter_buycycle/Screens/MyProfile.dart';
import 'package:flutter_buycycle/Screens/SellScreen.dart';

class BottomBar extends StatelessWidget {
  final ctx;
  BottomBar({this.ctx});
  @override
  Widget build(BuildContext ctx) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BottomBarIcons(
              icon: Icons.chat,
              color1: Colors.blue,
              color2: Colors.redAccent,
              iconText: 'Chat Dashboard',
              tapFunc: () {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (context) {
                    return ChatDashboard();
                  }),
                );
              },
            ),
            BottomBarIcons(
              icon: Icons.album_sharp,
              color1: Colors.blue,
              color2: Colors.redAccent,
              iconText: 'Your Ads',
              tapFunc: () {
                Navigator.pushNamed(ctx, MyAdsPage.id);
              },
            ),
            BottomBarIcons(
              icon: Icons.add,
              color2: Colors.blue,
              color1: Colors.redAccent,
              iconText: 'Sell your Product',
              tapFunc: () {
                Navigator.pushNamed(ctx, SellScreen.id);
              },
            ),
            BottomBarIcons(
              icon: Icons.dashboard,
              color2: Colors.redAccent,
              color1: Colors.blue,
              iconText: 'Dashboard',
              tapFunc: () {
                Navigator.pushNamed(ctx, DashBoard.id);
              },
            ),
            BottomBarIcons(
              icon: Icons.person,
              color1: Colors.blue,
              color2: Colors.redAccent,
              iconText: 'My Profile',
              tapFunc: () {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (context) {
                    return Profile();
                  }),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class BottomBarIcons extends StatelessWidget {
  final icon;
  final tapFunc;
  final color1;
  final color2;
  final iconText;
  BottomBarIcons(
      {this.icon, this.tapFunc, this.color1, this.color2, this.iconText});
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: color1, // button color
        child: InkWell(
          onLongPress: () {
            // ignore: deprecated_member_use
            Scaffold.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                backgroundColor: Colors.white,
                content: Text(
                  iconText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
          splashColor: color2, // inkwell color
          child: SizedBox(width: 56, height: 56, child: Icon(icon)),
          onTap: tapFunc,
        ),
      ),
    );
  }
}
