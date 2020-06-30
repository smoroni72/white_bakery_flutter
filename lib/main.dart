import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_message.dart';
import 'globals.dart' as globals;
import 'dart:developer';
import 'package:qrscan/qrscan.dart' as scanner;






//void main() => runApp(MyApp());

void main(){
//  MessageHandler();
  runApp(MyApp());

}



Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {

    return OKToast(
      child: MaterialApp(
        title: 'White Bakery',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
            primarySwatch: MyColors.white_bakery,
            primaryTextTheme: TextTheme(
                title: TextStyle(
                    color: const Color(0xFF705244)
                )
            )
        ),
//        home: WebViewPage(),
          home:  MessageHandler(),
      ),
    );
  }
}




class WebViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebViewExampleState();
  }
}

class _WebViewExampleState extends State<WebViewPage> {
  WebViewController _myController;
  bool _loadedPage = false;
  Future<String> _barcodeString;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _loadedPage = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('White Bakery App'),
        ),
        body: Builder(builder: (BuildContext context) {
           return new Stack(
            children: <Widget>[
                new WebView(
                  initialUrl: 'https://optimusnt.com/fidelity/',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller){
                    _myController = controller;
                  },
                  javascriptChannels: <JavascriptChannel>[
                    _messaggioJavascriptChannel(context),
                  ].toSet(),
                  onPageFinished: (url){
                    print('Page finished loading: $url');

    //                _myController.evaluateJavascript('tokenFirebase(' +  globals.token_firebase    + '")');
                    _myController.evaluateJavascript('tokenFirebase(' +  globals.token_firebase    + ')')
                    .then((result) {});
                    setState(() {
                     _loadedPage = true;
                    });
                  },
               ),
             _loadedPage == false
              ? new Center(
                child: new CircularProgressIndicator(
                backgroundColor: MyColors.white_bakery),
              )
              : new Container(),
            ],
           );
        }),

      floatingActionButton: FloatingActionButton(
        tooltip: 'scansiona il QRCode',
        child: Icon (MdiIcons.qrcodeScan,size: 30 ),
        onPressed: ()
          async {
            await _scan();
          },
        elevation: 20.0,
        highlightElevation: 20.0,
        backgroundColor: const Color(0xFF705244),
        foregroundColor: MyColors.white_bakery  ,
      ),
    );
  }

  Future<String> _scan() async {
    String barcode = await scanner.scan();
    print ("Qrcode scansionato: " + barcode) ;
    _myController.evaluateJavascript('qrcode(' +  barcode    + ')')
        .then((result) {});
  }

  JavascriptChannel _messaggioJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

}



class MyColors {

  static const MaterialColor white_bakery = MaterialColor(
    0xFFFFFAE3,
    <int, Color>{
      50: Color(0xFFFFFEFC),
      100: Color(0xFFFFFEF7),
      200: Color(0xFFFFFDF1),
      300: Color(0xFFFFFCEB),
      400: Color(0xFFFFFBE7),
      500: Color(0xFFFFFAE3),
      600: Color(0xFFFFF9E0),
      700: Color(0xFFFFF9DC),
      800: Color(0xFFFFF8D8),
      900: Color(0xFFFFF6D0),
    },
  );
}
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
      print('ecco il token:' + token); // Print the Token in Console
      globals.token_firebase=token;
    }



    );


  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'White Bakery',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
          primarySwatch: MyColors.white_bakery,
          primaryTextTheme: TextTheme(
              title: TextStyle(
                  color: const Color(0xFF705244)
              )
          )
      ),
      home: WebViewPage(),
    );

  }



}