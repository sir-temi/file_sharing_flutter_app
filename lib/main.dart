import 'package:cemfrontend/providers/files.dart';
import 'package:cemfrontend/screens/dashboard_screen.dart';
import 'package:cemfrontend/screens/file_detail_screen.dart';
import 'package:cemfrontend/screens/file_downloaded_screen.dart';
import 'package:cemfrontend/screens/search_file.dart';
import 'package:cemfrontend/screens/search_user.dart';
import 'package:cemfrontend/screens/upload_file.dart';
import 'package:cemfrontend/widgets/loading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'providers/auth.dart';
import 'screens/auth_screen.dart';
import 'screens/search_user.dart';

import 'package:flutter_downloader/flutter_downloader.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
                FlutterLocalNotificationsPlugin();

 AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

void main() async{ 
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
    );

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

  runApp(MyApp());
  }


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => Auth()),
          ChangeNotifierProxyProvider<Auth, Files>(
              create: (BuildContext ctx)=>Files(null, null),
              update: (ctx, auth, previousFiles) => Files(auth.token, auth.userName)),
          // ChangeNotifierProxyProvider<Auth, Orders>(
          //     create: (BuildContext ctx)=>Orders(null, null),
          //     update: (ctx, auth, previousProducts) => Orders(auth.token, auth.userPk)),
          // ChangeNotifierProvider(create: (ctx) => Cart()),
        ],
        child: Consumer<Auth>(
          builder: (ctx, authData, child) => MaterialApp(
              title: "TemiShare",
              theme: ThemeData(
                primarySwatch: Colors.teal,
                accentColor: Colors.tealAccent,
              ),
              home: authData.isAuth 
              ? DashboardScreen() 
              : FutureBuilder(
                future: authData.tryAutoLogin(),
                builder: (ctx, authSnapshot) =>
                  authSnapshot.connectionState == ConnectionState.waiting
                  ? Loading('Authenticating you...')
                  : AuthScreen()
              ),
              routes: {
                AuthScreen.routeName: (ctx) => AuthScreen(),
                DashboardScreen.routeName: (ctx) => DashboardScreen(),
                FileDetailScreen.routeName: (ctx) => FileDetailScreen(),
                DownloadScreen.routeName: (ctx) => DownloadScreen(),
                SearchUserScreen.routeName: (ctx) => SearchUserScreen(),
                UploadFileScreen.routeName: (ctx) => UploadFileScreen(),
                SearchFileScreen.routeName: (ctx) => SearchFileScreen(),
              }),
        ));
  }
}
