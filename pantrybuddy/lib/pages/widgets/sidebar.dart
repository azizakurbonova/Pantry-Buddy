import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/reg/login_page.dart';

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
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AccountPage()));
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
          ListTile( //replace with discarded inventory
            // each page is a ListTitle
            leading: Icon(Icons.remove_circle, color: Colors.black),
            title: Text(
              "Consumed/Discarded",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
          ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text(
                "Sign Out",
                style: TextStyle(fontSize: 20, color: Colors.black),
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
  );
}
