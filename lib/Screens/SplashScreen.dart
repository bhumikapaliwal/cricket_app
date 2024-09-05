import 'dart:async';

import 'package:cricketapp/Screens/Homepage.dart';
import 'package:cricketapp/Screens/Authentication/authpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => MySplashScreenState();
}

class MySplashScreenState extends State<MySplashScreen> {
  bool isloggingin= true;
  static const String LOGINKEY="login";
  void islogin(){
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user =_auth.currentUser;
    if(user!=null) {
      // SessionManager().userid= user.uid.toString();
      Timer(Duration(seconds: 6), () => Navigator.pushNamed(context, 'main'));
    }else{
      Timer(Duration(seconds: 6), () => Navigator.pushNamed(context, 'authpage'));
    }
  }
  @override
  void initState() {
    super.initState();
    islogin();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/Animation - 1724919504833.json', // Replace with your Lottie animation asset path
                width: 400,
                height: 200,
                fit: BoxFit.cover,)
              // Image.asset('assets/opener-loading.json'),
              // Text('Welcome',
              //   style: TextStyle(
              //       fontWeight: FontWeight.w700,
              //       color: Theme.of(context).primaryColor,
              //       fontSize: 34
              //   ),),
            ],
          ),
        ),
      ),
    );
  }
}
