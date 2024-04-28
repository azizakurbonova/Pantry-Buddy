import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';

Widget sideBar(BuildContext context) {
  return Drawer(
    child: Container(
      color: Colors.green[400],
      child: sideBarHelper(context),
    ),
  );
}

Widget sideBarHelper(BuildContext context) {
  return ListView(
    children: [
      ListTile(
        leading: const Icon(Icons.account_box),
        title: const Text(
          "Account",
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AccountPage()));
        },
      ),
      ListTile(
        leading: const Icon(Icons.notifications),
        title: const Text(
          "Notifications",
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const NotificationPage()));
        },
      ),
      ListTile(
        leading: const Icon(Icons.food_bank),
        title: const Text(
          "Inventory",
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const InventoryPage()));
        },
      ),
      ListTile(
          leading: const Icon(Icons.logout),
          title: const Text(
            "Sign Out",
            style: TextStyle(fontSize: 20),
          ),
          onTap: () {
            FirebaseAuth.instance.signOut();
          }),
    ],
  );
}
