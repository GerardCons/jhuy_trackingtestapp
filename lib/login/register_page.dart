import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhuy_trackingtestapp/login/check_user_type.dart';

class RegisterPage extends StatelessWidget {
  final String userType;

  RegisterPage({required this.userType});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Create a new user with email and password
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Add user data to Firestore based on the selected user type
      await _firestore.collection(userType).add({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              CheckUserTypePage(user: _auth.currentUser, context: context),
        ),
      );

      // Navigate to a success or home page
      // You can add your navigation logic here
    } catch (e) {
      print('Error registering user: $e');
      // Handle registration error and display a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email'),
            TextField(controller: _emailController),
            SizedBox(height: 16),
            Text('Password'),
            TextField(controller: _passwordController, obscureText: true),
            SizedBox(height: 16),
            Text('First Name'),
            TextField(controller: _firstNameController),
            SizedBox(height: 16),
            Text('Last Name'),
            TextField(controller: _lastNameController),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Call the registration method
                _register(context);
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
