import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:work_out_app/screens/home_screen.dart';
import 'login_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';  // <-- ADD THIS
import 'package:work_out_app/screens/wrapper.dart';

class SinupScreen extends StatefulWidget {
  const SinupScreen({super.key});

  @override
  State<SinupScreen> createState() => _SinupScreenState();
}

class _SinupScreenState extends State<SinupScreen> {
  bool _isPasswordVisible = false;
  TextEditingController _emailAddress = TextEditingController();
  TextEditingController _password = TextEditingController();
  String _confirmPassword = "";
  bool _passwordsMatch = true;

  signup() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailAddress.text.trim(),
        password: _password.text,
      );

      // Successfully created account, navigate to Wrapper
      Get.offAll(() => const HomeScreen());
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = e.message ?? 'An error occurred';
      }
      // Show a snackbar with error
      Get.snackbar('Sign Up Failed', e.message ?? 'Error', 
      backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      print(e);
    }
  }


  // Colors extracted from the image
  final Color _primaryOrange = const Color(0xFFFF8C53); 
  final Color _borderColor = Color.fromARGB(255, 255, 115, 0);
  final Color _blackColor = const Color(0xFF1A1D26);
  final Color _greyFillColor = const Color(0xFFF3F4F6);
  final Color _textGrey = const Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    // Getting screen size for responsive layout
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section with Background Image and Gradient Fade
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // 1. Background Image
                SizedBox(
                  height: size.height * 0.35,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/sign_in_up_cover_pic.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                // 2. White Gradient Overlay to fade the image into the background
                Container(
                  height: size.height * 0.33,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.0), // Transparent at top
                        Colors.white.withOpacity(0.8),
                        Colors.white, // Solid white at bottom
                      ],
                      stops: const [0.4, 0.8, 1.0],
                    ),
                  ),
                ),
                // 3. Logo and Header Content positioned on top of the fade
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        SizedBox(height: 120),
                        Container(
                        height: 70,
                        width: 80,
                        padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                        decoration: BoxDecoration(
                          color: _borderColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _borderColor.withOpacity(0.3),
                              blurRadius: 15,
                             
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo2.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      Text(
                        "Sign Up For Free",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        "Let's personalize your fitness with AI",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Form Section

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // -- Email Field --
                  _buildLabel("Email Address"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailAddress,
                    style: TextStyle(color: _blackColor, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(

                      contentPadding: const EdgeInsets.all(20),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        child: Icon(Icons.mail_outline_rounded, color: _blackColor),
                      ),
                      // The focused border state shown in the image (Orange border)
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _borderColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _borderColor, width: 2.5),
                      ),
                      
                    ),


                  ),

                  const SizedBox(height: 15),

                  // -- Password Field --
                  _buildLabel("Password"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _password,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: _blackColor, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      contentPadding: const EdgeInsets.all(20),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        child: Icon(Icons.lock_outline_rounded, color: _blackColor),
                      ),
                      // Default border for password (no border/grey as per image)
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _borderColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _borderColor, width: 2.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    
                  ),

                  const SizedBox(height: 15),


                  // -- Password Field --
                  // -- Confirm Password Field --
                  _buildLabel("Confirm Password"),
                  const SizedBox(height: 8),
                  TextFormField(
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: _blackColor, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),

                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        child: Icon(Icons.lock_outline_rounded, color: _blackColor),
                      ),

                      // BORDER CHANGES IN REAL-TIME:
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _passwordsMatch ? _borderColor : Colors.red,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _passwordsMatch ? _borderColor : Colors.red,
                          width: 2.5,
                        ),
                      ),

                      suffixIcon: _passwordsMatch
                          ? IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            )
                          : const Icon(Icons.error, color: Colors.red),
                    ),

                    // REAL-TIME VALIDATION
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value;
                        _passwordsMatch = (_password.text.trim() == _confirmPassword.trim());
                      });
                    },
                  ),

                  // SHOW RED WARNING TEXT IF NOT MATCHED
                  if (!_passwordsMatch)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 5),
                      child: Text(
                        "Passwords do not match",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ),

                  const SizedBox(height: 20),

                  // -- Sign Up Button --
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _passwordsMatch && _password.text.isNotEmpty
                          ? () => signup()
                          : null,  // disables button
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 115, 0),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),

 
                  const SizedBox(height: 40),

                  // -- Footer Links --
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 76, 76, 76),
                        fontSize: 15,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign In.",
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
                ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for Labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

}