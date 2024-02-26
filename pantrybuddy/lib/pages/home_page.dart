import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/Account_page.dart';
import 'package:pantrybuddy/pages/Inventory_page.dart';
import 'package:pantrybuddy/pages/Notification_pages.dart';

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
        appBar: AppBar(
          backgroundColor: Colors.green[400],
          elevation: 0, // how flat do we want this
          title: const Text("Top Bar"),
        ),
        endDrawer: Drawer(
          child: Container(
            color: Colors.green[400],
            child: ListView(
              children: [
                ListTile(
                  // each page is a ListTitle
                  leading: const Icon(Icons.account_box),
                  title: const Text(
                    "Account",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AccountPage()));
                  },
                ),
                ListTile(
                  // each page is a ListTitle
                  leading: const Icon(Icons.notifications),
                  title: const Text(
                    "Notifications",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const NotificationPage()));
                  },
                ),
                ListTile(
                  // each page is a ListTitle
                  leading: const Icon(Icons.food_bank),
                  title: const Text(
                    "Inventory",
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const InventoryPage()));
                  },
                ),
                ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text(
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
            child: Column(
              children: [
                ElevatedButton(
                  
                  onPressed: (){} , 
                  child: const Text("Create Pantry"),
                  ),


                ElevatedButton(
                  
                  onPressed: (){} , 
                  child: const Text("Join Pantry?"),
                  ),  
              ]

              
              ),



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
