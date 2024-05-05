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
import 'package:flutter/services.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';

class BarcodeEntryPage extends StatefulWidget {
  final String barcode;
  final product;
  BarcodeEntryPage({Key? key, required this.barcode, required this.product})
      : super(key: key);

  @override
  _BarcodeEntryPageState createState() => _BarcodeEntryPageState();
}

class _BarcodeEntryPageState extends State<BarcodeEntryPage> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _scannedProduct;

  @override
  void initState() {
    super.initState();
    _scannedProduct = widget.product!['title'].toString();
  }

  final user = FirebaseAuth.instance.currentUser!;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barcode Entry')),
      body: Column(
        children: [
          Text('Scanned Barcode: ${widget.barcode}'),
          SizedBox(height: 10),
          Text(
              'Product Name: ${_scannedProduct == null ? "Not Available" : _scannedProduct}'),
          SizedBox(height: 20),
          TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(
                labelText: 'Quantity',
                errorText: (_quantityController.text.isEmpty ||
                        int.parse(_quantityController.text) <= 0)
                    ? 'Quantity is required'
                    : null,
                labelStyle: TextStyle(color: Colors.black)),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter
                  .digitsOnly, // Only allows digits to be entered
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Quantity is required';
              }
              final n = int.tryParse(value);
              if (n == null || n <= 0) {
                return 'Please enter a valid positive number'; // Check for non-integer and non-positive values
              }
              return null; // Return null if the input is valid
            },
          ),
          SizedBox(height: 20),
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
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              if (_dateController.text.isNotEmpty &&
                  _quantityController.text.isNotEmpty &&
                  int.parse(_quantityController.text) > 0 &&
                  _scannedProduct != null) {
                addEntry(context);
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return InventoryPage();
                }));
              } else {
                // Show a dialog if the form is not valid
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Error"),
                      content: _scannedProduct == null
                          ? const Text("Product information not found")
                          : const Text(
                              "Please fill all required fields and set an expiration date."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Dismiss the dialog
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> addEntry(BuildContext context) async {
    final DateTime expirationDate = _dateController.text.isNotEmpty
        ? DateTime.parse(_dateController.text)
        : DateTime.now();

    final int quantity = _quantityController.text.isNotEmpty
        ? int.parse(_quantityController.text)
        : 1;

    FoodInventory pantry = await fetchPantry();
    String pantryID = pantry.inventoryId as String;

    GroceryItem? newItem = createGroceryItemFromSpoonacular(
        widget.product, pantryID, expirationDate, quantity);

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
