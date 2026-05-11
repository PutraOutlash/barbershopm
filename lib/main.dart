import 'package:barber_app/features/barber/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_app/features/auth/pages/login_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barber App',
      home: const LoginPage(),
    );
  }
}