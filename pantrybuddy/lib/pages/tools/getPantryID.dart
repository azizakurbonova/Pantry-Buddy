import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// This PROBABLY NEEDS FIXING! Please let me (CHRIS) know if there's an error
Future<String> fetchPantryID() async {
  final user = FirebaseAuth.instance.currentUser!;
  String userId = user.uid;
  final snapshot =
      await FirebaseDatabase.instance.ref("users/$userId/inventoryID").get();
  final inventoryID = snapshot.value.toString();
  return inventoryID;
}
