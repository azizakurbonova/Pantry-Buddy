import 'package:flutter/material.dart';

class GroceryNameField extends StatefulWidget {
  const GroceryNameField({
    required TextEditingController nameController,
  })  : _nameController = nameController,
        super();

  final TextEditingController _nameController;

  @override
  _FoodNameTextFieldState createState() => _FoodNameTextFieldState();
}

class _FoodNameTextFieldState extends State<GroceryNameField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget._nameController,
          textAlign: TextAlign.center,
          cursorColor: Colors.white,
          decoration: const InputDecoration(
              hintText: "Mushrooms, Chicken,...",
              hintStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white30,
                  fontSize: 20.0),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))),
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ],
    );
  }
}
