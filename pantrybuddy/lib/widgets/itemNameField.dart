import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/widgets/itemDescription.dart';
import 'package:pantrybuddy/models/grocery_item.dart';

Widget itemName(BuildContext context, TextEditingController nameController) {
  return Column(
    children: [
      TextField(
        controller: nameController,
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
