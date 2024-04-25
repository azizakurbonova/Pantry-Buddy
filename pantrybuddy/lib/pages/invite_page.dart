import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/invite_page.dart';
import 'package:pantrybuddy/scripts/getInventory.dart';

class InvitePage extends StatelessWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final _nameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      //appBar
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 0,
        //title: Text("Top Bar"),
      ),
      //drawer. pulls out on top right
      endDrawer: Drawer(
        child: Container(
          color: Colors.green[400],
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.account_box, color: Colors.black),
                title: Text(
                  "Account",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AccountPage()));
                },
              ),
              ListTile(
                // each page is a ListTitle
                leading: Icon(Icons.notifications, color: Colors.black),
                title: Text(
                  "Notifications",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationPage()));
                },
              ),
              ListTile(
                // each page is a ListTitle
                leading: Icon(Icons.insert_invitation, color: Colors.black),
                title: Text(
                  "Invite People",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => InvitePage()));
                },
              ),
              ListTile(
                // each page is a ListTitle
                leading: Icon(Icons.food_bank, color: Colors.black),
                title: Text(
                  "Inventory",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => InventoryPage()));
                },
              ),
              ListTile(
                  leading: Icon(Icons.logout, color: Colors.black),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  }),
            ],
          ),
        ),
      ),

      //body

      backgroundColor: Colors.green[200],
      body: SafeArea(
        child: Form(
          key: _formKey, //can use for validation
          child: Center(
            child: SingleChildScrollView(
              //fixes enter text overflow
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "User ID: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 15),

                  //name
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter user ID';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'User ID',
                          fillColor: Colors.grey[100],
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                  //SUBMIT BUTTON
                  const SizedBox(height: 35),
                  ElevatedButton(
                      onPressed: () async {
                        FoodInventory foodInventory =
                            await fetchUserInventory();
                        foodInventory.shareAccess(user.uid,
                            _nameController.text); //bool for success/fail
                      },
                      child: Text('Invite'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 50), //width, height
                        textStyle: TextStyle(
                          fontSize: 18,
                        ),
                        foregroundColor:
                            Colors.green[900], //foreground changes text color
                        backgroundColor: Colors.green[50],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
