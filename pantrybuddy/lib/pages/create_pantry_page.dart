import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/widgets/appbar.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';

class CreatePantryPage extends StatefulWidget {
  const CreatePantryPage({Key? key}) : super(key: key);

  @override
  State<CreatePantryPage> createState() => _CreatePantryPageState();
}

class _CreatePantryPageState extends State<CreatePantryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final database = FirebaseDatabase.instance.ref();

  void createPantry() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final pantry = FoodInventory(
        owner: userId,
        users: [userId], // Current user is added as owner and user
        groceryItems: [],
      );
      final reference = FirebaseDatabase.instance.ref().child('foodInventories');
      final newPantry = reference.push();
      newPantry.set(pantry.toJson());
      final userRef = FirebaseDatabase.instance.ref().child('users').child(userId);
      userRef.update({'pantry': newPantry.key});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: ApplicationToolbar(),
      endDrawer: sideBar(context),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: GestureDetector(
            onTap: () {
              createPantry();
            },
            child: Container(
              padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                color: Colors.purple[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )),
              ),
            ),
          )),
        ],
      )),
    );
  }
}
