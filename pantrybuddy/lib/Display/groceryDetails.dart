import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/Display/groceryNameField.dart';
import 'package:pantrybuddy/Display/groceryQuantityField.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'dart:developer';
import 'package:pantrybuddy/Display/groceryDescription.dart';

class ItemDetails extends StatefulWidget {
  final GroceryItem item;
  ItemDetails({required this.item}) : super();

  @override
  _FoodDetailsState createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<ItemDetails> {
  final dbRef = FirebaseDatabase.instance.ref();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _quantityController.text = widget.item.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF2D3447),
        appBar: AppBar(
            title: Text('Item Details',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w100)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.info, color: Colors.white),
                onPressed: () {},
              )
            ]),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Name:",
                  style: TextStyle(fontSize: 25.0, color: Colors.white)),
              GroceryNameField(
                nameController: _nameController,
              ),
              Divider(),
              Text(
                'Quantity:',
                style: TextStyle(fontSize: 25.0, color: Colors.white),
              ),
              GroceryQuantityField(quantityController: _quantityController),
              Divider(),
              //Column(
              //  children: [
              //    ElevatedButton(
              //      onPressed: () async {
              //        final uid = await getCurrentUID();
              //        db
              //            .collection('Users')
              //            .doc(uid)
              //            .collection(widget.food['location'])
              //            .doc(widget.food.id)
              //            .update({'quantity': _quantityController.text});
              //        Navigator.of(context).pushReplacement(
              //            MaterialPageRoute(builder: (context) {
              //          return AppHome();
              //        }));
              //      },
              //      child: const Text('Save'),
              //    ),
              //    ElevatedButton(
              //      color: Colors.red,
              //      textColor: Colors.white,
              //      onPressed: () async {
              //        final uid = await getCurrentUID();
              //        db
              //            .collection('Users')
              //            .doc(uid)
              //            .collection(widget.food['location'])
              //            .doc(widget.food.id)
              //            .delete();
              //        Navigator.of(context).pushReplacement(
              //            MaterialPageRoute(builder: (context) {
              //          return AppHome();
              //        }));
              //      },
              //      child: const Text('Delete'),
              //    ),
              //  ],
              //),
            ]),
          ),
        ));
  }
}
