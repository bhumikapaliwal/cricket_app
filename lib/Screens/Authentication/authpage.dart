import 'package:cricketapp/Screens/Authentication/login.dart';
import 'package:cricketapp/Screens/Authentication/signup.dart';
import 'package:flutter/material.dart';

class Authpage extends StatefulWidget {
  const Authpage({super.key});

  @override
  State<Authpage> createState() => _AuthpageState();
}

class _AuthpageState extends State<Authpage> {
   bool islogin =true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body:
       // SingleChildScrollView(
       //  child:
        Container(child:
         // children: [
           islogin? Login():Signup()
         // ],
        ),
      // ),
    );
  }
}
