import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'login_Screen.dart'; // Make sure you have a LoginScreen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔵 FULLSCREEN BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_page_bg.jpg',
              fit: BoxFit.cover,
              
            ),
          ),

          // 🔵 DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // 🔵 CONTENT OVERLAY
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // 🔵 LOGO
                Image.asset(
                  'assets/images/logo.jpg',
                  width: 100,
                  height: 100,
                ),

                const SizedBox(height: 10),

                // 🔵 BIG HIGHLIGHTED TEXT
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome To",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "TrainMax",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 115, 0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                const Text(
                  "Your Personal Workout Tracker",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 215, 214, 214),
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 5,
                      )
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                // 🔵 BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 115, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Get Started",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 🔵 "Already have an account? Sign in" text
                RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 215, 214, 214),
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: "Sign in",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 115, 0),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to login page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 90), // gap from bottom
              ],
            ),
          ),
        ],
      ),
    );
  }
}
