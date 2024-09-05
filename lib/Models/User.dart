import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String? Uid;
  final String name;
  final String phoneNumber;
  final String email;
  final String? password;
  final String? profileimage;

  UserModel({required this.Uid,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.profileimage
  });
  tojson(){
    return {"username":name,"email":email,"phoneNumber":phoneNumber,"password":password,"profileimage":profileimage};
  }
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>>document){
    final data = document.data();
    return UserModel(Uid: document.id,
        name: data!["name"],
        phoneNumber:data!["phoneNumber"],
        email: data!["email"],
        password: data!["password"], profileimage: data!["profileimage"]);
  }
  factory UserModel.fromChatID(String chatID) {
    // Implement logic to retrieve user data from chatID
    // This is just a placeholder
    return UserModel(
        Uid: chatID,
        name: "User Name",
        phoneNumber: "Phone Number",
        email: "Email",
        password: null,
        profileimage: "Profile Image URL"
    );
  }
}