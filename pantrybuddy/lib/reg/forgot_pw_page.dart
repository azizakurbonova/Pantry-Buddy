import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog (
        context: context,
        builder: (context) {
          return const AlertDialog (
            content: Text('Password reset link sent! Check your email'),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog (
        context: context,
        builder: (context) {
          return AlertDialog (
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar (
        backgroundColor: Colors.green[400],
        elevation: 0,
      ),
      backgroundColor: Colors.green[200],
      body: Column (
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding (
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text (
              'Enter your email and we will send you a password reset link:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ), 
          const SizedBox(height:10),

          Padding (
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField (
              controller: _emailController,
              decoration: InputDecoration (
                enabledBorder: OutlineInputBorder (
                  borderSide: const BorderSide (color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder (
                  borderSide: const BorderSide (color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Email',
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
          ),
          const SizedBox(height:10),
          
          MaterialButton (
            onPressed: () async {
              await passwordReset();
            },
            color: Colors.green,
            child: const Text('Reset Password'),
          )
        ]
      )
    );
  }
}