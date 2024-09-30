import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './signup_screen.dart';
import './main_page.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final VoidCallback onSignUpClicked;

  LoginScreen({super.key, required this.onSignUpClicked});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double formWidth = constraints.maxWidth > 600
                  ? 400 // Fixed width for larger screens
                  : double.infinity; // Full width for smaller screens

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: formWidth,
                    child: Column(
                      children: [
                        buildTextField(
                          controller: emailController,
                          labelText: 'Email',
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 15),
                        buildTextField(
                          controller: passwordController,
                          labelText: 'Password',
                          icon: Icons.lock,
                          obscureText: true,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              await handleLogin(context);
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: onSignUpClicked,
                          child: const Text(
                            "Don't have an account? Sign up",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.purple),
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[800],
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple),
        ),
      ),
    );
  }

  Future<void> handleLogin(BuildContext context) async {
    try {
      // Log in the user with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Fetch user data from Firestore using user ID (UID from FirebaseAuth)
      String userId = userCredential.user?.uid ?? '';
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Extract user data and store it locally for use throughout the app
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userDoc.id);
        await prefs.setString('firstName', userData['firstName']);
        await prefs.setString('lastName', userData['lastName']);
        await prefs.setString('email', userData['email']);

        // Successful login, navigate to main page or home screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Successfully logged in as ${userData['email']}')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      // Show an error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log in: ${e.toString()}')),
      );
    }
  }
}
