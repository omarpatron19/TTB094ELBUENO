import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String name;
  String mobileNumber;
  String email;
  Timestamp timestamp;
  String firebaseToken;
  String uid;
  String rol;

  UserModel(
      {this.name,
      this.mobileNumber,
      this.email,
      this.timestamp,
      this.uid,
      this.firebaseToken});

  toMap() {
    return {
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'uid': uid,
      'timestamp': FieldValue.serverTimestamp()
    };
  }

  // 4th part - from map to model object

  factory UserModel.fromMap(Map map) {
    UserModel user = UserModel(
      name: map["name"],
      mobileNumber: map["mobileNumber"],
      email: map["email"],
      timestamp: map["timestamp"],
      uid: map["uid"],
      firebaseToken: map["firebaseToken"],
    );
    user.rol = map["rol"];
    return user;
  }
}
