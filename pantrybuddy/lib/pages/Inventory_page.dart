// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryList.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';
import 'package:pantrybuddy/pages/widgets/appbar.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'dart:developer';
import 'package:pantrybuddy/foodEntry/widgets/scan_barcode.dart';
import 'package:pantrybuddy/foodEntry/widgets/manually_add.dart';
import 'package:pantrybuddy/foodEntry/widgets/auto_search.dart';
import 'package:pantrybuddy/foodEntry/utility/UPC.dart';

class InventoryPage extends StatefulWidget {
  InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? myUserID = FirebaseAuth.instance.currentUser!.uid;
  String code = 'n/a';
  late Future inventoryID;
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    inventoryID = getData();
    super.initState();
  }

  Future getData() async {
    return fetchPantryID();
  }

  String printLatestValue(String text) {
    return text;
  }

  List<GroceryItem> filterByName(List<GroceryItem> groceries) {
    List<GroceryItem> filteredList = [];
    for (int x = 0; x < groceries.length; x++) {
      if (groceries[x].name.contains(searchController.text)) {
        filteredList.add(groceries[x]);
      }
    }
    return filteredList;
  }

  List<GroceryItem> sortByExpirationDate(List<GroceryItem> groceries) {
    groceries.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    for (int x = 0; x < groceries.length; x++) {
      if (groceries[x].name == "dummy") {
        groceries.removeAt(x);
        break;
      }
    }
    //groceries.removeAt(0);
    return groceries;
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
      appBar: ApplicationToolbar(),
      endDrawer: sideBar(context),

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
            label: 'Manually Enter',
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ManualEntryForm()));
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.barcode_reader),
            label: 'Scan Barcode',
            onTap: () async {
              final barcode = await scanBarcode();
              if (barcode == null) {
                // Show a error dialog if not successful
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Error"),
                      content: const Text("Barcode scanning not successful"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) {
                              return InventoryPage();
                            })); // Dismiss the dialog
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
              if (barcode != 'Unknown' && barcode != '-1') {
                // If barcode is successfully scanned, navigate to the entry page
                final product = await fetchProductByUPC(barcode!);
                if (product != null &&
                    product['status'].toString() != "failure") {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          BarcodeEntryPage(barcode: barcode, product: product),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Product not found"),
                        content: const Text(
                            "We don't have this item in our database. Try another method of entry!"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) {
                                return InventoryPage();
                              })); // Dismiss the dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            },
          ),
          SpeedDialChild(
              child: Icon(Icons.search),
              label: 'Search for Item',
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AutoSearchForm()));
              }),
        ],
      ),

      //body
      backgroundColor: Colors.green[200],
      body: SafeArea(
          child: Column(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40.0)),
              child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    //log(searchController.text);
                  },
                  decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: "Search",
                      hintStyle: TextStyle(fontSize: 20.0),
                      icon: Icon(Icons.search),
                      border: InputBorder.none))),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Expanded(
            child: Container(
                child: StreamBuilder(
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
                                if (jsonData['groceryItems'] == null) {
                                  jsonData["groceryItems"] = [];
                                } else {
                                  for (var map in jsonData["groceryItems"]) {
                                    Map<String, dynamic> groceryJson = {};
                                    for (var key in map.keys) {
                                      //log("translating: ${key.toString()}->${map[key].toString()}");
                                      groceryJson[key.toString()] = map[key];
                                    }
                                    //if (groceryJson["visible"]) {
                                    //  groceryJsons.add(groceryJson);
                                    //}
                                    groceryJsons.add(groceryJson);
                                  }
                                  jsonData["groceryItems"] = groceryJsons;
                                }
                                FoodInventory pantry =
                                    FoodInventory.fromJson(jsonData);
                                //log(pantry.groceryItems.length.toString());
                                //If you're reading this i suffered for this :_:
                                return GroceryList(
                                    groceries: filterByName(
                                        sortByExpirationDate(
                                            pantry.groceryItems)));
                              }
                            });
                      }
                    }))),
      ])),
    );
  }
}
