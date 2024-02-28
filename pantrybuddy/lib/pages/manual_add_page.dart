import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';

class ManualAddPage extends StatefulWidget {
  const ManualAddPage({Key? key}) : super(key: key);

  @override
  State<ManualAddPage> createState() => _ManualAddPageState();
}

class _ManualAddPageState extends State<ManualAddPage> {
  final user = FirebaseAuth.instance.currentUser!;

  //itemID?
  final _nameController = TextEditingController();
  //category is buttons
  //use parse to get to int
  final _quantityController = TextEditingController();
  final _expireDateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expireDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                leading: Icon(Icons.food_bank, color: Colors.black),
                title: Text(
                  "Inventory",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InventoryPage()));
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
                  }
              ),
            ],
          ),
        ),
      ),

      //body
      backgroundColor: Colors.green[200],
      body: SafeArea (
        child: Center (
          child: SingleChildScrollView ( //fixes enter text overflow
            child: Column (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //stretch so can left align
                const SizedBox(height:15),
                const SizedBox (
                  
                  width: double.infinity,
                  child: Text (
                    "      Manual Entry",
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 10),

                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField (
                    controller: _nameController,
                    decoration: InputDecoration (
                      enabledBorder: OutlineInputBorder (
                        borderSide: const BorderSide (color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder (
                        borderSide: const BorderSide (color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Item Name',
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),



              //ui and controllers for everything. buttons for category
              //when hit add item, direct to method that 
              //saves all data to create a grocery item to rt database





                
              ],
            ),
          ),
        ),
      
      
      
      
      
      ),
    );
  }
}