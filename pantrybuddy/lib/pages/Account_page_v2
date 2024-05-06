import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/home_page.dart';
import 'package:pantrybuddy/pages/join_pantry_page.dart';
import 'package:pantrybuddy/pages/create_pantry_page.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:pantrybuddy/pages/tools/getPantryID.dart';
import 'package:pantrybuddy/reg/forgot_pw_page.dart';
import 'package:pantrybuddy/reg/login_page.dart';
import 'package:pantrybuddy/auth/main_page.dart';

class AccountPageV2 extends StatefulWidget {
  final bool isOwner;
  final bool inventoryIDExists;
  final String? userID;
  const AccountPageV2({Key? key, required this.userID, required this.isOwner, required this.inventoryIDExists})
      : super(key: key);

  @override
  State<AccountPageV2> createState() => _AccountPageV2State();
}

class _AccountPageV2State extends State<AccountPageV2> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (widget.isOwner && widget.inventoryIDExists) ...[
            ElevatedButton(
              onPressed: () => deletePantry(),
              child: Text('Delete Pantry'),
            ),
            ElevatedButton(
              onPressed: () => showAccessDialog(context, true),
              child: Text('Share User Access'),
            ),
            ElevatedButton(
              onPressed: () => showAccessDialog(context, false),
              child: Text('Remove User Access'),
                ),
            ElevatedButton(
              onPressed: () => viewAccess(context, true),
              child: Text('View User Access'),
            ),
          ]
          else if (!widget.isOwner && widget.inventoryIDExists) ...[
            ElevatedButton(
              onPressed: () => leavePantry(),
              child: Text('Leave Pantry'),
            ),
          ],
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ForgotPasswordPage();
                  },
                ),
              );
            },
            child: Text('Change Password'),
          ),
          ElevatedButton(
            onPressed: () => deleteAccount(),
            child: Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> showAccessDialog(BuildContext context, bool isSharing) async {
    final TextEditingController _emailController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isSharing ? 'Share User Access' : 'Remove User Access'),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter user email',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  if (isSharing) {
                    shareUserAccess(_emailController.text);
                  } else {
                    removeUserAccess(_emailController.text);
                  }
                  Navigator.of(dialogContext).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> fetchUserEmails(List<String> userIds) async {
    FoodInventory pantry = await fetchPantry();
    List<String> shared = pantry.users as List<String>;

    DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
    List<String> emails = [];
    for (String item in shared) {
      DataSnapshot snapshot = await usersRef.child(item).child('email').get();
      if (snapshot.exists) {
        emails.add(snapshot.value.toString());
      }
    }
    return emails;
  }

  void viewAccess(BuildContext context, bool isOwner) async {
    if (!isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only the owner can view user access.")),
      );
      return;
    }
    FoodInventory pantry = await fetchPantry();
    if (pantry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No pantry found.")),
      );
      return;
    }
    List<String> userEmails = await fetchUserEmails(pantry.users);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("User Access"),
          content: SingleChildScrollView(
            child: ListBody(
              children: userEmails.map((email) => Text(email)).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  Future<void> deletePantry() async {
    final user = FirebaseAuth.instance.currentUser;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();


    FoodInventory pantry = await fetchPantry();
    String inventoryID = pantry.inventoryID as String;
    String owner = pantry.owner as String;
    List<String> users = pantry.users as List<String>;

    try {

      // Check if the current user is the owner of the pantry
      if (user != null && widget.userID == owner) {
        // Update all users' pantry field to null
        for (String user in users) {
          dbRef.child('users/$user').update({'inventoryID': "Null"});
        }

        // Update the current user's pantry field to null
        dbRef.child('users/${widget.userID}').update({'inventoryID': "Null"});

        // Remove the pantry from the Food Inventory database
        dbRef.child('foodInventories/$inventoryID').remove();

        // Confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("You have successfully left the pantry."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) {
                                return HomePage();
                              })); // Dismiss the dialog
                            }, //TO-DO: Need to add logic that when the user does not have pantry id (for users w/ share access), stay at join pantry page after logging in
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // If the current user is not the owner, handle accordingly
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("You do not have permission to delete this pantry."),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Dismiss the dialog
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle any errors that occur during the delete process
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to delete pantry: $e"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Dismiss the dialog
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> shareUserAccess(String userEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    String? ownerEmail = FirebaseAuth.instance.currentUser?.email;

    FoodInventory pantry = await fetchPantry();
    String inventoryID = pantry.inventoryID as String;
    String owner = pantry.owner as String;
    List<String> users = pantry.users as List<String>;

    if (user == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("You are not logged in."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (userEmail == ownerEmail){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("You cannot share access with yourself!"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    try {
      // Check if the current user is the owner of the pantry
      if (widget.userID != owner) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("You are not the owner of this pantry."),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      // Get the user to share with by their email
      Query query = dbRef.child('users').orderByChild('email').equalTo(userEmail);
      DataSnapshot userSnapshot = await query.get();

      if (userSnapshot.exists && userSnapshot.value != null) {
        Map userData = userSnapshot.value as Map;
        String userToShareID = userData.keys.first;

        Map userToShareData = userData[userToShareID];

        // Check if the user already belongs to any pantry
        if (userToShareData['inventoryID'] != null && userToShareData['inventoryID'] != "Null") {
          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("User already belongs to a pantry!"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }

        if (!users.contains(userToShareID)) {
          users.add(userToShareID);
          await dbRef.child('foodInventories/$inventoryID').update({'users': users});

          // Set the shared user's pantry field to this pantry ID
          await dbRef.child('users/$userToShareID').update({'inventoryID': inventoryID});
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Success"),
                content: const Text("Pantry access shared successfully"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("User already has access to this pantry"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("No user found with that email"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error sharing pantry access: $e");
    }
  }


  Future<void> removeUserAccess(String userEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    String? ownerEmail = FirebaseAuth.instance.currentUser?.email;

    FoodInventory pantry = await fetchPantry();
    String inventoryID = pantry.inventoryID as String;
    String owner = pantry.owner as String;
    List<String> users = pantry.users as List<String>;

    try {

      // Check if the current user is the owner of the pantry
      if (widget.userID != owner) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("You are not owner of this pantry"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      if (userEmail == ownerEmail){
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Please use delete pantry to remove yourself!"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      // Get the user to remove by their email
      Query query = dbRef.child('users').orderByChild('email').equalTo(userEmail);
      DataSnapshot userSnapshot = await query.get();

      if (userSnapshot.exists && userSnapshot.value != null) {
        Map userData = userSnapshot.value as Map;
        String userToRemoveID = userData.keys.first;

        users.remove(userToRemoveID);
        await dbRef.child('foodInventories/$inventoryID').update({'users': users});

        // Set the removed user's pantry field to null
        await dbRef.child('users/$userToRemoveID').update({'inventoryID': "Null"});
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("User access removed successfully"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("No user found with that email"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error removing user access: $e");
    }
  }



  Future<void> leavePantry() async {
    final user = FirebaseAuth.instance.currentUser;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    FoodInventory pantry = await fetchPantry();
    String inventoryID = pantry.inventoryID as String;
    String owner = pantry.owner as String;
    List<String> users = pantry.users as List<String>;

    if (user == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("You are not logged in."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      if (inventoryID == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("You do not belong to any pantry."),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Remove the user from the pantry users list
      users.remove(widget.userID);
      await dbRef.child('foodInventories/$inventoryID').update({'users': users});

      // Set the user's pantry field to null
      await dbRef.child('users/${widget.userID}').update({'inventoryID': "Null"});

      // Confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Success"),
            content: const Text("You have successfully left the pantry."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) {
                              return HomePage();
                            })); // Dismiss the dialog
                          }, //TO-DO: Need to add logic that when the user does not have pantry id, stay at join pantry page after logging in
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Error handling
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to leave the pantry: $e"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser!;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    FoodInventory pantry = await fetchPantry();
    String inventoryID = pantry.inventoryID as String;
    String owner = pantry.owner as String;
    List<String> users = pantry.users as List<String>;
    

    if (inventoryID != null && owner != "Null") {
      if (widget.userID == owner) {
        // Current user is the owner, remove pantry and set pantry field of all users to null
        for (String user in users) {
          dbRef.child('users/$user').update({'inventoryID': "Null"});
        }

        // Update the current user's pantry field to null
        dbRef.child('users/${widget.userID}').update({'inventoryID': "Null"});

        // Remove the pantry from the Food Inventory database
        dbRef.child('foodInventories/$inventoryID').remove();
      } else {
        // Current user is not the owner
        // Remove the user from the pantry users list
        users.remove(widget.userID);
        await dbRef.child('foodInventories/$inventoryID').update({'users': users});
      }
    }

    // Delete the user from the users database
    await dbRef.child("users/${widget.userID}").remove();

    // Sign out the user and redirect to the main page
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainPage()), (Route<dynamic> route) => false);
  }

}
