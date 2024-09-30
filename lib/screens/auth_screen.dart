import 'package:flutter/material.dart';
import './login_screen.dart';
import './signup_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLogin = true;

  void toggleScreens() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MIFtek Assist',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.black,
      body: showLogin
          ? LoginScreen(onSignUpClicked: toggleScreens)
          : SignUpScreen(onLoginClicked: toggleScreens),
    );
  }
}
