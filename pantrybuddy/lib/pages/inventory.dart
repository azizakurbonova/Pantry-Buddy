import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/widgets/itemList.dart';
import 'package:pantrybuddy/widgets/sidebar.dart';
import 'package:pantrybuddy/widgets/item.dart';

class Inventory extends StatefulWidget {
  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Color(0xFF2D3447),
        appBar: AppBar(
          title: const Text("Pantry",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.w100)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              SearchBar(),
              SizedBox(height: screenHeight * 0.02),
              Expanded(child: Container(child: ItemList(context))),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewItemName(Item: newItem)));
            },
            child: Icon(Icons.add, color: Color(0xFF2D3447), size: 30.0),
            backgroundColor: Colors.white));
  }
}
