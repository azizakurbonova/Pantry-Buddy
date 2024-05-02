//import 'dart:html';

import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pantrybuddy/item.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_database/firebase_database.dart';

class NewInventoryPage extends StatefulWidget {
  const NewInventoryPage({Key? key}) : super(key: key);

  @override
  State<NewInventoryPage> createState() => _NewInventoryPageState();
}

class _NewInventoryPageState extends State<NewInventoryPage> {
  final user = FirebaseAuth.instance.currentUser!;

  // 2) From joincode, get FoodInventory
  //List of items to be displayed, consisting of STRINGS
  List _items = [];
  // 3) Retrieve all items from FoodInventory, quantity + name in string format

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Future retrieveData() async {
    List<dynamic> _items = [];
    String userID = user.uid;

    // to do:
    // Need to update this so it updates automatically on event changes

    // 1) From user id, query for joincode
    final readCode = FirebaseDatabase.instance.ref();
    final joincode = await readCode.child('users/$userID/joinCode').get();

    // 2) From joincode, get FoodInventoryID
    final foodInventoryID =
        await readCode.child('foodInventories/$joincode/inventoryId').get();

    // 3) Get foodInventory, get items in Alphabetical Format
    final itemsObjects = FirebaseDatabase.instance
        .ref()
        .child('FoodInventory/inventoryId/$foodInventoryID')
        .orderByKey()
        .get();

    // itemsObjects is a query!!!!!!

    // {Process itemsObjects into strings (Quantity + Name)
    return _items;
  }

  @override
  Widget build(BuildContext context) {
    _items = retrieveData() as List;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return MyItem(
                  child: _items[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
