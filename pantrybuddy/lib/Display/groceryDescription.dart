import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/grocery_item.dart';

enum QuantityType { individuals, bags, boxes, bundles, bottles }

class GroceryItemDescription extends StatelessWidget {
  final GroceryItem item;
  const GroceryItemDescription({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF2D3447),
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  //overflow: TextOverflow.ellipsis
                ),
                Text('Quantity: ${(item.quantity)}',
                    maxLines: 1,
                    //overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.0, color: Color(0xFF2D3447))),
                Text(
                    '${'Best before:'} ${item.expirationDate.toIso8601String().substring(0, 10)}',
                    maxLines: 1,
                    //overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.0,
                        color: Color.fromARGB(255, 45, 71, 55))),
                Text('${'Use in:'} ${daysUntilExpiration(item)} ${'days'}',
                    maxLines: 1,
                    //overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.0, color: Color(0xFF2D3447))),
              ],
            ))
      ],
    );
  }
}

int daysUntilExpiration(GroceryItem item) {
  return (item.expirationDate.difference(DateTime.now()).inDays + 1);
}
