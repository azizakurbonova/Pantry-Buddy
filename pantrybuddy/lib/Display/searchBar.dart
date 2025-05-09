import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/Inventory_page.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _searchController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(40.0)),
          child: TextField(
              controller: _searchController,
              onChanged: (text) {
                print(text);
              },
              decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Search",
                  hintStyle: TextStyle(fontSize: 20.0),
                  icon: Icon(Icons.search),
                  border: InputBorder.none))),
    );
  }
}
