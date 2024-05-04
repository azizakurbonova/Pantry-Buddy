import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<String> pantryId;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    pantryId = getData();
    super.initState();
  }

  Future<String> getData() async {
    return await fetchPantryID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[400],
          elevation: 0,
        ),
        endDrawer: sideBar(context),
        backgroundColor: Colors.green[200],
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    //fixes enter text overflow
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
              FutureBuilder<String>(
                future: pantryId,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      //selectable so can copy paste
                      return SelectableText(
                        "Your Pantry ID is: ${snapshot.data}\n\nCopy and paste to share with your friends and have them join your pantry!",
                        style: TextStyle(fontSize: 22),
                        textAlign: TextAlign.center,
                      );
                    }
                  }
                },
              ),
            ])))));
  }
}
