import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:uuid/uuid.dart';

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
  //final DatabaseReference pantryDB = FirebaseDatabase.instance.ref().child("FoodInventory/inventoryId");

  Future<FoodInventory> fetchUserInventory() async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    try {
      DatabaseEvent event = await databaseReference
          .child('FoodInventory')
          .child(user.uid)
          .once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<String, dynamic>? inventoryData =
            snapshot.value as Map<String, dynamic>;
        return FoodInventory.fromJson(inventoryData ?? {});
      }
      debugPrint('Error fetching user inventory: data snapshot is null');
      return FoodInventory(
        inventoryId: '', owner: '', groceryItems: [], users: []);
    } catch (error) {
      debugPrint('Error fetching user inventory: $error');
      throw Exception('Failed to fetch user inventory due to error');
    }
  }
  late FoodInventory userInventory;

  @override
  void initState() {
    super.initState();
    // Fetch the user's inventory when the widget is initialized
    fetchUserInventory().then((inventory) {
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
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15,
  ];
  int? selectedQuantity; 

  final List<int> monthList = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12,
  ];
  int? selectedMonth; 

  final List<int> dayList = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
  ];
  int? selectedDay; 

  final List<int> yearList = [ //this year and up to seven years in future
    DateTime.now().year, DateTime.now().year+1, DateTime.now().year+2, DateTime.now().year+3, 
    DateTime.now().year+4, DateTime.now().year+5, DateTime.now().year+6, DateTime.now().year+7, 
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
      endDrawer: Drawer(
        child: Container(
          color: Colors.green[400],
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.account_box, color: Colors.black),
                title: Text(
                  "Account",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AccountPage()));
                },
              ),
              ListTile(
                // each page is a ListTitle
                leading: Icon(Icons.notifications, color: Colors.black),
                title: Text(
                  "Notifications",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NotificationPage()));
                },
              ),
              ListTile(
                // each page is a ListTitle
                leading: Icon(Icons.food_bank, color: Colors.black),
                title: Text(
                  "Inventory",
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InventoryPage()));
                },
              ),
              ListTile(
                  leading: Icon(Icons.logout, color: Colors.black),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  }
              ),
            ],
          ),
        ),
      ),

      //body

      backgroundColor: Colors.green[200],
      body: SafeArea (
        child: Form (
          key: _formKey, //can use for validation
          child: Center (
            child: SingleChildScrollView ( //fixes enter text overflow
              child: Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text (
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
                  child: Padding (
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField (
                      controller: _nameController,
                      validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                      decoration: InputDecoration (
                        enabledBorder: OutlineInputBorder (
                          borderSide: const BorderSide (color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder (
                          borderSide: const BorderSide (color: Colors.green),
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
                  const SizedBox (
                    child: Text(
                      "Enter expiration date:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox ( //month
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
                                return 'Select month';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox ( //day
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
                                return 'Select day';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox ( //year
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
                                return 'Select year';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  //submit button
                  const SizedBox(height:35),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        var uuid = Uuid(); //instance of Uuid class from uuid package
                        var uniqueId = uuid.v4(); //actually create unique id

                        GroceryItem newItem = GroceryItem(
                          itemId: uniqueId,
                          name: _nameController.text,
                          category: selectedCat!,
                          quantity: selectedQuantity!,
                          expirationDate: DateTime(selectedYear!, selectedMonth!, selectedDay!),
                          itemIdType: ItemIdType.Manual,
                        );
                        try {
                          userInventory!.addGroceryItem(newItem);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Item added successfully')),
                          );
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add item: $error')),
                          );
                        }

                        /*
                        var newItemRef = pantryDB.push();
                        var newItemId = newItemRef.key;
                        DateTime date = DateTime(selectedYear!, selectedMonth!, selectedDay!);
                        newItemRef.set({
                          'itemId': newItemId,
                          'name': _nameController.text,
                          'category': selectedCat!,
                          'quantity': selectedQuantity!,
                          //'expirationDate': DateTime.now(),
                          'expirationDate': date.millisecondsSinceEpoch,
                          'itemIdType': "Manual",
                        
                        }).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Form submitted successfully')),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit form: $error')),
                          );
                        });
                        */
                      }
                    },
                    
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(120, 50), //width, height
                      textStyle: TextStyle (
                        fontSize: 18,
                      ),
                      foregroundColor: Colors.green[900], //foreground changes text color
                      backgroundColor: Colors.green[50],
                    )
                  ),


                //ui and controllers for everything. buttons for category
                //when hit add item, direct to method that 
                //saves all data to create a grocery item to rt database
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}





/*
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical:16),
                      border: OutlineInputBorder (
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide (color: Colors.white),
                      ),
                    ),
                    hint: const Text (
                      'Select Category',
                      style: TextStyle(fontSize: 18),
                    ),
                    items: categoryList
                      .map((String item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text (
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ))
                      .toList(),
                    validator: (value) {
                      if (value==null) {
                        return 'Please select category.';
                      }
                      return null;
                    },
                    //onChanged: (value) {
                      //do something when selected item is changed?
                    //}
                    onSaved: (value) {
                      selectedCat = value.toString();
                    },
                    buttonStyleData: const ButtonStyleData (
                      padding: EdgeInsets.only(right: 8),
                    ),
                    iconStyleData: const IconStyleData (
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                      iconSize: 24,
                    ),
                    dropdownStyleData: DropdownStyleData (
                      decoration: BoxDecoration (
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black,
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData (
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
*/

/*
                  SizedBox (
                    width: 300,
                    child: Padding( 
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: DropdownMenu(
                        enableFilter: true,
                        dropdownMenuEntries: <DropdownMenuEntry<String>>[
                          DropdownMenuEntry(value: 'Fruit', label: 'Fruit'),
                          DropdownMenuEntry(value: 'Vegetable', label: 'Vegetable'),
                          DropdownMenuEntry(value: 'Grain', label: 'Grain'),
                          DropdownMenuEntry(value: 'Protein', label: 'Protein'),
                          DropdownMenuEntry(value: 'Dairy', label: 'Dairy'),
                          DropdownMenuEntry(value: 'Other', label: 'Other'),
                        ],
                        hintText: ("Category"),
                        inputDecorationTheme: InputDecorationTheme(
                          fillColor: Colors.grey[100],
                          filled: true,
                          enabledBorder: OutlineInputBorder (
                              borderSide: const BorderSide (color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder (
                              borderSide: const BorderSide (color: Colors.green),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
*/