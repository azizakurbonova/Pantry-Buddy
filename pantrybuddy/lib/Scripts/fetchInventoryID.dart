import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pantrybuddy/models/food_inventory.dart';

Future<String> fetchInventoryID() async {
  // THIS WILL RETURN Null IF USER EXISTS, BUT DOESN'T HAVE A PANTRY YET!!!
  final user = FirebaseAuth.instance.currentUser!;
  final userId = user.uid;

  final snapshot =
      await FirebaseDatabase.instance.ref("users/$userId/inventoryID").get();

  final inventoryID = snapshot.value.toString();
  return inventoryID;
}
