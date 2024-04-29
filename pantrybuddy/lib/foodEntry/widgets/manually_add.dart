import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:pantrybuddy/foodEntry/utility/MANUAL.dart";
import "package:pantrybuddy/models/grocery_item.dart";
import 'package:pantrybuddy/models/food_inventory.dart';
import "package:pantrybuddy/foodEntry/utility/suggest_expiration.dart";
import 'package:path/path.dart' as path;
import 'dart:io';
import "package:pantrybuddy/foodEntry/utility/csv.dart";

class ManualEntryForm extends StatefulWidget {
  const ManualEntryForm ({Key? key}) : super(key: key);
  @override
  State<ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<ManualEntryForm> {
  List<String> categoryNames = [];
  Map<String, List<String>> nameAllOptions = {};
  String? selectedCategory;
  List<String>? selectedNameAllOptions;
  String? selectedNameAll;

  final TextEditingController _quantityController = TextEditingController();
  TextEditingController productNameController = TextEditingController(); //product name if dropdown is N/A
  DateTime? expirationDate;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // Load and parse the categories and expiration data from CSV files.
    var currDir= Directory.current.path;
    String filePath = path.join(currDir, 'lib', 'foodEntry','externalDB','foodKeeper.csv');

    final expirationData = await loadCsv(filePath);

    // Create lists of maps to hold the parsed data.
    List<Map<String, dynamic>> csvData = parseCsv(expirationData);

    var dropdownData = await prepareDropdownData(csvData);
    setState(() {
      categoryNames = dropdownData['Category_Name'];
      nameAllOptions = dropdownData['Name_ALL'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedCategory,
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
              selectedNameAllOptions = nameAllOptions[value];
              selectedNameAll = null; // Reset the L2 dropdown when L1 changes
            });
          },
        items: categoryNames.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        hint: const Text("Select a Category"),
      ),
      if (selectedCategory != null && selectedCategory != "N/A") ...[
        DropdownButton<String>(
          value: selectedNameAll,
          onChanged: (value) {
            setState(() {
              selectedNameAll = value;
            });
          },
          items: selectedNameAllOptions?.map((String name) {
            return DropdownMenuItem<String>(
              value: name,
              child: Text(name),
            );
          }).toList() ?? [],
          hint: const Text("Select Product"),
        ),
      ],
      TextField(
          controller: productNameController,
          decoration: InputDecoration(
            labelText: 'Product Name',
            enabled: selectedNameAll == "N/A" || selectedNameAll!.contains(', '),  // Enable only if selected product is N/A
      ),
      ),
      TextFormField(
        controller: _quantityController,
        decoration: const InputDecoration(labelText: 'Quantity'),
        keyboardType: TextInputType.number,
      ),
      ElevatedButton(
        onPressed: () => setExpirationDate(context),
        child: const Text('Set Expiration Date'),
      ),
      if (selectedNameAll != null && selectedNameAll != "N/A") ...[
        FutureBuilder<String>(
          future: suggestExpiration_Manual(selectedNameAll!),
          builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Text(snapshot.data ?? "No expiration guideline available.");
              } 
              else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ElevatedButton(
        onPressed: addEntry,
        child: const Text('Add to Pantry'),
      ),
      ],
    );
  }

  Future<void> setExpirationDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // Set a range up to five years
    );

    if (pickedDate != null) {
      setState(() {
        expirationDate = pickedDate;
      });
    }
  }

  Future<void> addEntry() async {
    String itemName = selectedNameAll != "N/A" && selectedNameAll != null ? selectedNameAll! : productNameController.text;
    int quantity = int.tryParse(_quantityController.text) ?? 1; // Default to 1 if parsing fails
    String category = selectedCategory ?? "Uncategorized";  // Default category if none selected

    if (expirationDate == null) {
      // Handle error - expiration date is required
      debugPrint("Expiration date must be set.");
      return;
    }

    // Write to groceryItems DB
    DatabaseReference ref = FirebaseDatabase.instance.ref("groceryItems");
    DatabaseReference newInventoryRef = ref.push();
    String? itemId = newInventoryRef.key;

    GroceryItem newItem = GroceryItem(
      itemId: itemId, // Assuming this is generated elsewhere or not needed at creation
      name: itemName,
      category: [category],
      quantity: quantity,
      dateAdded: DateTime.now(),
      expirationDate: expirationDate!,
      itemIdType: ItemIdType.MANUAL, // Example, adjust as needed
      visible: true,
    );

    await ref.push().set(newItem.toJson());

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

      inventoryManager.addGroceryItem(newItem);
    }

    debugPrint("Created Food Product: ${newItem.name}");

    _quantityController.clear();
    productNameController.clear();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _quantityController.dispose();
    productNameController.dispose();
    super.dispose();
  }

}