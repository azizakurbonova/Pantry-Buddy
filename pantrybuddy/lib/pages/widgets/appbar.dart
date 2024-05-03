import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/models/user.dart' as my_user;
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/pages/dc_inventory_page.dart';
import 'package:pantrybuddy/pages/create_pantry_page.dart';
import 'package:pantrybuddy/pages/join_pantry_page.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:uuid/uuid.dart';

class ApplicationToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green[400],
      elevation: 0,
      title: Text("Top Bar"),
      automaticallyImplyLeading: false,
      // Refresh Button
      // actions: [IconButton(
      //  onPressed: ,
      //  icon: Icon(Icons.circle))],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
