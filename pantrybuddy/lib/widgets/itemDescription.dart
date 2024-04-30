import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/grocery_item.dart';

enum QuantityType { individuals, bags, boxes, bundles, bottles }

<<<<<<< Updated upstream
class ItemDescription extends StatelessWidget {
  final GroceryItem food;
  const ItemDescription({super.key, required this.food});

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
                Text(food.name,
                    style: const TextStyle(
                        fontSize: 15.0,
                        color: Color(0xFF2D3447),
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text((food.quantity.toString()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15.0, color: Color(0xFF2D3447))),
                Text(
                    '${'Best before:'} ${food.expirationDate.toIso8601String().substring(0, 10)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15.0, color: Color(0xFF2D3447))),
                Text('${'Use in:'} ${daysUntilExpiration(food)} ${'days'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15.0, color: Color(0xFF2D3447))),
              ],
            ))
      ],
    );
  }
}

int daysUntilExpiration(GroceryItem food) {
  return (food.expirationDate.day - DateTime.now().day);
=======
Widget itemDescription(BuildContext context, GroceryItem grocery) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(grocery.name,
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Color(0xFF2D3447),
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text('${(grocery.quantity.toString())}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.0, color: Color(0xFF2D3447))),
              Text('${'Best before:'} ${grocery.expirationDate}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.0, color: Color(0xFF2D3447))),
              Text('${'Use in:'} ${daysUntilExpiration(grocery)} ${'days'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.0, color: Color(0xFF2D3447))),
            ],
          ))
    ],
  );
}

int daysUntilExpiration(GroceryItem grocery) {
  return (grocery.expirationDate.difference(DateTime.now()).inDays) + 1;
>>>>>>> Stashed changes
}
