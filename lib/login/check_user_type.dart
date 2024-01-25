import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhuy_trackingtestapp/page/driver_home.dart';
import 'package:jhuy_trackingtestapp/page/user_home.dart';

class CheckUserTypePage extends StatelessWidget {
  final User? user;
  final BuildContext context; // Add context as a parameter

  CheckUserTypePage({required this.user, required this.context}) {
    _checkUserType(context); // Pass context to _checkUserType
  }

  Future<String?> _getUserType(String email) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot userSnapshot = await _firestore
        .collection('user')
        .where('email', isEqualTo: email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      return 'user';
    }

    QuerySnapshot driverSnapshot = await _firestore
        .collection('driver')
        .where('email', isEqualTo: email)
        .get();

    if (driverSnapshot.docs.isNotEmpty) {
      return 'driver';
    }

    return null;
  }

  void _checkUserType(BuildContext context) async {
    String? userType = await _getUserType(user!.email!);
    if (userType == 'user') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => UserHomePage(
                  userEmail: user!.email!,
                )),
      );
    } else if (userType == 'driver') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => DriverHomePage(
                  userEmail: user!.email!,
                )),
      );
    } else {
      // Handle the case where the user type is not found
      // You can display an error message or navigate to an appropriate page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
