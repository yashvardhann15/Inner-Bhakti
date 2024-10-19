import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/program_details_screen.dart';
import 'screens/player_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inner Bhakti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/programDetails': (context) => ProgramDetailsScreen(),
        '/player': (context) => PlayerScreen(),
      },
    );
  }
}