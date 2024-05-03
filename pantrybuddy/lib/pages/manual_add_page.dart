import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';

class ManualAddPage extends StatefulWidget {
  final FoodInventory? userInventory;
  const ManualAddPage({Key? key, this.userInventory}) : super(key: key);

  @override
  State<ManualAddPage> createState() => _ManualAddPageState();
}

class _ManualAddPageState extends State<ManualAddPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  late FoodInventory userInventory;

  @override
  void initState() {
    super.initState();
    // Fetch the user's inventory when the widget is initialized
    fetchPantry().then((inventory) {
      setState(() {
        userInventory = inventory;
      });
    }).catchError((error) {
      // Handle errors if any
      debugPrint('Error fetching user inventory in initializing: $error');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  final List<String> categoryList = [
    'Fruit',
    'Vegetable',
    'Grain',
    'Protein',
    'Dairy',
    'Other',
  ];
  String? selectedCat;
  final List<int> quantityList = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
  ];
  int? selectedQuantity;
  final List<int> monthList = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
  ];
  int? selectedMonth;
  final List<int> dayList = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31
  ];
  int? selectedDay;
  final List<int> yearList = [
    //this year and up to seven years in future
    DateTime.now().year, DateTime.now().year + 1, DateTime.now().year + 2,
    DateTime.now().year + 3,
    DateTime.now().year + 4, DateTime.now().year + 5, DateTime.now().year + 6,
    DateTime.now().year + 7,
  ];
  int? selectedYear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 0,
        //title: Text("Top Bar"),
      ),
      //drawer. pulls out on top right
      endDrawer: sideBar(context),

      //body

      backgroundColor: Colors.green[200],
      body: SafeArea(
        child: Form(
          key: _formKey, //can use for validation
          child: Center(
            child: SingleChildScrollView(
              //fixes enter text overflow
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Manual Item Entry",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 15),

                  //name
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Item Name',
                          fillColor: Colors.grey[100],
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  //category
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: DropdownButtonFormField<String>(
                        value: selectedCat,
                        onChanged: (value) {
                          setState(() {
                            selectedCat = value;
                          });
                        },
                        items: categoryList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: 'Category',
                          fillColor: Colors.grey[100],
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select the category';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  //quantity
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: DropdownButtonFormField<int>(
                        value: selectedQuantity,
                        onChanged: (value) {
                          setState(() {
                            selectedQuantity = value;
                          });
                        },
                        items: quantityList.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: 'Quantity',
                          fillColor: Colors.grey[100],
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select the quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  //expiration date, row of three boxes within column
                  const SizedBox(
                    child: Text(
                      "Enter expiration date:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        //month
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: DropdownButtonFormField<int>(
                            value: selectedMonth,
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value;
                              });
                            },
                            items: monthList.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              hintText: 'Month',
                              fillColor: Colors.grey[100],
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.green),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Select month';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        //day
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: DropdownButtonFormField<int>(
                            value: selectedDay,
                            onChanged: (value) {
                              setState(() {
                                selectedDay = value;
                              });
                            },
                            items: dayList.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              hintText: 'Day',
                              fillColor: Colors.grey[100],
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.green),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Select day';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        //year
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: DropdownButtonFormField<int>(
                            value: selectedYear,
                            onChanged: (value) {
                              setState(() {
                                selectedYear = value;
                              });
                            },
                            items: yearList.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              hintText: 'Year',
                              fillColor: Colors.grey[100],
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.green),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Select year';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  //SUBMIT BUTTON
                  const SizedBox(height: 35),
                  ElevatedButton(
                      onPressed: () async {
                        FoodInventory pantry = await fetchPantry();
                        String pantryID = pantry.inventoryId as String;
                        //log("Attempting to fetch user inventory");
                        //FoodInventory pantry = await fetchPantry();
                        //log("Successful fetch");
                        //String inventoryId = pantry.inventoryId!;
                        //GroceryItem newGrocery = GroceryItem(
                        //    name: _nameController.text,
                        //    category: [selectedCat!],
                        //    dateAdded: DateTime.now(),
                        //    expirationDate: DateTime(
                        //        selectedYear!, selectedMonth!, selectedDay!),
                        //    itemIdType: ItemIdType.MANUAL);
                        //final Map<String, Map> groceryUpdates = {};
                        //groceryUpdates['foodInventories/$inventoryId'] =
                        //    newGrocery.toJson();
                        //FirebaseDatabase.instance.ref().update(groceryUpdates);
                        //log(pantry.groceryItems.toString());
                      },
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(120, 50), //width, height
                        textStyle: TextStyle(
                          fontSize: 18,
                        ),
                        foregroundColor:
                            Colors.green[900], //foreground changes text color
                        backgroundColor: Colors.green[50],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
