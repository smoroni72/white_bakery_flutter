import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {

  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState(){
    super.initState();
    _fcm.configure(

      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },

    );
    _fcm.subscribeToTopic('all');
    _fcm.requestNotificationPermissions(IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
    ));
    _fcm.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Hello');
    });
    _fcm.getToken().then((token) {
//      print(token); // Print the Token in Console
    });
  }




  @override
  Widget build(BuildContext context) {
    return null;
  }


}