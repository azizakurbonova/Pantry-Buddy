import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pantrybuddy/models/food_inventory.dart';
import 'package:pantrybuddy/pages/tools/getFoodInventory.dart';
import 'package:pantrybuddy/pages/widgets/sidebar.dart';
import 'package:fl_chart/fl_chart.dart';

class DCInventoryPage extends StatefulWidget {
  DCInventoryPage({Key? key}) : super(key: key);

  @override
  State<DCInventoryPage> createState() => _DCInventoryPageState();
}

class _DCInventoryPageState extends State<DCInventoryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  FoodInventory? inventory;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    inventory = await fetchPantry();
    setState((){}); //trigger rebuild
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        elevation: 0,
      ),
      endDrawer: sideBar(context),

      //body
      backgroundColor: Colors.green[200],
      body: inventory != null ?
      PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: inventory?.consumed.toDouble(),
            color: Colors.blue[400],
            title: 'Consumed: (${inventory?.consumed})',
            titleStyle: TextStyle(fontWeight: FontWeight.bold),
            radius: 160,
          ),
          PieChartSectionData(
            value: inventory?.discarded.toDouble(),
            color: Colors.red[400],
            title: 'Discarded: (${inventory?.discarded})',
            titleStyle: TextStyle(fontWeight: FontWeight.bold),
            radius:  160,
          ),
        ],
        ),
      ) : Container(),
    );
  }
}
