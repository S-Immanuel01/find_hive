import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// A model of a user, params: [name , email, regNo, contact, password]
///
/// Methods : fromjson - converts user json from firebase to usermodel obj
class UserModel {
  final String name;
  final String password;
  final String email;
  final String regNo;
  final String contact;
  static String _error = "error";

  const UserModel({
    this.name = " ",
    this.email = "",
    this.regNo = "",
    this.contact = "",
    this.password = "...",
  });

  /// convert from JSON Obj to a User Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      password: "....",
      regNo: json['regNo'],
      contact: json['contact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "email": email, "regNo": regNo, "contact": contact};
  }

  String get error => _error;

  set errorMessage(String message) => _error = message;

  Future<void> signInUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      errorMessage = error.toString();
      debugPrint(error.toString());
    }
  }

  Future<void> signUp() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final String userColDir = "users";
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      errorMessage = error.toString();
      debugPrint(error.toString());
    } finally {
      if (FirebaseAuth.instance.currentUser != null) {
        final User fireUser = FirebaseAuth.instance.currentUser!;
        fireUser.updateDisplayName(name);
        final String userDocDir = FirebaseAuth.instance.currentUser!.uid;
        db.collection(userColDir).doc(userDocDir).set(toJson());
      }
    }
  }

  /// Fetch user details from Firestore for the current user
  static Future<UserModel?> getUserDetails() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final String userColDir = "users";

    if (FirebaseAuth.instance.currentUser == null) {
      debugPrint('Error: No user is logged in');
      return null;
    }

    try {
      final userDocDir = FirebaseAuth.instance.currentUser!.uid;
      final docSnapshot = await db.collection(userColDir).doc(userDocDir).get();

      if (docSnapshot.exists) {
        return UserModel.fromJson(docSnapshot.data()!);
      } else {
        debugPrint('Error: User document does not exist for UID: $userDocDir');
        return null;
      }
    } catch (error) {
      debugPrint('Error fetching user details: $error');
      return null;
    }
  }
}
