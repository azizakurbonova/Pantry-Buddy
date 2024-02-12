import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/user.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  @override
  void dispose() { //for memory management
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
      _confirmpasswordController.text.trim()) {
        return true;
      } else {
        return false;
      }
  }

  Future signUp() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseDatabase _database = FirebaseDatabase.instance;

    try {
      if (passwordConfirmed()) {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        //UPDATE DATABASE WITH NEW USER
        // Successful registration
        if (userCredential.user != null) {
          String userId = userCredential.user!.uid; // Get the user ID

          // Here, you create a map or use your User model to represent user data
          Map<String, dynamic> userData = {
            "userId": userId,
            "email": _emailController.text.trim(),
          };

          // Update the Realtime Database with the new user's information
          await FirebaseDatabase.instance.ref("users/$userId").set(userData);

          //TO-DO: Navigate user to different screen upon first successfully registering, to do after Figma setup
        }

      } else {
        showDialog (
          context: context,
          builder: (context) {
            return AlertDialog (
              content: Text('Passwords must match!'),
            );
          }
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog (
        context: context,
        builder: (context) {
          return AlertDialog (
            content: Text(e.message.toString()),
          );
        }
      );
    };
  }


  @override
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
                  'Welcome!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 52,
                  ),
                ),
                const SizedBox(height:10),
                const Text (
                  'Password must be at least 6 characters',
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

                //confirm password textfield
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField (
                    obscureText: true, //add eyeball icon to allow user to see password?
                    controller: _confirmpasswordController,
                    decoration: InputDecoration (
                      enabledBorder: OutlineInputBorder (
                        borderSide: const BorderSide (color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder (
                        borderSide: const BorderSide (color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Confirm Password',
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              
                //sign up button
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector (
                    onTap: signUp, //method
                    child: Container (
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration (
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center (
                        child: Text (
                          'Sign Up',
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
                      'I am a member!',
                      style: TextStyle (
                        fontWeight: FontWeight.bold 
                      ),
                    ),
                    GestureDetector (
                      onTap: widget.showLoginPage,
                      child: const Text (
                        ' Login now',
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