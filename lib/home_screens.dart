import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:users_notify/new_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? mToken = "";
  TextEditingController userName = TextEditingController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  TextEditingController title = TextEditingController();

  TextEditingController body = TextEditingController();

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    try {
      if (title != null && title.isNotEmpty) {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return NewPage(info: title.toString());
        }));
      } else {}
    } catch (e) {
      throw e.toString();
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse? response) {
    if (response != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return NewPage(info: response.payload.toString());
      }));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
    getToken();
    initInfo();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User Granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User granted provisional permission");
    } else {
      print('User declined');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAwGBWy1I:APA91bGllpSZtcQ3-tewPPYVRyRcsdGxX7EwUVT6JGtWnMMyHmNOjecjcSN3deK1H5C0GiTkWwbGrwEHXJw2LrGUDRJW7vMWyxZreoStVM43nPF0JBmJITb8qLo1jPsI3ZGH7VRVEQk_',
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "dbfood"
            },
            "to": token,
          }));
    } catch (e) {
      throw e.toString();
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mToken = token;
      });

      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection("UserTokens")
        .doc("User1")
        .set({'token': token});
  }

  void initInfo() async {
    var androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitialize,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'dbfood',
        'dbfood',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );
      NotificationDetails platformChannelSpecifies = NotificationDetails(
          android: androidNotificationDetails,
          iOS: DarwinNotificationDetails());

      await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, platformChannelSpecifies,
          payload: message.data['title']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: userName,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "Enter Name"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: title,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "Enter Title"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: body,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: "Enter Body"),
              ),
            ),
            GestureDetector(
              onTap: () async {
                String name = userName.text.trim();

                String titleText = title.text;
                String bodyText = body.text;

                if (name != "") {
                  DocumentSnapshot snapshot = await FirebaseFirestore.instance
                      .collection("UserTokens")
                      .doc(name)
                      .get();

                  String token = snapshot['token'];

                  print(token);

                  sendPushMessage(token, titleText, bodyText);
                }
              },
              child: Container(
                margin: EdgeInsets.all(20),
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.red)]),
                child: Center(
                  child: Text(
                    "Notification",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
