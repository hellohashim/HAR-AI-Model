import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:work_out_app/screens/age_screen.dart';
import 'home_screen.dart';
import 'login_Screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Waiting for Auth connection
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. User is Logged In
          if (snapshot.hasData && snapshot.data != null) {
            User user = snapshot.data!;
            
            // CHECK DATABASE: Did they finish setup? (We check if 'weight' exists)
            return FutureBuilder<DataSnapshot>(
              future: FirebaseDatabase.instance
                  .ref('users/${user.uid}/assessment/weight') // Check specifically for weight
                  .get(),
              builder: (context, dbSnapshot) {
                if (dbSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.orange));
                }

                if (dbSnapshot.hasData && dbSnapshot.data!.value != null) {
                  // Weight exists -> Setup is done -> Go Home
                  return const HomeScreen();
                } else {
                  // Weight missing -> Setup incomplete -> Go to Age Screen
                  return const AgeSelectionScreen();
                }
              },
            );
          }

          // 3. User is NOT Logged In -> Show Login
          return const LoginScreen();
        },
      ),
    );
  }
}