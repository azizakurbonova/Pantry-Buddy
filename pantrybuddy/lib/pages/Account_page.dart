import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/home_page.dart';
import 'package:pantrybuddy/pages/join_pantry_page.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';
import 'package:pantrybuddy/reg/forgot_pw_page.dart';
import 'package:pantrybuddy/reg/login_page.dart';

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

  // remove user from pantry
  void removeUserFromPantry() async {
    final database = FirebaseDatabase.instance.ref();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;
    FoodInventory pantry = await fetchPantry();
    final String pantryCode = await fetchPantryID();
    if (userId == pantry.owner) {
      //if owner tries to leave, just delete pantry
      deletePantry();
    }
    //remove user from list of users in FoodInventory
    List<String> users = pantry.users;
    int indexToRemove = users.indexOf(userId); //find their index
    if (indexToRemove != -1) {
      // if user exists in list
      users.removeAt(indexToRemove); // Remove the user from the list
      await database
          .child('foodInventories/$pantryCode/users')
          .set(users); // update
    }
    //remove inventoryID from User
    final userRef =
        FirebaseDatabase.instance.ref().child('users').child(userId);
    userRef.update({'inventoryID': null});
  }

  Future<void> deletePantry() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;
    FoodInventory pantry = await fetchPantry();
    if (userId != pantry.owner) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child:
                    Text('Only the owner has permission to delete the pantry!'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
      return;
    }
    final databaseReference = FirebaseDatabase.instance.ref();

    //remove inventoryid from every user
    List<String> users = pantry.users;
    String pantryCode = pantry.inventoryId as String;

    for (String userId in users) {
      //working
      Map<String, dynamic> update = {};
      update['inventoryID'] = "Null";
      databaseReference.child('users/$userId').update(update);
    }

    //delete FoodInventory
    databaseReference.child('foodInventories/$pantryCode').remove();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ),
    );
  }

  void deleteAccount() async {
    FoodInventory pantry = await fetchPantry();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;
    if (userId != pantry.owner) {
      removeUserFromPantry();
    } //if not owner, leave pantry
    else {
      deletePantry();
    } // if owner, delete pantry
    //then delete user from database
    final databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child('users').child(userId).remove();
    //and firebase auth
    FirebaseAuth.instance.currentUser?.delete();
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
                      return Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 251, 226, 255),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SelectableText(
                            "Your Pantry ID is: ${snapshot.data}\n\nCopy and paste to share with your friends and have them join your pantry!",
                            style: TextStyle(fontSize: 22),
                            textAlign: TextAlign.center,
                          ));
                    }
                  }
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      removeUserFromPantry();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return HomePage();
                          },
                        ),
                      );
                    },
                    child: Text('Leave Pantry'),
                  ),
                  SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () async {
                      deletePantry();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return HomePage();
                          },
                        ),
                      );
                    },
                    child: Text('Delete Pantry (Owner)'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const ForgotPasswordPage();
                          },
                        ),
                      );
                    },
                    child: Text('Change Password'),
                  ),
                  SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () async {
                      deleteAccount();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginPage(
                              showRegisterPage: () {},
                            );
                          },
                        ),
                      );
                    },
                    child: Text('Delete Account'),
                  ),
                ],
              ),
            ])))));
  }
}
