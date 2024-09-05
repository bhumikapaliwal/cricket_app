import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricketapp/Services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NevBar extends StatefulWidget {
  @override
  State<NevBar> createState() => _NevBarState();
}

class _NevBarState extends State<NevBar> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServices>(context);
    User? user = authService.getCurrentUser();

    return Drawer(
      backgroundColor: Colors.white,
      child: user == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
        stream: authService.streamUserInfo(user.uid),
        builder: (context, snapshot) {
          String name = '';
          String email = '';
          String profileImageUrl = '';

          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for the data
          } else if (snapshot.hasError) {
            // Handle errors
            print('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data!.exists) {
            // Extract user data if available
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            name = userData['name'] ?? 'No Name';
            email = userData['email'] ?? 'No Email';
            profileImageUrl = userData['profileimage'] ?? '';
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: UserAccountsDrawerHeader(
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : AssetImage('assets/user (1).png') as ImageProvider,
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/pexels-mam-ashfaq-1314585-3452356.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), // Adjust the opacity here
                        BlendMode.luminosity,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.indigo[800]),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pushNamed(context, 'profile');
                },
              ),
              // ListTile(
              //   leading: Icon(Icons.payment, color: Colors.indigo[800]),
              //   title: Text('Payment'),
              //   onTap: () {
              //     Navigator.pushNamed(context, 'savedcardscreen');
              //   },
              // ),
              // ListTile(
              //   leading: Icon(Icons.settings, color: Colors.indigo[800]),
              //   title: Text('Settings'),
              //   onTap: () {
              //     // Handle settings tap
              //   },
              // ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.indigo[800]),
                title: Text('Logout'),
                onTap: () {
                  authService.logout();
                  Navigator.pushReplacementNamed(context, 'login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
