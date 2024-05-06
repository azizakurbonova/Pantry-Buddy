import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/auth/auth_page.dart';
import 'package:pantrybuddy/auth/main_page.dart';
//import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/account_page_v2.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/dc_inventory_page.dart';
import 'package:pantrybuddy/reg/login_page.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Widget sideBar(BuildContext context) {
  return Drawer(
    child: Container(
      color: Colors.green[400],
      child: ListView(
        children: [
          ListTile(
            // each page is a ListTitle
            leading: Icon(Icons.account_box, color: Colors.black),
            title: Text(
              "Account",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            onTap: () async {
              try {
                FoodInventory pantry = await fetchPantry();
                bool inventoryIDExists = (pantry.owner != "Null");
                String? userID = FirebaseAuth.instance.currentUser?.uid;
                bool isOwner = pantry.owner == userID;

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AccountPageV2(
                        userID: userID,
                        isOwner: isOwner,
                        inventoryIDExists: inventoryIDExists)));
              } catch (e) {
                // Handle exception if any error during fetching pantry
                print("Error fetching pantry: $e");
                // Optionally, navigate to an error page or show a message
              }
            },
          ),
          ListTile(
            // each page is a ListTitle
            leading: Icon(Icons.food_bank, color: Colors.black),
            title: Text(
              "Inventory",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => InventoryPage()));
            },
          ),
          ListTile(
            //replace with discarded inventory
            // each page is a ListTitle
            leading: Icon(Icons.remove_circle, color: Colors.black),
            title: Text(
              "Consumed/Discarded",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DCInventoryPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.black),
            title: Text(
              "Sign Out",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MainPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    ),
  );
}
