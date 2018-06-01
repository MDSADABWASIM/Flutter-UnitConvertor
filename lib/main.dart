import 'package:flutter/material.dart';
import 'package:udacity_project/CategoryScreen.dart';

void main() {
  runApp(new Unitconverter());
}

class Unitconverter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Alegreya',
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.grey[600],
            ),
        // This colors the [InputOutlineBorder] when it is selected
        primaryColor: Colors.grey[500],
        textSelectionHandleColor: Colors.green[500],
      ),
      home: CategoryScreen(),
    );
  }
}
