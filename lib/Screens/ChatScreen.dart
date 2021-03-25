import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_buycycle/Screens/WelcomeScreen.dart';
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
Codec<String, String> stringToBase64 = utf8.fuse(base64);
final fs = Firestore.instance;

class ChatScreen extends StatefulWidget {
  static String id = 'ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
  ChatScreen(emailsFront, itemNames, prices, fromItemScreens, isBuyingFromDashs,
      imgsUrl) {
    emailFront = emailsFront;
    itemName = itemNames;
    price = prices;
    fromItemScreen = fromItemScreens;
    isBuyingFromDash = isBuyingFromDashs;
    imgUrls = imgsUrl;
    titleEmail = emailsFront;
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
      });
      print(fromItemScreen);
      if (fromItemScreen) {
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
        int i = 0;
        for (i = 0; i < imgUrls.length; i++) {
          print(i);
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
    } catch (e) {
      print(e);
    }
    messageNotLoading = false;
  }

  void sendOffer() async {
    try {
      // Implement Offer thing
    } catch (e) {
      print(e);
    }
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
        print(chatId);
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
  }

  void clearCache() async {
    await DefaultCacheManager().emptyCache();
  }

  void logout() async {
    try {
      await fu.signOut();
      Navigator.popUntil(context, ModalRoute.withName(WelcomeScreen.id));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Build Called');
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
        title: Center(child: Text(titleEmail)),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: MessageStream()),
          Container(
            decoration: kMessageContainerDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragDown: (DragDownDetails) {
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
          ),
        ],
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
            List<MessageBubble> messageBubbles = [];

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
                final currentUser = loggedInUser.email;
                final messageBubble = MessageBubble(
                  sender: messageSender,
                  text: messageText,
                  isMe: currentUser == messageSender,
                );
                messageBubbles.add(messageBubble);
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

// // Earlier it was stateless converted it to stateful to add
// // translation functionality.
// class MessageBubble extends StatefulWidget {
//   String sender;
//   String text;
//   bool isMe;
//   MessageBubble(senders, texts, isMes) {
//     sender = senders;
//     text = texts;
//     isMe = isMes;
//     print(text + 'Message Bubble');
//   }
//   @override
//   _MessageBubbleState createState() =>
//       _MessageBubbleState(isMe: isMe, sender: sender, text: text);
// }

// class _MessageBubbleState extends State<MessageBubble> {
//   final bool isMe;
//   final String sender;
//   String text;
//   String ol = 'en';
//   bool isTranslated = false;
//   var translator = GoogleTranslator();
//   _MessageBubbleState({
//     @required this.isMe,
//     this.sender,
//     this.text,
//   });
//   @override
//   Widget build(BuildContext context) {
//     print('Message Bubble build called' + text);
//     double topLeft;
//     double topRight;
//     Color colorDef;
//     CrossAxisAlignment cal;
//     topLeft = isMe ? 30.0 : 0.0;
//     topRight = isMe ? 0.0 : 30.0;
//     colorDef = isMe ? Colors.white : Colors.blue;
//     cal = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment: cal,
//         children: [
//           Text(
//             sender,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.black54,
//             ),
//           ),
//           Material(
//             elevation: 5.0,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(topLeft),
//               bottomLeft: Radius.circular(30.0),
//               bottomRight: Radius.circular(30.0),
//               topRight: Radius.circular(topRight),
//             ),
//             color: colorDef,
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//               child: Text(text),
//             ),
//           ),
//           GestureDetector(
//               onTap: () {
//                 translate();
//               },
//               child: Icon(Icons.translate))
//         ],
//       ),
//     );
//   }
//
//   void translate() async {
//     print(text);
//     print(isTranslated);
//     if (!isTranslated) {
//       var uid = loggedInUser.uid;
//       var ds = await fs
//           .collection('Users')
//           .document(uid)
//           .collection('Details')
//           .document('Details')
//           .get();
//       String lang = await ds.data['Language'];
//       var translatedText = await translator.translate(text, to: lang);
//       ol = text;
//       setState(() {
//         text = translatedText.toString();
//       });
//       isTranslated = true;
//     } else {
//       setState(() {
//         text = ol;
//       });
//       isTranslated = false;
//     }
//   }
// }

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
