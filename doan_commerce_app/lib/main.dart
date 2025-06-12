import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens/welcome_page.dart';
import 'screens/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile_page.dart';
import 'screens/cart_screen.dart';

//-----------------------------------------Vui lòng xem file Hướng dẫn setup để chạy code-------------------------------------------------
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-commerce App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: kTextColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomePage(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/cart': (context) => const ShoppingBagScreen(),
      },
    );
  }
}
