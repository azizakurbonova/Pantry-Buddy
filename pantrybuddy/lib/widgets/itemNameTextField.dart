import 'package:flutter/material.dart';

class ItemNameTextField extends StatefulWidget {
  const ItemNameTextField({
    super.key,
    required TextEditingController nameController,
  }) : _nameController = nameController;

  final TextEditingController _nameController;

  @override
  _ItemNameTextFieldState createState() => _ItemNameTextFieldState();
}

class _ItemNameTextFieldState extends State<ItemNameTextField> {
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
