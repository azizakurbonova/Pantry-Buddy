import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'package:pantrybuddy/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => HomePage(),
      ));
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.edit,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'LOAD SCREEN',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
