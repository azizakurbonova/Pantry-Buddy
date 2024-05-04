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
import 'package:intl/intl.dart';

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
  final TextEditingController _dateController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser!;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

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
            children: _buildFormFields(context),
          ),
        ),
      ),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildFormFields(BuildContext context) {
    bool isProductNameRequired = (selectedNameAll == "N/A" ||
        (','.allMatches(selectedNameAll!).length >
            1)); //if product type is N/A or is a list of items

    //product name is optional field except required in certain cases

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
        validator: (value) =>
            value == null || value.isEmpty ? "Category is required" : null,
        decoration: InputDecoration(
          labelText: "Select Category",
          errorText: selectedCategory == null ? 'Category is required' : null,
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
          validator: (value) => value == null || value.isEmpty
              ? "Product type is required"
              : null,
          decoration: InputDecoration(
            labelText: "Select Product Type",
            errorText:
                selectedNameAll == null ? "Product type is required" : null,
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          ),
        ),
      ],
      SizedBox(height: 20),
      TextFormField(
        controller: productNameController,
        decoration: InputDecoration(
            labelText: 'Product Name',
            hintText: 'Enter product name',
            errorText:
                isProductNameRequired ? 'Product name is required' : null,
            labelStyle: TextStyle(color: Colors.black)),
      ),
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
          controller: _dateController, //editing controller of this TextField
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
                lastDate: DateTime.now().add(const Duration(days: 365 * 25)));

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
      SizedBox(height: 10),
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

  List<Widget> _buildActions(BuildContext context) {
    bool isProductNameRequired = (selectedNameAll! == "N/A" ||
        (','.allMatches(selectedNameAll!).length > 1));

    bool isValid = _dateController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        (int.parse(_quantityController.text) > 0) &&
        (isProductNameRequired && productNameController.text.isNotEmpty) &&
        (selectedNameAll != null) &&
        (selectedCategory != null);
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
          if (isValid) {
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
                  content: const Text(
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
    ];
  }

  Future<void> addEntry(BuildContext context) async {
    String itemName = productNameController.text.isNotEmpty
        ? productNameController.text
        : selectedNameAll!;
    String category = selectedCategory ??
        "Uncategorized"; // Default category if none selected

    final DateTime expirationDate = _dateController.text.isNotEmpty
        ? DateTime.parse(_dateController.text)
        : DateTime.now();

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
        image: "");

    try {
      log("length before" + pantry.groceryItems.length.toString());
      pantry.appendGroceryItem(newItem);
      log("length after" + pantry.groceryItems.length.toString());
      dbRef.child("foodInventories/$pantryID").update(pantry.toJson());
    } catch (e) {
      debugPrint("Error adding item to pantry: $e");
    }

    _quantityController.clear();
    _dateController.clear();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _quantityController.dispose();
    productNameController.dispose();
    _dateController.dispose();
    selectedCategory = null;
    selectedNameAll = null;
    super.dispose();
  }
}
