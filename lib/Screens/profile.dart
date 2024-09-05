import "dart:io";
import "dart:typed_data";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:cricketapp/Services/firebase_services.dart";
import "package:cricketapp/utils/costumappbar.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_svg/svg.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:image_picker/image_picker.dart";
import "package:provider/provider.dart";

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    User? user = Provider.of<AuthServices>(context, listen: false).getCurrentUser();
    if (user != null) {
      _emailController.text = user.email ?? '';
      Provider.of<AuthServices>(context, listen: false).initializeProfileImage(user.uid);
    }
  }

  Future<void> _pickImage() async {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final authService = Provider.of<AuthServices>(context, listen: false);
    User? user = authService.getCurrentUser();

    if (user != null) {
      String? photoURL;
      if (_profileImage != null) {
        try {
          photoURL = await authService.uploadOrUpdateProfileImage(_profileImage!, user.uid);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading profile image')));
          return;
        }
      } else if (_profileImageUrl != null) {
        photoURL = _profileImageUrl;
      }

      Map<String, dynamic> userData = {
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
        'password': _passController.text,
        if (photoURL != null) 'profileimage': photoURL,
      };

      await authService.updateUserInfo(user.uid, userData);
      await authService.updateProfile(_nameController.text, photoURL ?? user.photoURL ?? '');
      setState(() {
        _profileImageUrl = photoURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    }
  }
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServices>(context);
    User? user = authService.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomCurvedAppBar(
        backButtonTitle: "        Profile",
        height: 170,
        showBackButton: true,
        menubar: false,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg', // Replace with your image path
        imageOpacity: 0.7, title: '',
      ),
      body:
    //   Stack(
    //     children: [
    //   // SVG Background
    //   Positioned.fill(
    //   child: SvgPicture.asset(
    //     'assets/background/Animated Shape (3).svg',
    //     fit: BoxFit.cover, // Adjust as needed
    //   ),
    // ),
          user == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
        stream: authService.streamUserInfo(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data available'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          _nameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phoneNumber'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _passController.text = userData['password'] ?? '';
          _profileImageUrl = userData['profileimage'];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!) as ImageProvider
                          : AssetImage('assets/user.png'),
                    ),
                    Positioned(
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        shape: CircleBorder(),
                        child: Icon(Icons.add_a_photo_outlined, color: Theme.of(context).primaryColor),
                        onPressed: _pickImage,
                      ),
                      bottom: 0,
                      left: 80,
                    ),
                  ],
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    labelText: 'Name',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.account_circle),
                    prefixIconColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    labelText: 'Email Address',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.email),
                    prefixIconColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    labelText: 'Phone Number',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.phone_android),
                    prefixIconColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _passController,
                  keyboardType: TextInputType.visiblePassword,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    labelText: 'Password',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.lock),
                    prefixIconColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 30),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo[800]!)),
                        onPressed: _updateProfile,
                        child: authService.loading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Update Profile',style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    SizedBox(width: 20),
                    // SizedBox(width: 20,),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     try {
                    //       await Provider.of<AuthServices>(context, listen: false).deleteUser();
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(content: Text('User deleted successfully')),
                    //       );
                    //     } catch (e) {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(content: Text('Error deleting user: $e')),
                    //       );
                    //     }
                    //   },
                    //   child: Text('Delete Account'),
                    // )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    // ]
    //   )
    );
  }
}
