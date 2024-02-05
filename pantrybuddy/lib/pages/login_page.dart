import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/forgot_pw_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) { //login unsuccessful
      print(e); 
      showDialog (//console
        context: context,
        builder: (context) {
          return AlertDialog (
            content: Text(e.message.toString())
          );
        }
      );
    }
  }

  @override
  void dispose() { //for memory management
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: SafeArea (
        child: Center (
          child: SingleChildScrollView ( //fixes enter text overflow
            child: Column (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //pantry buddy icon? or just have it for loading screens?
                //imagelcon widget
                /*
                ImageIcon (
                  AssetImage("images/icon.pgn"),
                  color: Colors.green,
                  size: 24,
                ),
                */

                //welcome text
                const Text (
                  'Hello',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 52,
                  ),
                ),
                const SizedBox(height:10),
                const Text (
                  'Your Pantry Buddy missed you!',
                  style: TextStyle (
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),

                //email textfield
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
                const SizedBox(height: 10),

                //password textfield
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField (
                    obscureText: true, //add eyeball icon to allow user to see password?
                    controller: _passwordController,
                    decoration: InputDecoration (
                      enabledBorder: OutlineInputBorder (
                        borderSide: const BorderSide (color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder (
                        borderSide: const BorderSide (color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Password',
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Padding (
                  padding: const EdgeInsets.symmetric(horizontal:25.0),
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector (
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) {
                                return ForgotPasswordPage();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle (
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          )
                        )
                      )
                    ],
                  ),
                ),
              
                const SizedBox(height: 10),
                //sign in button
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector (
                    onTap: signIn, //method
                    child: Container (
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration (
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center (
                        child: Text (
                          'Sign In',
                          style: TextStyle (
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                        ),
                      ),
                    ),
                  )
                ),
                const SizedBox(height: 25),

                //register button
                Row (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text (
                      'Not a Member?',
                      style: TextStyle (
                        fontWeight: FontWeight.bold 
                      ),
                    ),
                    GestureDetector (
                      onTap: widget.showRegisterPage,
                      child: const Text (
                        ' Register now',
                        style: TextStyle (
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ]
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}