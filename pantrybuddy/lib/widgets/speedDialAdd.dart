import 'package:flutter/material.dart';
import 'package:pantrybuddy/pages/manual_add_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

Widget speedDialAdd(BuildContext context) {
  return SpeedDial(
    //animatedIcon: AnimatedIcons.menu_close,
    icon: Icons.add,
    backgroundColor: Colors.green[400],
    overlayColor: Colors.black,
    //background greys out when opened. helps focus on options
    overlayOpacity: .4,
    children: [
      SpeedDialChild(
        child: Icon(Icons.add_box),
        label: 'Manual Entry',
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ManualAddPage()));
        },
      ),
      SpeedDialChild(
        child: Icon(Icons.barcode_reader),
        label: 'Scan (UPC/EAN)',
      ),
      SpeedDialChild(
        child: Icon(Icons.add_a_photo),
        label: 'Photo (PLU)',
      ),
    ],
  );
}
