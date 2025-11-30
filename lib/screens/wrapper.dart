import 'package:firebase_auth/firebase_auth.dart';  // <-- ADD THIS
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_Screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // User is signed in
              return HomeScreen(); // <-- Make sure to import HomeScreen
            } else {
              // User is not signed in
              return LoginScreen(); // <-- Make sure to import LoginScreen
            }
          } else {
            // Show loading indicator while checking auth state
            return Center(child: CircularProgressIndicator());
          }
        },
      )
    );
  }
}