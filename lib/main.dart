import 'package:cemfrontend/providers/files.dart';
import 'package:cemfrontend/screens/dashboard_screen.dart';
import 'package:cemfrontend/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth.dart';
import 'screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => Auth()),
          ChangeNotifierProxyProvider<Auth, Files>(
              create: (BuildContext ctx)=>Files(null, null),
              update: (ctx, auth, previousProducts) => Files(auth.token, auth.userName)),
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
              }),
        ));
  }
}
