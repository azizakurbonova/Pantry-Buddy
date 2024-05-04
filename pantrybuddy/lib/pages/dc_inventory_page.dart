import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryList.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:pantrybuddy/pages/dc_inventory_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'dart:developer';

class DCInventoryPage extends StatefulWidget {
  DCInventoryPage({Key? key}) : super(key: key);

  @override
  State<DCInventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<DCInventoryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? myUserID = FirebaseAuth.instance.currentUser!.uid;
  String code = 'n/a';
  late Future pantryID;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    pantryID = getData();
    super.initState();
  }

  Future getData() async {
    return fetchPantryID();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference getCode =
        FirebaseDatabase.instance.ref().child('users/$myUserID/inventoryID');
    getCode.onValue.listen((event) {
      setState(() {
        code = event.snapshot.value.toString();
      });
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 0,
        //title: Text("Top Bar"),
      ),
      endDrawer: sideBar(context),
/*
      //speed dial for add methods
      floatingActionButton: SpeedDial(
        //animatedIcon: AnimatedIcons.menu_close,
        icon: Icons.add,
        backgroundColor: Colors.green[400],
        overlayColor: Colors.black,
        //background greys out when opened. helps focus on options
        overlayOpacity: .4,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add_box),
            label: 'Manual Entry',
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ManualAddPage()));
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.barcode_reader),
            label: 'Scan (UPC/EAN)',
          ),
          SpeedDialChild(
            child: Icon(Icons.add_a_photo),
            label: 'Photo (PLU)',
          ),
        ],
      ),
*/

      //body
      backgroundColor: Colors.green[200],
      body: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref("users/$myUserID/inventoryID")
              .onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              //log("WE HAVE VALUES");
              var databaseEvent = snapshot.data!;
              var databaseSnapshot = databaseEvent.snapshot;
              String inventoryID = databaseSnapshot.value as String;
              return StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref("foodInventories/$inventoryID")
                      .onValue,
                  builder: (context, snapshot2) {
                    Map<String, dynamic> jsonData = {};
                    if (!snapshot2.hasData) {
                      return const CircularProgressIndicator();
                    } else {
                      var dbevent = snapshot2.data!;
                      var dbsnapshot = dbevent.snapshot;
                      for (var item in dbsnapshot.children) {
                        //log("TRYING TO TRANSLATE: ${item.key.toString()}->${item.value.toString()}");
                        jsonData[item.key.toString()] = item.value;
                      }
                      List<dynamic> groceryJsons = [];
                      for (var map in jsonData["groceryItems"]) {
                        Map<String, dynamic> groceryJson = {};
                        for (var key in map.keys) {
                          //log("translating: ${key.toString()}->${map[key].toString()}");
                          groceryJson[key.toString()] = map[key];
                        }
                        if (!groceryJson["visible"]) {
                          groceryJsons.add(groceryJson);
                        }
                      }
                      jsonData["groceryItems"] = groceryJsons;
                      FoodInventory pantry = FoodInventory.fromJson(jsonData);
                      return GroceryList(groceries: pantry.groceryItems);
                    }
                  });
            }
          }),

      //body: FutureBuilder(
      //    future: pantryID,
      //    builder: (context, snapshot) {
      //      switch (snapshot.connectionState) {
      //        case ConnectionState.none:
      //        //return Text("None");
      //        case ConnectionState.waiting:
      //        //return Text("Waiting");
      //        case ConnectionState.active:
      //          //return Text("Active");
      //          return CircularProgressIndicator();
      //        case ConnectionState.done:
      //          log(snapshot.data);
      //          return Text(snapshot.data);
      //      }
      //    }),
    );
  }
}
