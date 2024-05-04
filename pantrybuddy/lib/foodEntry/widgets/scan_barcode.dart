import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/foodEntry/utility/UPC.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'dart:developer';

//Stateful Widget, calling scanAndFetchProduct() from upc_ean to initiate
//barcode scanning process, generates the JSON map for Grocery Item,
//quantity and expiration date needs to be updated with manual input from user

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({Key? key}) : super(key: key);
  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  GroceryItem? currentGroceryItem;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser!;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Scan Barcode"),
      content: Form(
        key: GlobalKey<FormState>(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildFormFields(context),
          ),
        ),
      ),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildFormFields(BuildContext context) {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      appBar: AppBar(
        title: const Text('Scan Grocery Item'),
      ),
      body: Column(
        children: [
          if (currentGroceryItem != null) ...[
            Text('Scanned Item: ${currentGroceryItem!.name}'),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              // Optional: Add validation for input
            ),
            TextField(
                controller:
                    _dateController, //editing controller of this TextField
                decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today), //icon of text field
                    labelText: "Enter Expiration Date", //label text of field,
                    errorText: _dateController.text.isEmpty
                        ? 'Expiration date is required'
                        : null,
                    labelStyle: TextStyle(color: Colors.black)),
                readOnly: true, // when true user cannot edit text
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), //get today's date
                      firstDate: DateTime
                          .now(), //DateTime.now() - not to allow to choose before today.
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 25)));

                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(
                        pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                    debugPrint(
                        formattedDate); //formatted date output using intl package =>  2022-07-04

                    setState(() {
                      _dateController.text =
                          formattedDate; //set foratted date to TextField value.
                    });
                  } else {
                    debugPrint("Date is not selected");
                  }
                }),
            // Additional UI elements as needed
          ],
          ElevatedButton(
            //scan UPC/EAN barcode
            onPressed: () async => await scanAndAddProduct(),
            child: const Text('Scan Product'),
          ),
        ],
      ),
    );
  }

  Future<void> scanAndAddProduct() async {
    final DateTime expirationDate = _dateController.text.isNotEmpty
        ? DateTime.parse(_dateController.text)
        : DateTime.now();

    final int quantity = _quantityController.text.isNotEmpty
        ? int.parse(_quantityController.text)
        : 1;

    FoodInventory pantry = await fetchPantry();
    String pantryID = pantry.inventoryId as String;

    GroceryItem? newItem = await scanAndFetchProduct();

    try {
      log("length before" + pantry.groceryItems.length.toString());
      pantry.appendGroceryItem(newItem!);
      log("length after" + pantry.groceryItems.length.toString());
      dbRef.child("foodInventories/$pantryID").update(pantry.toJson());
    } catch (e) {
      debugPrint("Error adding item to pantry: $e");
    }

    _quantityController.clear();
    _dateController.clear();
  }

  //to avoid memory leak, dispose of quantityController
  @override
  void dispose() {
    _quantityController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
