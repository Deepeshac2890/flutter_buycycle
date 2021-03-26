import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Components/AppBarWithoutSearch.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:translator/translator.dart';

import '../Constants.dart';

FirebaseUser loggedInUser;
String emailFront;
String itemName;
String price;
String chatId;
bool fromItemScreen;
String titleEmail = ' ';
Stream st;
bool isBuyingFromDash;
List<String> imgUrls;
bool isAnOffer;
final offerTextController = TextEditingController();
Codec<String, String> stringToBase64 = utf8.fuse(base64);
final fs = Firestore.instance;

class ChatScreen extends StatefulWidget {
  static String id = 'ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
  ChatScreen(emailsFront, itemNames, prices, fromItemScreens, isBuyingFromDashs,
      imgUrl, isAnOffers) {
    emailFront = emailsFront;
    itemName = itemNames;
    price = prices;
    fromItemScreen = fromItemScreens;
    isBuyingFromDash = isBuyingFromDashs;
    imgUrls = imgUrl;
    titleEmail = emailsFront;
    isAnOffer = isAnOffers;
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth fu = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  // ignore: close_sinks
  String msgTxt;
  String offer;
  bool messageNotLoading = true;

  String encodeMessage(String msg) {
    return stringToBase64.encode(msg);
  }

  void sendMessage() async {
    try {
      await fs.collection('Messages').document(chatId).collection('Chats').add({
        'sender': loggedInUser.email,
        'text': encodeMessage(msgTxt),
        'receiver': emailFront,
        'isOffer': isAnOffer,
      });
      if (fromItemScreen) {
        if (isAnOffer) {
          await fs
              .collection('Messages')
              .document(chatId)
              .collection('Information')
              .document('Data')
              .setData({
            'item': itemName,
            'price': price,
            'offered price': offerTextController.text,
            'seller': emailFront,
            'buyer': loggedInUser.email,
          });
        } else {
          await fs
              .collection('Messages')
              .document(chatId)
              .collection('Information')
              .document('Data')
              .setData({
            'item': itemName,
            'price': price,
            'offered price': 'N.A',
            'seller': emailFront,
            'buyer': loggedInUser.email,
          });
        }

        await fs
            .collection('Users')
            .document(loggedInUser.uid)
            .collection('Chats')
            .document(chatId)
            .setData({
          'Party1': loggedInUser.email,
          'Party2': emailFront,
          'Item': itemName,
        });
        var dr = await fs.collection('UIDS').document(emailFront).get();
        var uidOfReceiver = await dr.data['uid'];
        await fs
            .collection('Users')
            .document(uidOfReceiver)
            .collection('Chats')
            .document(chatId)
            .setData({
          'Party1': loggedInUser.email,
          'Party2': emailFront,
          'Item': itemName,
        });
        var imagesDoc = await fs
            .collection('Messages')
            .document(chatId)
            .collection('Information')
            .document('Data')
            .collection('Images')
            .getDocuments();
        if (imagesDoc.documents.length == 0) {
          int i = 0;
          for (i = 0; i < imgUrls.length; i++) {
            await fs
                .collection('Messages')
                .document(chatId)
                .collection('Information')
                .document('Data')
                .collection('Images')
                .add({
              'url': imgUrls[i],
              'index': i,
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
    messageNotLoading = false;
  }

  void currentUser() async {
    try {
      final user = await fu.currentUser();
      if (user != null) {
        loggedInUser = user;
        if (fromItemScreen) {
          chatId = loggedInUser.email + emailFront + itemName;
        } else {
          if (isBuyingFromDash) {
            chatId = loggedInUser.email + emailFront + itemName;
          } else
            chatId = emailFront + loggedInUser.email + itemName;
        }
        setState(() {
          st = fs
              .collection('Messages')
              .document(chatId)
              .collection('Chats')
              .snapshots();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser();
    offerTextController.text = price.toString();
  }

  void clearCache() async {
    await DefaultCacheManager().emptyCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithoutSearch(ctx: context)
          .buildAppBarWithoutSearch(context, titleEmail),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: MessageStream(),
          ),
          buildBottom(),
        ],
      ),
    );
  }

  Container buildBottom() {
    if (isAnOffer)
      return buildOffer();
    else
      return buildChat();
  }

  Container buildChat() {
    return Container(
      decoration: kMessageContainerDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onHorizontalDragDown: (dragDownDetails) {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              },
              child: TextField(
                controller: messageTextController,
                onChanged: (value) {
                  msgTxt = value;
                },
                decoration: kMessageTextFieldDecoration,
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              messageTextController.clear();
              sendMessage();
            },
            child: Text(
              'Send',
              style: kSendButtonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Container buildOffer() {
    return Container(
      decoration: kMessageContainerDecoration,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriceSuggestor(
                    text: getPriceSuggestion(1),
                  ),
                  PriceSuggestor(
                    text: getPriceSuggestion(2),
                  ),
                  PriceSuggestor(
                    text: getPriceSuggestion(3),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(),
              flex: 2,
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Text(
              'Rs.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragDown: (dragDownDetails) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
                child: TextField(
                  controller: offerTextController,
                  onChanged: (value) {
                    msgTxt = value;
                    setState(() {});
                  },
                  keyboardType: TextInputType.number,
                  decoration: kMessageTextFieldDecoration.copyWith(
                      hintText: 'Your Offer'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  getText(),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.all(10),
                child: FlatButton(
                  color: Colors.black54,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                  onPressed: () {
                    messageTextController.clear();
                    msgTxt = offerTextController.text;
                    sendMessage();
                  },
                  child: Text(
                    'Send',
                    style: kSendButtonTextStyle.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

String getPriceSuggestion(int level) {
  String priceText;
  if (level == 1)
    priceText = (int.parse(price) * 0.9).toString();
  else if (level == 2)
    priceText = (int.parse(price) * 0.8).toString();
  else if (level == 3) priceText = (int.parse(price) * 0.7).toString();
  return priceText.substring(0, priceText.indexOf('.'));
}

String getText() {
  String prices = offerTextController.text;
  int offerVal = int.parse(prices);
  int askedVal = int.parse(price);
  if (offerVal > askedVal) {
    return 'Why Do you want Overpay !!';
  } else if (offerVal / askedVal > 0.65) {
    return 'High Chances of Getting Reply !!';
  } else if (offerVal / askedVal > 0.45) {
    return 'Medium Chances of Getting Reply !!';
  } else {
    return 'Low Chances of Getting Reply !!';
  }
}

class PriceSuggestor extends StatelessWidget {
  final text;
  PriceSuggestor({this.text});
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        margin: EdgeInsets.all(5),
        child: FlatButton(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(40),
          ),
          onPressed: () {
            // Something will happen
            offerTextController.text = text;
          },
          child: Text(text),
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  String decodeMessage(String msg) {
    return stringToBase64.decode(msg);
  }

  @override
  Widget build(BuildContext context) {
    try {
      return StreamBuilder<QuerySnapshot>(
          stream: st,
          builder: (context, snapshot) {
            List<Widget> messageBubbles = [];

            if (snapshot.hasData != null && snapshot.data != null) {
              // snapshot is async snapshot from Flutter
              // Reversed is added to reverse the order of the list so new message goes
              // the bottom
              final messages = snapshot.data.documents.reversed;
              for (var message in messages) {
                // message is document snapshot from firebase
                String messageText = message.data['text'];
                messageText = decodeMessage(messageText);
                final messageSender = message.data['sender'];
                final isOffer = message.data['isOffer'];
                final currentUser = loggedInUser.email;
                if (isOffer) {
                  final offerBubble = OfferBubble(
                    sender: messageSender,
                    text: messageText,
                    isMe: currentUser == messageSender,
                  );
                  messageBubbles.add(offerBubble);
                } else {
                  final messageBubble = MessageBubble(
                    sender: messageSender,
                    text: messageText,
                    isMe: currentUser == messageSender,
                  );
                  messageBubbles.add(messageBubble);
                }
              }
              return ListView(
                // This makes listview sticky to bottom of listview
                reverse: true,
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                children: messageBubbles,
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    } catch (e) {
      print(e);
      return ListView(
        children: [
          Expanded(
            child: Icon(Icons.error),
          ),
        ],
      );
    }
  }
}

/* Currently the Translation Function is giving the translated Text as snack bar
 In future release try to give it in the List widget only problem that we face here
 was that when tried making the message bubble stateful the sent messages were not
 displayed instantly.*/
class MessageBubble extends StatelessWidget {
  final String sender;
  String text;
  final bool isMe;
  double topLeft;
  double topRight;
  Color colorDef;
  CrossAxisAlignment cal;
  BuildContext ctx;
  MessageBubble({this.sender, this.text, this.isMe});
  @override
  Widget build(BuildContext context) {
    ctx = context;
    topLeft = isMe ? 30.0 : 0.0;
    topRight = isMe ? 0.0 : 30.0;
    colorDef = isMe ? Colors.white : Colors.blue;
    cal = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: cal,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeft),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(topRight),
            ),
            color: colorDef,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text('$text'),
            ),
          ),
          GestureDetector(
              onTap: () {
                translate();
              },
              child: Icon(Icons.translate))
        ],
      ),
    );
  }

  void translate() async {
    var translator = GoogleTranslator();
    var uid = loggedInUser.uid;
    var ds = await fs
        .collection('Users')
        .document(uid)
        .collection('Details')
        .document('Details')
        .get();
    String lang = await ds.data['Language'];
    var translatedText = await translator.translate(text, to: lang);
    // Alert(context: ctx, title: translatedText.text).show();
    Scaffold.of(ctx).showSnackBar(
      SnackBar(
        content: Text(translatedText.text),
      ),
    );
  }
}

class OfferBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  double topLeft;
  double topRight;
  Color colorDef;
  CrossAxisAlignment cal;
  BuildContext ctx;
  OfferBubble({this.sender, this.text, this.isMe});
  @override
  Widget build(BuildContext context) {
    ctx = context;
    topLeft = isMe ? 30.0 : 0.0;
    topRight = isMe ? 0.0 : 30.0;
    colorDef = isMe ? Colors.white : Colors.blue;
    cal = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: cal,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeft),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(topRight),
            ),
            color: colorDef,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                children: [
                  Text(
                    'Offer : ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Rs. $text',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
