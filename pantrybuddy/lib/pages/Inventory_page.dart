import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? myUserID = FirebaseAuth.instance.currentUser!.uid;

  String code = 'n/a';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference getCode =
        FirebaseDatabase.instance.ref().child('users/$myUserID/inventoryID');
    getCode.onValue.listen((event) {
      setState(() {
        code = event.snapshot.value.toString();
      });
    });

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
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => InventoryPage()));
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
                  }),
            ],
          ),
        ),
      ),

      //speed dial for add methods
      floatingActionButton: SpeedDial(
        //animatedIcon: AnimatedIcons.menu_close,
        icon: Icons.add,
        backgroundColor: Colors.green[400],
        overlayColor: Colors.black,
        //background greys out when opened. helps focus on options
        overlayOpacity: .4,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add_box),
            label: 'Manual Entry',
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ManualAddPage()));
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.barcode_reader),
            label: 'Scan (UPC/EAN)',
          ),
          SpeedDialChild(
            child: Icon(Icons.add_a_photo),
            label: 'Photo (PLU)',
          ),
        ],
      ),

      //body
      backgroundColor: Colors.green[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            //fixes enter text overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  "This is your Pantry Code!: $code",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                //stretch so can left align
                const SizedBox(height: 15),
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    "      show grocery items here",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    /* for category boxes
                //other
                Padding (
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 14.0),
                  child: GestureDetector (
                    //onTap: widget.showFullInventoryPage,
                    child: Container (
                      padding: const EdgeInsets.all(20),
                      height: 120,
                      decoration: BoxDecoration (
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center (
                        child: Text (
                          'Other',
                          style: TextStyle (
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                        ),
                      ),
                    ),
                  )
                ),
                */
  }
}
