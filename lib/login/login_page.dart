import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jhuy_trackingtestapp/login/check_user_type.dart';
import 'package:jhuy_trackingtestapp/login/choose_user.dart';
import 'package:jhuy_trackingtestapp/login/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Redirect to CheckUserTypePage after successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              CheckUserTypePage(user: userCredential.user, context: context),
        ),
      );
    } catch (e) {
      print('Error logging in: $e');
      // Show a Snackbar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect email or password. Please try again.'),
        ),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField("Email", _emailController),
            SizedBox(height: 16),
            _buildTextField("Password", _passwordController, isPassword: true),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Call the login method
                _login(context);
              },
              child: Text('Login'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChooseUserPage(),
                ));
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
