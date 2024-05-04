import 'package:flutter/material.dart';
import "package:pantrybuddy/foodEntry/utility/AUTO.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import "package:pantrybuddy/models/grocery_item.dart";
import 'package:pantrybuddy/models/food_inventory.dart';
import "package:pantrybuddy/foodEntry/utility/suggest_expiration.dart";
import 'package:pantrybuddy/models/spoonacular.dart';
import 'package:flutter/cupertino.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'dart:developer';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:flutter/services.dart';

//The user will select to search between products, ingredients, and menu items
//Simply because the endpoints are separate and there is no way to
//combine results

enum SearchType { products, ingredients, menuItems }

class AutoSearchForm extends StatefulWidget {
  const AutoSearchForm({Key? key}) : super(key: key);
  @override
  State<AutoSearchForm> createState() => _AutoSearchFormState();
}

class _AutoSearchFormState extends State<AutoSearchForm> {
  SearchType _selectedSearchType = SearchType.products;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<Spoonacular> _searchResults = [];
  DateTime? expirationDate;
  GroceryItem? selectedGroceryItem;

  final user = FirebaseAuth.instance.currentUser!;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedSearchType = SearchType.products;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search Food Items'),
        ),
        body: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSegmentedControl<SearchType>(
              children: const {
                SearchType.products: Text('Products'),
                SearchType.ingredients: Text('Ingredients'),
                SearchType.menuItems: Text('Menu Items'),
              },
              onValueChanged: (SearchType value) {
                setState(() {
                  _selectedSearchType = value;
                  // Clears previous results when switching search types
                  _searchResults.clear();
                  _searchController.clear();
                });
              },
              groupValue: _selectedSearchType,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults.clear();
                    });
                  },
                ),
              ),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  _search(text);
                } else {
                  setState(() {
                    _searchResults.clear();
                  });
                }
              },
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (BuildContext context, int index) {
              final result = _searchResults[index];
              return ListTile(
                title: Text(result.name),
                subtitle: Text('ID: ${result.id}'),
                onTap: () => showAddToPantryDialog(context, result),
              );
            },
          ))
        ]));
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

  Future<void> _addGroceryItem(
      BuildContext context, Spoonacular suggestion) async {
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

    GroceryItem? item;
    switch (_selectedSearchType) {
      case SearchType.products:
        item = await idSearch_products(
            suggestion.id, pantryID, expirationDate!, quantity);
        break;
      case SearchType.ingredients:
        item = await idSearch_ingredients(
            suggestion.id, pantryID, expirationDate!, quantity);
        break;
      case SearchType.menuItems:
        item = await idSearch_menuItems(
            suggestion.id, pantryID, expirationDate!, quantity);
        break;
    }

    if (item != null) {
      try {
        FoodInventory pantry = await fetchPantry();
        String pantryID =
            pantry.inventoryId as String; // Ensure pantryID is not null
        log("length before" + pantry.groceryItems.length.toString());
        pantry.appendGroceryItem(item);
        log("length after" + pantry.groceryItems.length.toString());
        dbRef.child("foodInventories/$pantryID").update(pantry.toJson());
      } catch (e) {
        debugPrint("Error adding item to pantry: $e");
      }
    } else {
      debugPrint("Failed to create grocery item from API data.");
    }

    _quantityController.clear();
  }

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    List<Spoonacular> results;
    switch (_selectedSearchType) {
      case SearchType.products:
        results = await autocompleteSearch_products(query);
        break;
      case SearchType.ingredients:
        results = await autocompleteSearch_ingredients(query);
        break;
      case SearchType.menuItems:
        results = await autocompleteSearch_menuItems(query);
        break;
    }

    setState(() {
      _searchResults = results;
    });
  }

  Future<void> showAddToPantryDialog(
      BuildContext context, Spoonacular selectedResult) async {
    // Validate inputs before proceeding
    bool isValid() {
      return _quantityController.text.isNotEmpty && expirationDate != null;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add to Pantry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  errorText: _quantityController.text.isEmpty
                      ? 'Quantity is required'
                      : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter
                      .digitsOnly, // Only allows digits to be entered
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    errorMessage = 'Quantity is required';
                    return errorMessage;
                  }
                  final n = int.tryParse(value);
                  if (n == null || n <= 0) {
                    errorMessage = 'Please enter a valid positive number';
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
              FutureBuilder<String>(
                  future: suggestExpiration_Auto(
                      selectedResult.name, _selectedSearchType),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(snapshot.data ??
                          "No expiration guideline available.");
                    } else {
                      return const CircularProgressIndicator();
                    }
                  })
            ],
          ),
          actions: [
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
                if (isValid()) {
                  _addGroceryItem(context, selectedResult);
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
              child: const Text('Add to Inventory'),
            ),
          ],
        );
      },
    );
  }
}
