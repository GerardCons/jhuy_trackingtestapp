import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCubit extends Cubit<User?> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthCubit() : super(null) {
    _initAuthState();
  }

  void _initAuthState() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      emit(user);
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Successfully logged in
    } catch (e) {
      print("Error logging in: $e");
      return false; // Login failed
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true; // Successfully registered
    } catch (e) {
      print("Error registering: $e");
      return false; // Registration failed
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
