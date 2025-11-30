import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Note: Assuming 'package:get/get.dart' is available if needed for SnackBar, 
// but using standard Material Snackbar here for portability.

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final primaryOrange = const Color.fromARGB(255, 255, 115, 0);
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false; // State variable for loading indicator

  // Function with Error Handling and User Feedback
  void resetPassword() async {
    final emailAddress = emailController.text.trim();
    if (emailAddress.isEmpty) {
      _showSnackbar('Error', 'Please enter your email address.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailAddress);

      // Success feedback
      _showSnackbar(
        'Success',
        'Password reset link sent to $emailAddress. Check your inbox!',
        Colors.green,
      );
      
      // Optionally navigate the user back to the login screen after a delay
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.pop(context);
      }
      
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email. Please check your address.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }

      // Failure feedback
      _showSnackbar('Error', errorMessage, Colors.red);
    } catch (e) {
      // General error feedback
      _showSnackbar('Error', 'An unknown error occurred.', Colors.red);
    } finally {
      // Hide loading indicator regardless of success or failure
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to show SnackBar
  void _showSnackbar(String title, String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title: $message'),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // FIX: Ensure the body is wrapped in a SingleChildScrollView to prevent overflow
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Title
              const Text(
                "Reset Password",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),
              // Lock Icon
              Icon(
                Icons.lock_outline_rounded,
                size: 100,
                color: primaryOrange,
              ),
              const SizedBox(height: 30),
              // Instructions Text
              const Text(
                'Enter your registered email address below to receive the password reset link.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),
              // Email Input Field
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  contentPadding: const EdgeInsets.all(20),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(Icons.mail_outline_rounded, color: primaryOrange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryOrange.withOpacity(0.5), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryOrange, width: 2.5),
                  ),
                ),
              ),

              const SizedBox(height: 50),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : resetPassword, // Disable when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              // Add extra spacing for when the keyboard is up
              const SizedBox(height: 50), 
            ],
          ),
        ),
      ),
    );
  }
}