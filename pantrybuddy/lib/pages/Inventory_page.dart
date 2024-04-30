<<<<<<< Updated upstream
//import 'dart:html';
// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
=======
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Scripts/getGroceryItem.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/account_page.dart';
>>>>>>> Stashed changes
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_database/firebase_database.dart';
<<<<<<< Updated upstream
import 'package:pantrybuddy/widgets/sidebar.dart';
=======
import 'package:pantrybuddy/widgets/itemCard.dart';
import 'package:pantrybuddy/Scripts/fetchFoodInventory.dart';
import 'dart:developer';
import 'package:pantrybuddy/APIUtils.dart';
>>>>>>> Stashed changes

class InventoryPage extends StatefulWidget {
  dynamic data;
  InventoryPage(this.data, {Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? myUserID = FirebaseAuth.instance.currentUser!.uid;
  String code = 'n/a';
  List<GroceryItem> data = [];

  @override
  void dispose() {
    super.dispose();
  }

  Future retrieveData() async {
    List<GroceryItem> groceries = [];
    List<String> groceryIDs =
        (await fetchUserInventory()).groceryItems; //groceryIDs[0] is dumb
    log(groceryIDs.length.toString());
    for (String groceryID in groceryIDs) {
      log(groceryID);
    }
    return getGroceries(groceryIDs);
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
    List<GroceryItem> groceries = []; //HOW TO RETRIEVE??
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 0,
<<<<<<< Updated upstream
      ),
      endDrawer: sideBar(context),

      //+ Button on page, for adding things, DO NOT
=======
        actions: [
          IconButton(
            icon: const Icon(Icons.circle),
            tooltip: "Refresh",
            onPressed: () async {
              groceries = await retrieveData();
              log(groceries[1].name.toString());
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => InventoryPage(null)));
            },
          ),
        ],
        //title: Text("Top Bar"),
      ),
      //drawer. pulls out on top right
      endDrawer: Drawer(
        child: Container(
          color: Colors.green[400],
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.account_box, color: Colors.black),
                title: const Text(
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
                      builder: (context) => InventoryPage(null)));
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
      //speed dial for add methods
>>>>>>> Stashed changes
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

      //body
      backgroundColor: Colors.green[200],
      body: Container(
        child: StreamBuilder(
            stream: getGroceryListStream(context),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Text('No food items');
              else {
                log(snapshot.hasData.toString());
              }
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.children.length,
                  itemBuilder: (BuildContext context, int index) =>
                      //itemCard(food: snapshot.data!.documents[index]));
                      Text(snapshot.data!.children.length.toString()));
            }),
      ),
    );
  }
}
