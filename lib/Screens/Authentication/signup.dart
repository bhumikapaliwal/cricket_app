import 'package:cricketapp/Screens/Homepage.dart';
import 'package:cricketapp/Screens/Authentication/login.dart';
import 'package:cricketapp/Services/firebase_services.dart';
import 'package:cricketapp/utils/costumappbar.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final _confirmpassController = TextEditingController();
  bool obsecurePass = true;
  bool isloading = false;

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    _confirmpassController.dispose();
    super.dispose();
  }

  void signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });

      String res = await AuthServices().signup(
        email: emailController.text,
        password: passController.text,
        name: nameController.text,
      );

      setState(() {
        isloading = false;
      });

      if (res == "success") {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyHomePage()));
      } else if (res == "user_exists") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User already exists')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomCurvedAppBar(
        title: "",
        height: 170,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg',
        imageOpacity: 0.4,
        menubar: false,
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 25, left: 25, bottom: 70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Text(
                      "Sign-Up",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.indigo[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 35),
                    ),
                    SizedBox(height: 35),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        prefixIcon: Icon(Icons.account_circle, size: 20),
                        prefixIconColor: Colors.indigo[900],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 7),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        prefixIcon: Icon(Icons.email_rounded, size: 20),
                        prefixIconColor: Colors.indigo[900],
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 7),
                    TextFormField(
                      controller: passController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
                        prefixIconColor: Colors.indigo[900],
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obsecurePass = !obsecurePass;
                            });
                          },
                          icon: obsecurePass
                              ? Icon(Icons.visibility_off_outlined, color: Colors.black38)
                              : Icon(Icons.visibility_outlined, color: Colors.indigo[900]),
                        ),
                      ),
                      obscureText: obsecurePass,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        } else if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                          return 'Password must contain at least one lowercase letter';
                        } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                          return 'Password must contain at least one uppercase letter';
                        } else if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                          return 'Password must contain at least one number';
                        } else if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
                          return 'Password must contain at least one special character';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 7),
                    TextFormField(
                      controller: _confirmpassController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
                        prefixIconColor: Colors.indigo[900],
                      ),
                      obscureText: obsecurePass,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm the Password";
                        } else if (value != passController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo[900]!),
                      ),
                      onPressed: signup,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[900],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
