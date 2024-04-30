import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/pages/account_page.dart';
import 'package:pantrybuddy/pages/notif_page.dart';
import 'package:pantrybuddy/pages/inventory_page.dart';
import 'package:pantrybuddy/widgets/itemDescription.dart';
import 'package:pantrybuddy/widgets/itemDetails.dart';

Widget itemCard(BuildContext context, GroceryItem grocery) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Card(
        color: grocery.expirationDate.day - DateTime.now().day < 0
            ? Colors.red[200]
            : Colors.white,
        child: InkWell(
          child: Container(
              height: 90,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Container(
                          child: Image(
                              image: AssetImage('assets/images/groceries.png'),
                              height: 50.0),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: itemDescription(context, grocery))
                  ],
                ),
              )),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => itemDetails(context, grocery)));
          },
        ),
      ));
}
