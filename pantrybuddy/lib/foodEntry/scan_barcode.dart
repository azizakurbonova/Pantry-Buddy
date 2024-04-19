import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/foodEntry/spoonacular_upc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Stateful Widget, calling scanAndFetchProduct() from upc_ean to initiate
//barcode scanning process, generates the JSON map for Grocery Item,
//quantity and expiration date needs to be updated with manual input from user

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner ({Key? key}) : super(key: key);
  @override

  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  GroceryItem? currentGroceryItem;
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ElevatedButton(
              onPressed: () async => await setExpirationDate(context),
              child: const Text('Set Expiration Date'),
            ),
            // Additional UI elements as needed
          ],
          ElevatedButton( //scan UPC/EAN barcode
            onPressed: () async => await scanAndAddProduct(),
            child: const Text('Scan Product'),
          ),
        ],
      ),
    );
  }

  Future<void> scanAndAddProduct() async {
    GroceryItem? item = await scanAndFetchProduct();

    if (item != null) {
      int quantity = int.tryParse(_quantityController.text) ?? 1; // Default to 1 if parsing fails
      
      // Write to groceryItems DB
      DatabaseReference ref = FirebaseDatabase.instance.ref("groceryItems");
      DatabaseReference newInventoryRef = ref.push();
      String? itemId = newInventoryRef.key;
      
      setState(() {
        currentGroceryItem = item;
        currentGroceryItem!.quantity = quantity; // Update quantity based on input
        currentGroceryItem!.itemId = itemId;
      });

      await ref.push().set(currentGroceryItem!.toJson());

      User? user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;

      if (user != null) {
      // Fetch inventoryId from user's database entry, field is "pantry"
      final DatabaseReference dbref = FirebaseDatabase.instance.ref('users');
      final DataSnapshot userSnapshot = await dbref.child("users/$user.uid/inventoryId").get();
      String pantry = userSnapshot.value.toString();

      FoodInventory inventoryManager = FoodInventory(
        owner : userId!,
        inventoryId : pantry
      );

      inventoryManager.addGroceryItem(currentGroceryItem!);
    }
      _quantityController.clear();
  }
}

  Future<void> setExpirationDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentGroceryItem?.expirationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 15), //last selectable date, 15 years from now
    );

    if (pickedDate != null) {
      setState(() {
        currentGroceryItem!.expirationDate = pickedDate;
      });
    }
  }

  //to avoid memory leak, dispose of quantityController
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}
