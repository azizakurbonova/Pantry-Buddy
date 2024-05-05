import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/home_page.dart';
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
  void removeUserFromPantry(String pantryCode) async {
    final database = FirebaseDatabase.instance.ref();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;
    //remove user from list of users in FoodInventory
    FoodInventory pantry = await fetchPantry();
    List<String> users = pantry.users;
    int indexToRemove = users.indexOf(userId); //find their index
    if (indexToRemove != -1) { // if user exists in list
      users.removeAt(indexToRemove); // Remove the user from the list
      await database.child('foodInventories/$pantryCode/users').set(users); // update
    }
    //remove inventoryID from User
    final userRef = FirebaseDatabase.instance.ref().child('users').child(userId);
    userRef.update({'inventoryID': null});
  }

  void deletePantry(String ownerId, List<String> users) {
    if (FirebaseAuth.instance.currentUser?.uid != ownerId) {
      AlertDialog(
        content: Text('Only the owner has permission to delete the pantry!')
      );
      return;
    }
    final databaseReference = FirebaseDatabase.instance.ref();

    //remove inventoryid from every user
    for (String userId in users) {
      databaseReference.child('users').child(userId).update({'pantry': null});
    }

    //delete FoodInventory
    String pantry = fetchPantryID() as String;
    databaseReference.child('foodInventories').child(pantry).remove();

    Navigator.push( //nav to home page
      context,
      MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ),
    );
  }

  void deleteAccount() {
    FoodInventory pantry = fetchPantry() as FoodInventory;
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (FirebaseAuth.instance.currentUser?.uid != pantry.owner) {
      List<String> users = pantry.users;
      deletePantry(pantry.owner, users);
    } //if owner, delete the pantry
    else { 
      removeUserFromPantry(fetchPantry() as String);
    }// else, just remove from pantry
    //then delete user from database
    final databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child('users').child(userId!).remove();
    //and firebase auth
    FirebaseAuth.instance.currentUser?.delete();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {  },)),
    );
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
                      return Container (
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
                        removeUserFromPantry(fetchPantryID() as String);
                      },
                      child: Text('Leave Pantry'),
                    ),
                    SizedBox(width: 4),

                    ElevatedButton(
                      onPressed: () async {
                        // Implement owner delete pantry functionality
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
                      },
                      child: Text('Delete Account'),
                    ),
                  ],
                ),
            ])))));
  }
}
