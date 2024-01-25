import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jhuy_trackingtestapp/auth/auth_cubit.dart';
import 'package:jhuy_trackingtestapp/login/check_user_type.dart';
import 'package:jhuy_trackingtestapp/login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyBCn7NVaXti_QcpdPmo9n8E44ktPe1L8BI',
              appId: '1:732296420284:android:c7902a65edc62b610769b9',
              messagingSenderId: '732296420284',
              projectId: 'jhuy-env-test'))
      : await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) =>
            AuthCubit(), // Ensure you have the correct AuthCubit
        child: BlocBuilder<AuthCubit, User?>(
          builder: (context, user) {
            if (user != null) {
              // User is logged in, navigate to the user home page or a different page.
              return CheckUserTypePage(
                user: user,
                context: context,
              ); // Replace with your user home page.
            } else {
              // User is not logged in, show the login page.
              return LoginPage();
            }
          },
        ),
      ),
    );
  }
}
