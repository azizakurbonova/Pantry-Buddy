import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/auth/auth_page.dart';
import '../pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pantrybuddy/Scripts/fetchInventoryID.dart';
import 'package:pantrybuddy/Scripts/getGroceryItem.dart';
import 'package:pantrybuddy/auth/main_page.dart';
import 'package:pantrybuddy/firebase_options.dart';
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
import 'package:pantrybuddy/Scripts/fetchFoodInventory.dart';
import 'package:pantrybuddy/widgets/sidebar.dart';

class MainPage extends StatefulWidget {
  List<GroceryItem> groceries;
  FoodInventory? pantry;
  String? inventoryID;
  MainPage(this.groceries, this.pantry, this.inventoryID, {Key? key})
      : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    log("=====Main_Page=====");
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance
                .authStateChanges(), //like JavaScript listener
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return HomePage();
              } else {
                return AuthPage();
              }
            }));
  }
}
