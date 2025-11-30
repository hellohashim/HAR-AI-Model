import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // <-- ADD THIS


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final user = FirebaseAuth.instance.currentUser; 
  signout() async{
    await FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user?.email ?? 'Guest'}!'), // Display user email
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (()=>signout()),
                
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}