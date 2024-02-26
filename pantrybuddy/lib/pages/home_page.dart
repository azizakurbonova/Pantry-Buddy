import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/Account_page.dart';
import 'package:pantrybuddy/pages/Inventory_page.dart';
import 'package:pantrybuddy/pages/Notification_pages.dart';
import 'package:pantrybuddy/pages/create_pantry_page.dart';
import 'package:pantrybuddy/pages/join_pantry_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green[100],
        appBar: AppBar(
          backgroundColor: Colors.green[400],
          elevation: 0, // how flat do we want this
          title: Text("Top Bar"),
        ),
        endDrawer: Drawer(
          child: Container(
            color: Colors.green[400],
            child: ListView(
              children: [
                ListTile(
                  // each page is a ListTitle
                  leading: Icon(Icons.account_box),
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
                  leading: Icon(Icons.notifications),
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
                  leading: Icon(Icons.food_bank),
                  title: Text(
                    "Inventory **",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => InventoryPage()));
                  },
                ),
                ListTile(
                    leading: Icon(Icons.logout),
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
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                height: 300,
                width: 300,
                child: Image.asset('lib/images/fridgey.png')),
            Padding(
              padding: EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Padding(padding: EdgeInsets.only(left: 10)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green[800],
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CreatePantryPage()));
                    },
                    child: Text(
                      "Create Pantry",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green[800],
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => JoinPantryPage()));
                    },
                    child: Text(
                      "Join Pantry",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ]),

          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text('signed in as ' + user.email!),
          //     MaterialButton(
          //       onPressed: () {
          //         FirebaseAuth.instance.signOut();
          //       },
          //       color: Colors.green[300],
          //       child: Text('Sign Out'),
          //     ),
          //     Container()
          //   ],

          // ),
        ));
  }
}
