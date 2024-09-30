import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './login_screen.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  SignUpScreen({super.key});

  // Key for storing the next available ID in SharedPreferences
  static const String nextIdKey = 'next_user_id';

  // Function to get the next user ID from storage
  Future<int> getNextIdFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(nextIdKey) ?? 0;
  }

  // Function to save the next user ID to storage
  Future<void> saveNextIdToStorage(int nextId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(nextIdKey, nextId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
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
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: formWidth,
                      child: Column(
                        children: [
                          buildTextField(
                            controller: firstNameController,
                            labelText: 'First Name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 15),
                          buildTextField(
                            controller: lastNameController,
                            labelText: 'Last Name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 15),
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
                          const SizedBox(height: 15),
                          buildTextField(
                            controller: confirmPasswordController,
                            labelText: 'Confirm Password',
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
                                await handleSignUp(context);
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              // Navigate to login screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Already have an account? Login',
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

  Future<void> handleSignUp(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Create a new user with email and password
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Fetch the latest _nextId from persistent storage
      int currentId = await getNextIdFromStorage();

      // Store user information in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
      });

      // Increment the ID and update storage
      await saveNextIdToStorage(currentId + 1);

      // Redirect to the login screen after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Show an error message if sign-up fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up: ${e.toString()}')),
      );
    }
  }
}
