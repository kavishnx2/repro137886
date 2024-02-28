import 'package:flutter/material.dart';
import 'package:repro137886/pages/selectionPage.dart'; // Import the selection page

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SelectionPage(), // Start with the SelectionPage
    );
  }
}
