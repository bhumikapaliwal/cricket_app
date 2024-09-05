import 'package:cricketapp/Screens/Homepage.dart';
import 'package:cricketapp/Screens/Authentication/forgotpassword.dart';
import 'package:cricketapp/Screens/Authentication/signup.dart';
import 'package:cricketapp/Services/firebase_services.dart';
import 'package:cricketapp/main.dart';
import 'package:cricketapp/utils/costumappbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:sign_in_button/sign_in_button.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final Alertservice _alertservice =Alertservice();
  User? user;
  bool obsecurePass =true;
  bool islogin =false;
  bool isloading =false;
  String welcome ="facebook";
Map<String, dynamic>?  _userData;


  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

  void login()async{
    if (_formKey.currentState!.validate());
    String res = await AuthServices().login(
        email: emailController.text,
        password: passController.text,);
    if(res=="success"){
      setState(() {
        isloading=true;
      });
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>const MyHomePage()));
    }else{
      isloading=false;
     // _alertservice.showToast(text: "Check email or password");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No users saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomCurvedAppBar(
        title: "",
        height: 170,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg', // Replace with your image path
        imageOpacity: 0.4,
        menubar: false,
        showBackButton: false,
      ),
      body:
      // Padding(
      //   padding: const EdgeInsets.only(top:100, right:30, left:30),
      //    child:
      SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                 top: 30, right:30 , left:30 ,
                   ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(height: 2.7,
                // child: Lottie.asset('assets/Animation - 1720429008565.json')),
                Form(
                   key: _formKey,
                  child: Column(
                  children: [
                    Text("Sign-In",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.indigo[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 35),),
                    SizedBox(height: 35,),
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
                      prefixIconColor: Colors.indigo[900],
                    ), validator: (value){
                    if(value!.isEmpty){
                      return "Enter the Password";
                    }
                    if(value!.isEmpty ||!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value!))
                    {
                      return "Enter correct Email address";
                    }else{
                      return null;
                    }
                  },),
                    SizedBox(height: 7),
                    TextFormField(
                      controller: passController,
                      keyboardType: TextInputType.visiblePassword,
                      cursorColor: Theme.of(context).primaryColor,
                      obscureText: obsecurePass,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                          ),
                          hintText: 'Password',
                          labelText: 'Password',
                          alignLabelWithHint: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          prefixIconColor: Colors.indigo[900],
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obsecurePass = !obsecurePass;
                                });
                              },
                              icon: obsecurePass
                                  ? const Icon(
                                Icons.visibility_off_outlined,
                                color: Colors.black38,
                              )
                                  :  Icon(
                                Icons.visibility_outlined,
                                color: Theme.of(context).primaryColor,
                              ))),
                      validator: (value){
                        if(value!.isEmpty){
                          return "Enter the Password";
                        }
                        if(value!.length < 8)
                        {
                          return "Enter correct Password";
                        }else{
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Align(
                          alignment:Alignment.centerRight,
                          child: GestureDetector(onTap: (){Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context)=> ForgotPasswordscreen()));},
                            child: Text('Forgot Password ?',style: TextStyle(
                            color: Colors.indigo[900],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16
                                              ),),
                          )),
                    ),
                    SizedBox(height: 20,),
                  ElevatedButton(style:ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo[900]!)),
                      onPressed: login ,child: Text('Login',style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold),))
                  ],
                ), ),
                SizedBox(height: 30,),
                Column(
                  children: [
                    SignInButton(Buttons.google, onPressed:(){googlesignin(context);
                      // setState(() {
                      //   Navigator.pushReplacement(context, MaterialPageRoute(
                      //       builder: (context)=> MyHomePage()));
                      // });
                      },),
      //               SignInButton(Buttons.facebook, onPressed: ()async{signinfacebook();
      // //                 setState(() {
      // // Navigator.pushReplacement(context, MaterialPageRoute(
      // //     builder: (context)=> MyHomePage()));
      // //
      // //                 });
      //                }),
                    // SignInButton(Buttons.apple, onPressed: (){}),

                  ],
                ),
                SizedBox(height: 30,),
                Align(alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // MyApp.navigatorKey.currentState!.pushNamed('signup');
                          Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context)=> Signup()));
                          setState(() {
                            islogin = !islogin;
                          });
                        },
                        child:  Text(
                          'Sign Up',
                          style:  TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[900],
                          ),
                        ),
                      ),
                      //   )
                    ],
                  ),
                ),
              ],

            ),
          ),
        ),
      // ),
     );
  }

  void googlesignin(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Sign out of any existing Google accounts to force the account selection screen
      await googleSignIn.signOut();

      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      // Proceed to check if the selected email exists in Firebase Authentication
      checkIfUserExists(googleUser.email, context);
    } catch (error) {
      print('Google sign-in error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during sign-in. Please try again.')),
      );
    }
  }

  void checkIfUserExists(String email, BuildContext context) async {
    try {
      // Fetch sign-in methods for the given email
      List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty) {
        // User exists; you can proceed with further actions, like linking accounts
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User exists: $email')),
        );
      } else {
        // User does not exist; show Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found with this email.')),
        );
      }
    } catch (e) {
      print('Error checking if user exists: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while checking user.')),
      );
    }
  }



  Future<UserCredential> signinfacebook() async{
    final LoginResult  loginResult = await FacebookAuth.instance.login(permissions:['email','public_profile']);
    if(loginResult==LoginStatus.success){
      final userdata =await FacebookAuth.instance.getUserData();
      _userData =userdata;
    }else{
      print(loginResult.message);
    }
    setState(() {
      welcome = _userData!['email'];
    });
     final OAuthCredential oAuthcredential =FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
    return FirebaseAuth.instance.signInWithCredential(oAuthcredential);
  }
}
