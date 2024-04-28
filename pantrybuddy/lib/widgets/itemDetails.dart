import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/Inventory_page.dart';
import 'package:pantrybuddy/scripts/fetchUserInventory.dart';
import 'package:pantrybuddy/widgets/itemNameTextField.dart';
import 'package:pantrybuddy/widgets/itemQuantityTextField.dart';

class ItemDetails extends StatefulWidget {
  final GroceryItem food;
  const ItemDetails({required this.food, super.key}) : super();

  @override
  _ItemDetailsState createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  final dbRef = FirebaseDatabase.instance.ref();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.food.name;
    _quantityController.text = widget.food.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF2D3447),
        appBar: AppBar(
            title: const Text('Food Details',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w100)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.info, color: Colors.white),
                onPressed: () {},
              )
            ]),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Name:",
                  style: TextStyle(fontSize: 25.0, color: Colors.white)),
              ItemNameTextField(
                nameController: _nameController,
              ),
              const Divider(),
              const Text(
                'Quantity:',
                style: TextStyle(fontSize: 25.0, color: Colors.white),
              ),
              ItemQuantityTextField(quantityController: _quantityController),
              Divider(),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> updateItem = {};
                      updateItem['quantity'] = _quantityController.text;

                      //db
                      //    .collection('Users')
                      //    .doc(uid)
                      //    .collection(widget.food['location'])
                      //    .doc(widget.food.itemId)
                      //    .update({'quantity': _quantityController.text});
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return InventoryPage();
                      }));
                    },
                    child: const Text('Save'),
                  ),
                  //IMPLEMENT THIS LATER!!
                  //ElevatedButton(
                  //  color: Colors.red,
                  //  textColor: Colors.white,
                  //  onPressed: () async {
                  //    final uid = await getCurrentUID();
                  //    db
                  //        .collection('Users')
                  //        .doc(uid)
                  //        .collection(widget.food['location'])
                  //        .doc(widget.food.id)
                  //        .delete();
                  //    Navigator.of(context).pushReplacement(
                  //        MaterialPageRoute(builder: (context) {
                  //      return AppHome();
                  //    }));
                  //  },
                  //  child: const Text('Delete'),
                  //),
                ],
              ),
            ]),
          ),
        ));
  }
}
