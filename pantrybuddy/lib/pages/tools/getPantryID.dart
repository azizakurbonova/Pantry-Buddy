import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Future<String> fetchPantryID() async {
  final user = FirebaseAuth.instance.currentUser!;
  String userId = user.uid;
  final snapshot =
      await FirebaseDatabase.instance.ref("users/$userId/inventoryID").get();
  final inventoryID = snapshot.value.toString();
  return inventoryID;
}
