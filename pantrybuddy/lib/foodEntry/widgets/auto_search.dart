import 'package:flutter/material.dart';
import "package:pantrybuddy/foodEntry/utility/AUTO.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import "package:pantrybuddy/models/grocery_item.dart";
import 'package:pantrybuddy/models/food_inventory.dart';
import "package:pantrybuddy/foodEntry/utility/suggest_expiration.dart";
import 'package:pantrybuddy/models/spoonacular.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/cupertino.dart';

//The user will select to search between products, ingredients, and menu items
//Simply because the endpoints are separate and there is no way to
//combine results

enum SearchType { product, ingredient, menuItem }

class AutoSearchForm extends StatefulWidget {
  const AutoSearchForm ({Key? key}) : super(key: key);
  @override
  State<AutoSearchForm> createState() => _AutoSearchFormState();
}

class _AutoSearchFormState extends State<AutoSearchForm> {
  late SearchType _searchType;
  DateTime? _expirationDate;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchType = SearchType.product;
  }

@override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoSegmentedControl<SearchType>(
          children: const {
            SearchType.product: Text('Product'),
            SearchType.ingredient: Text('Ingredient'),
            SearchType.menuItem: Text('Menu Item'),
          },
          onValueChanged: (SearchType? value) {
            setState(() {
              _searchType = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        TypeAheadField<Spoonacular>(
          hideOnEmpty: false,
          hideOnLoading: true,
          debounceDuration: const Duration(milliseconds: 300),
          suggestionsCallback: (query) async {
            switch (_searchType) {
              case SearchType.product:
                return await autocompleteSearch_products(query);
              case SearchType.ingredient:
                return await autocompleteSearch_ingredients(query);
              case SearchType.menuItem:
                return await autocompleteSearch_menuItems(query);
              default:
                return [];
            }
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion.name),
            );
          },
          onSelected: (suggestion) {
            _quantityController.text = '';
            _addGroceryItem(context, suggestion);
          }
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _quantityController,
          decoration: const InputDecoration(labelText: 'Quantity'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final String query = _quantityController.text.trim();
            if (query.isNotEmpty) {
              switch (_searchType) {
                case SearchType.product:
                  _apiService.searchProducts(query).then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductSearchResultsPage(value, _addGroceryItem),
                      ),
                    );
                  });
                  break;
                case SearchType.ingredient:
                  _apiService.searchIngredients(query).then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            IngredientSearchResultsPage(value, _addGroceryItem),
                      ),
                    );
                  });
                  break;
                case SearchType.menuItem:
                  _apiService.searchMenuItems(query).then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MenuItemSearchResultsPage(value, _addGroceryItem),
                      ),
                    );
                  });
                  break;
              }
            }
          },
          child: const Text('Search'),
        ),
      ],
    );
  }

  Future<void> _setExpirationDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // Set a range up to five years
    );

    if (pickedDate != null) {
      setState(() {
        _expirationDate = pickedDate;
      });
    }
  }

  Future<void> _addGroceryItem(BuildContext context, Spoonacular suggestion) async {
    await _setExpirationDate(context);

    final int quantity = _quantityController.text.isNotEmpty ? int.parse(_quantityController.text) : 1;
    final GroceryItem groceryItem = GroceryItem(
      id: suggestion.id,
      name: suggestion.name,
      imageUrl: suggestion.imageUrl,
      expirationDate: _expirationDate,
      quantity: quantity,
      category: suggestion.category,
    );

    await FirebaseService().addGroceryItem(groceryItem);

    Navigator.pop(context);
  }

}
