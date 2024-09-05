import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricketapp/Models/Team.dart';
import 'package:cricketapp/Services/session_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/src/foundation/change_notifier.dart';

class AuthServices with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseref = FirebaseDatabase.instance.ref('user');
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
      notifyListeners();
  }
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<String> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    loading = true;
    String res = "Some error occurred";
    try {
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        final user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await _firestore.collection("user").doc(user.user!.uid).set({
          'email': email,
          'name': name,
          'password': password,
          'uid': user.user!.uid,
          'phoneNumber': '',
          'profileimage': '',
        }).then((value) {
          SessionManager().userid = user.user!.uid.toString();
        });
        res = "success";
      }
    } catch (e) {
      loading = false;
      return e.toString();
    }
    return res;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password).then((value) {
          SessionManager().userid = value.user!.uid.toString();
        });
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (e) {
      return e.toString();

    }
    return res;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateProfile(String name, String profileimage) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateProfile(displayName: name, photoURL: profileimage);
      await user.reload();
    }
  }

  Future<String> uploadProfileImage(File profileImage, String uid) async {
    try {
      Reference storageReference = _storage.ref().child('profileimage/$uid');
      UploadTask uploadTask = storageReference.putFile(profileImage);

      await uploadTask.whenComplete(() => null);

      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading profile image: $e");
      throw Exception("Error uploading profile image: ${e.toString()}");
    }
  }

  Future<void> updateUserInfo(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('user').doc(uid).update(userData);
  }

  Stream<DocumentSnapshot> streamUserInfo(String uid) {
    return _firestore.collection('user').doc(uid).snapshots();
  }
  Future<String> uploadOrUpdateProfileImage(File profileImage, String uid) async {
    try {
      // Define the reference to the storage location
      Reference storageReference = _storage.ref().child('profileimage/$uid');

      // Upload the file
      UploadTask uploadTask = storageReference.putFile(profileImage);
      TaskSnapshot snapshot = await uploadTask;

      // Ensure upload is successful
      if (snapshot.state == TaskState.success) {
        // Get the download URL
        String downloadURL = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new image URL
        await _firestore.collection('user').doc(uid).update({'profileimage': downloadURL});

        return downloadURL;
      } else {
        throw Exception("Upload failed with state: ${snapshot.state}");
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      throw Exception("Error uploading profile image: ${e.toString()}");
    }
  }

  Future<void> initializeProfileImage(String uid) async {
    DocumentSnapshot snapshot = await _firestore.collection('user').doc(uid).get();
    if (snapshot.exists && snapshot.data() != null) {
      var userData = snapshot.data() as Map<String, dynamic>;
      if (userData['profileimage'] == null || userData['profileimage'].isEmpty) {
        // Set a default image or handle the case where there is no initial image
        await _firestore.collection('user').doc(uid).update({'profileimage': 'default_image_url'});
      }
    }
  }
  Future<void> updateProfiles(String displayName, String photoURL) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await user.reload();
    }
  }
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      String? uid = getCurrentUserId();
      if (uid != null) {
        DocumentSnapshot snapshot = await _firestore.collection('user').doc(uid).get();
        if (snapshot.exists) {
          return snapshot.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      print("Error retrieving user profile: $e");
      return null;
    }
  }


  Future<void> deleteUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('user').doc(user.uid).delete();
        await user.delete();
      } catch (e) {
        throw Exception("Error deleting user: $e");
      }
    }
  }
  Stream<QuerySnapshot> streamgetuserprofile() {
    return _firestore.collection('user').where("uid",isNotEqualTo: _auth.currentUser!.uid).snapshots();
  }
}

