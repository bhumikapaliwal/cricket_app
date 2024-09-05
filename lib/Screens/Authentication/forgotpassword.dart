import 'package:cricketapp/utils/costumappbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ForgotPasswordscreen extends StatefulWidget {
  const ForgotPasswordscreen({super.key});

  @override
  State<ForgotPasswordscreen> createState() => _ForgotPasswordscreenState();
}

class _ForgotPasswordscreenState extends State<ForgotPasswordscreen> {
  final TextEditingController emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: Colors.white,
      appBar: CustomCurvedAppBar(
        title: "Add Team",
        height: 170,
        showBackButton: true,
        menubar: false,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg', // Replace with your image path
        imageOpacity: 0.7,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20,top: 100),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  TextFormField(
                       controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Theme.of(context).primaryColor,
                       decoration: InputDecoration(
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                         ),
                           hintText: 'Email Address',
                           labelText: 'Email Address',
                           alignLabelWithHint: true,
                           prefixIcon: Icon(Icons.email_outlined),
                           prefixIconColor: Theme.of(context).primaryColor,
                            ), ),
            SizedBox(height: 10,),
            ElevatedButton(
                style:ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo[900]!)),
                onPressed: (){
              auth.sendPasswordResetEmail(email: emailController.text.toString()).then((value){
               return ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('We have sent the email successfully')));
              });
            }, child: Text('Forgot Password',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))
                    ],
               ),
      ),
    );
  }
}
