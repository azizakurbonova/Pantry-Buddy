import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
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
import 'package:pantrybuddy/Display/groceryDescription.dart';
>>>>>>> 65a911b4d274c56dc357ccfd7b94507dd0d347aa

class GroceryNameField extends StatefulWidget {
  const GroceryNameField({
    required TextEditingController nameController,
  })  : _nameController = nameController,
        super();

  final TextEditingController _nameController;

  @override
  _FoodNameTextFieldState createState() => _FoodNameTextFieldState();
}

class _FoodNameTextFieldState extends State<GroceryNameField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget._nameController,
          textAlign: TextAlign.center,
          cursorColor: Colors.white,
          decoration: const InputDecoration(
              hintText: "Mushrooms, Chicken,...",
              hintStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white30,
                  fontSize: 20.0),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))),
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ],
    );
  }
}
