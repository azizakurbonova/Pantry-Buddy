import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroceryQuantityField extends StatelessWidget {
  const GroceryQuantityField({
    Key? key,
    required TextEditingController quantityController,
  })  : _quantityController = quantityController,
        super(key: key);

  final TextEditingController _quantityController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      controller: _quantityController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      cursorColor: Colors.black,
      decoration: const InputDecoration(
          hintText: "Enter quantity",
          hintStyle: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black,
              fontSize: 20.0),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
      style: const TextStyle(color: Colors.black, fontSize: 20.0),
    );
  }
}
