import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea (
        child: Center (
          child: SingleChildScrollView ( //fixes enter text overflow
            child: Column (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              ]
            )
          )
        )
      )
    );
  }
}
