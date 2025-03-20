import 'package:flutter/material.dart';
import 'package:myfinance/Authentication/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}
