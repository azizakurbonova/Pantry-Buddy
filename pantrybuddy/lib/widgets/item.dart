import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/grocery_item.dart';
import 'package:pantrybuddy/widgets/itemDescription.dart';
import 'package:pantrybuddy/widgets/itemDetails.dart';

class Item extends StatelessWidget {
  GroceryItem food;
  Item({super.key, required this.food});

  bool isExpired() {
    if (food.expirationDate.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Card(
          color: isExpired() ? Colors.red[200] : Colors.white,
          child: InkWell(
            child: SizedBox(
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: ItemDescription(food: food))
                    ],
                  ),
                )),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemDetails(
                            food: food,
                          )));
            },
          ),
        ));
  }
}
