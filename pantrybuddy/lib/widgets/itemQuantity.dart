import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/widgets/itemDescription.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/widgets/itemNameField.dart';

Widget itemQuantity(
    BuildContext context, TextEditingController quantityController) {
  return TextFormField(
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
    ],
    controller: quantityController,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    cursorColor: Colors.white,
    decoration: const InputDecoration(
        hintText: "Enter quantity",
        hintStyle: TextStyle(
            fontStyle: FontStyle.italic, color: Colors.white30, fontSize: 20.0),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
    style: const TextStyle(color: Colors.white, fontSize: 20.0),
  );
}
