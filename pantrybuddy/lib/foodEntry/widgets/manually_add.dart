import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:pantrybuddy/foodEntry/utility/MANUAL.dart";
import "package:pantrybuddy/models/grocery_item.dart";
import 'package:pantrybuddy/models/food_inventory.dart';
import "package:pantrybuddy/foodEntry/utility/suggest_expiration.dart";
import "package:pantrybuddy/foodEntry/utility/csv.dart";
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'dart:developer';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:flutter/services.dart';

class ManualEntryForm extends StatefulWidget {
  const ManualEntryForm({Key? key}) : super(key: key);

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
  TextEditingController productNameController =
      TextEditingController(); //product name if dropdown is N/A
  DateTime? expirationDate;

  final user = FirebaseAuth.instance.currentUser!;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    List<List<dynamic>> csvData = await loadCsv('assets/foodKeeper.csv');
    List<Map<String, dynamic>> expirations = parseCsv(csvData);

    var dropdownData = await prepareDropdownData(expirations);
    setState(() {
      categoryNames = dropdownData['Category_Name'];
      nameAllOptions = dropdownData['Name_ALL'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Item to Pantry"),
      content: Form(
        key: GlobalKey<FormState>(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildFormFields(),
          ),
        ),
      ),
      actions: _buildActions(),
    );
  }

  List<Widget> _buildFormFields() {
    bool isProductNameEnabled = true;

    return [
      DropdownButtonFormField<String>(
        value: selectedCategory,
        onChanged: (value) {
          setState(() {
            selectedCategory = value;
            selectedNameAllOptions = nameAllOptions[value] ?? [];
            selectedNameAll = null; // Reset when L1 changes
          });
        },
        items: categoryNames.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            errorMessage = "Category is required";
            return errorMessage;
          }
          errorMessage = null;
          return errorMessage;
        },
        decoration: InputDecoration(
          labelText: "Select Category",
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
      SizedBox(height: 20),
      if (selectedCategory != null && selectedCategory != "N/A") ...[
        DropdownButtonFormField<String>(
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
              }).toList() ??
              [],
          validator: (value) {
            if (value == null || value.isEmpty) {
              errorMessage = "Product type is required";
              return errorMessage;
            }
            errorMessage = null;
            return errorMessage;
          },
          decoration: InputDecoration(
            labelText: "Select Product Type",
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          ),
        ),
      ],
      SizedBox(height: 20),
      TextFormField(
        controller: productNameController,
        enabled: isProductNameEnabled,
        decoration: InputDecoration(
          labelText: 'Product Name',
          hintText: 'Enter product name',
        ),
        validator: (value) {
          if (isProductNameEnabled && (value == null || value.isEmpty)) {
            errorMessage = 'Product name is required';
            return errorMessage;
          }
          errorMessage = null;
          return errorMessage;
        },
      ),
      SizedBox(height: 20),
      TextFormField(
        controller: _quantityController,
        decoration: InputDecoration(
          labelText: 'Quantity',
          errorText:
              _quantityController.text.isEmpty ? 'Quantity is required' : null,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter
              .digitsOnly, // Only allows digits to be entered
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            errorMessage = 'Please enter a quantity';
            return errorMessage;
          }
          final n = int.tryParse(value);
          if (n == null || n <= 0) {
            errorMessage = 'Please enter a valid positive whole number';
            return errorMessage;
          }
          errorMessage = null;
          return errorMessage;
        },
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => setExpirationDate(context),
        child: const Text('Set Expiration Date'),
      ),
      SizedBox(height: 10),
      if (expirationDate != null)
        Text('Selected date: ${expirationDate!.toLocal()}'),
      expirationDate == null
          ? Text("Expiration date is required",
              style: TextStyle(color: Colors.red))
          : Text('Selected date: ${expirationDate!.toLocal()}'),
      if (selectedNameAll != null && selectedNameAll != "N/A") ...[
        FutureBuilder<String>(
          future: suggestExpiration_Manual(selectedNameAll!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(
                  snapshot.data ?? "No expiration guideline available.");
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        SizedBox(height: 10)
      ]
    ];
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: () => {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return InventoryPage();
          }))
        },
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          if (expirationDate != null &&
              (GlobalKey<FormState>().currentState?.validate() ?? false)) {
            addEntry();
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
                  content: Text(errorMessage!),
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
        child: const Text('Add to Pantry'),
      ),
    ];
  }

  Future<void> setExpirationDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 365 * 5)), // Set a range up to five years
    );

    if (pickedDate != null) {
      setState(() {
        expirationDate = pickedDate;
      });
    } else {
      debugPrint('Expiration date not set.');
    }
  }

  Future<void> addEntry() async {
    String itemName = productNameController.text;
    String category = selectedCategory ??
        "Uncategorized"; // Default category if none selected

    await setExpirationDate(context);

    if (expirationDate == null) {
      debugPrint('Expiration date is required');
      return;
    }

    final int quantity = _quantityController.text.isNotEmpty
        ? int.parse(_quantityController.text)
        : 1;

    FoodInventory pantry = await fetchPantry();
    String pantryID = pantry.inventoryId as String;

    GroceryItem newItem = GroceryItem(
      inventoryID: pantryID,
      name: itemName,
      category: [category.toString()],
      quantity: quantity,
      dateAdded: DateTime.now(),
      expirationDate: expirationDate!,
      itemIdType: ItemIdType.MANUAL,
      visible: true,
    );

    try {
      FoodInventory pantry = await fetchPantry();
      String pantryID =
          pantry.inventoryId as String; // Ensure pantryID is not null
      log("length before" + pantry.groceryItems.length.toString());
      pantry.appendGroceryItem(newItem);
      log("length after" + pantry.groceryItems.length.toString());
      dbRef.child("foodInventories/$pantryID").update(pantry.toJson());
    } catch (e) {
      debugPrint("Error adding item to pantry: $e");
    }

    _quantityController.clear();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _quantityController.dispose();
    productNameController.dispose();
    super.dispose();
  }
}
