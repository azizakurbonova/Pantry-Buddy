import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/reg/login_page.dart';
//import 'package:pantrybuddy/pages/join_pantry_page.dart';

class CreatePantryPage extends StatefulWidget {
  const CreatePantryPage({Key? key}) : super(key: key);

  @override
  State<CreatePantryPage> createState() => _CreatePantryPageState();
}

class _CreatePantryPageState extends State<CreatePantryPage> {
  final user = FirebaseAuth.instance.currentUser!;

  final database = FirebaseDatabase.instance.ref();

  //String userID = user.uid.toString();

  @override
  Widget build(BuildContext context) {
    //final pantry = database.child('pantry');

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 0, // how flat do we want this
        title: Text("Top Bar"),
      ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.green[400],
          child: ListView(
            children: [
              ListTile(
                // each page is a ListTitle
                leading: Icon(Icons.account_box),
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
                leading: Icon(Icons.notifications),
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
                leading: Icon(Icons.food_bank),
                title: Text(
                  "Inventory **",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => InventoryPage()));
                },
              ),
              ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginPage(
                              showRegisterPage: () {},
                            )));
                  }),
            ],
          ),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Give your pantry a name!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              //controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Name',
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  String userID = user.uid;
                  // ".write": "auth != null && data.child('users').child(auth.uid).exists()",
                  //UPDATE DATABASE WITH NEW USER
                  // Successful registration
                  // if (userCredential.user != null) {
                  //   String userId = userCredential.user!.uid; // Get the user ID

                  // Here, you create a map or use your User model to represent user data
                  Map<String, dynamic> userData = {
                    "userId": user.uid,
                    "email": user.email,
                  };

                  // Update the Realtime Database with the new user's information
                  await FirebaseDatabase.instance
                      .ref("users/$userID")
                      .set(userData);

                  // await database.child('users').set({
                  //   //'title': "hari",
                  //   'userId': user.uid,
                  //   'email': user.email,
                  //   'isAnonymous': user.isAnonymous,
                  // });
                  print("stuff has been written!");
                } catch (e) {
                  print('youve got error $e');
                }
              },
              child: Text('Add User')),
          ElevatedButton(
              onPressed: () async {
                try {
                  String userID = user.uid;

                  //FoodInventory pantry =
                  List<String> users = [user.uid];
                  List<GroceryItem> groceryItems = [];

                //const getTimeEpoch = () => {return new Date().getTime().toString()}
                  // ".write": "auth != null && data.child('users').child(auth.uid).exists()",
                  //UPDATE DATABASE WITH NEW USER
                  // Successful registration
                  // if (userCredential.user != null) {
                  //   String userId = userCredential.user!.uid; // Get the user ID

                  // Here, you create a map or use your User model to represent user data
                  Map<String, dynamic> foodInventoryData = {
                    "owner": user.uid,
                    "users": users,
                    "groceryItems": groceryItems,
                  };

                  // Update the Realtime Database with the new user's information
                  await FirebaseDatabase.instance
                      .ref("foodInventories/$userID")
                      .set(foodInventoryData);

                  //FirebaseDatabase.instance.ref

                  // await database.child('users').set({
                  //   //'title': "hari",
                  //   'userId': user.uid,
                  //   'email': user.email,
                  //   'isAnonymous': user.isAnonymous,
                  // });
                  print("stuff has been written!");
                } catch (e) {
                  print('youve got error $e');
                }
              },
              child: Text('Add FoodInventory')),
        ],
      )),
    );
  }
}
