import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
/// This widget is used to show a login/signup screen
/// It has two text fields for email and password and a button to submit the form
class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  // submit the login/signup form
  // if the user is logging in, call the login method from FirebaseAuth
  Future<void> _submit() async {
    try {
      if (_isLogin) {
        // Sign in
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email.text, password: _password.text);
      } else {
        // Sign up
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email.text, password: _password.text);
      }
      // If the user is logged in, navigate to the map screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // show firebase specific error messages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Authentication Error"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One Sip Coffee Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // created a text field for email and password
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? "Login" : "Sign Up"),
            ),
            // created a text button to switch between login and signup
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin ? "Create Account" : "Back to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
