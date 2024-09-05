import 'package:cricketapp/Screens/Homepage.dart';
import 'package:cricketapp/Screens/SplashScreen.dart';
import 'package:cricketapp/Screens/Authentication/forgotpassword.dart';
import 'package:cricketapp/Screens/Authentication/login.dart';
import 'package:cricketapp/Screens/menubar.dart';
import 'package:cricketapp/Screens/profile.dart';
import 'package:cricketapp/Screens/Authentication/signup.dart';
import 'package:cricketapp/Services/firebase_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Screens/Authentication/authpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthServices()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Scoreboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MySplashScreen(),
        'main':(context) =>  MyHomePage(),
        'authpage':(context) => Authpage(),
        'signup':(context) => Signup(),
        'login':(context) => Login(),
        'menubar':(context) => NevBar(),
        'profile':(context) => ProfileScreen(),
        'forgotpassword':(context) => const ForgotPasswordscreen()
      },
    );
  }
}


