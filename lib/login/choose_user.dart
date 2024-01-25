import 'package:flutter/material.dart';
import 'package:jhuy_trackingtestapp/login/register_page.dart';

class ChooseUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose User Type')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to RegisterPage with user type "User"
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegisterPage(userType: 'user'),
                ));
              },
              child: Text('User'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to RegisterPage with user type "Driver"
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegisterPage(userType: 'driver'),
                ));
              },
              child: Text('Driver'),
            ),
          ],
        ),
      ),
    );
  }
}
