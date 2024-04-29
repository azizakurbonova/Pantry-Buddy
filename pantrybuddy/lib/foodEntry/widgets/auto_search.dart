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

//The user will select to search between products, ingredients, and menu items
//Simply because the endpoints are separate and there is no way to
//combine results

enum SearchType { products, ingredients, menuItems }

class AutoSearchForm extends StatefulWidget {
  const AutoSearchForm ({Key? key}) : super(key: key);
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
    body: Column(
      children: <Widget>[
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
                onTap: () async {
                  final selectedResult = result;
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Add to Pantry"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Set quantity and expiration date for ${selectedResult.name}."),
                            TextField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            ElevatedButton(
                              onPressed: () => setExpirationDate(context),
                              child: const Text('Set Expiration Date'),
                            ),
                            if (expirationDate != null)
                              Text('Selected date: ${expirationDate!.toLocal()}'),
                            ...[
                            FutureBuilder<String>(
                              future: suggestExpiration_Manual(selectedResult.name),
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
                          ]
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _addGroceryItem(context, selectedResult);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Add to Inventory'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}


  Future<void> setExpirationDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // Set a range up to five years
    );

    if (pickedDate != null) {
      setState(() {
        selectedGroceryItem!.expirationDate = pickedDate;
      });
    }
  }


  Future<void> _addGroceryItem(BuildContext context, Spoonacular suggestion) async {
    await setExpirationDate(context);

    GroceryItem? item;
    switch (_selectedSearchType) {
      case SearchType.products:
        item = await idSearch_products(suggestion.id);
        break;
      case SearchType.ingredients:
        item = await idSearch_ingredients(suggestion.id);
        break;
      case SearchType.menuItems:
        item = await idSearch_menuItems(suggestion.id);
        break;
    }

    if (item != null) {
      final int quantity = _quantityController.text.isNotEmpty ? int.parse(_quantityController.text) : 1;
      
      // Write to groceryItems DB
      DatabaseReference ref = FirebaseDatabase.instance.ref("groceryItems");
      DatabaseReference newInventoryRef = ref.push();
      String? itemId = newInventoryRef.key;
      
      setState(() {
        selectedGroceryItem = item;
        selectedGroceryItem!.quantity = quantity; // Update quantity based on input
        selectedGroceryItem!.itemId = itemId;
      });

      await ref.push().set(selectedGroceryItem!.toJson());

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

      inventoryManager.addGroceryItem(selectedGroceryItem!);
    }
      _quantityController.clear();
  }
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
}
