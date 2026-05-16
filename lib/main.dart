import 'package:barber_app/features/barber/viewmodel/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:barber_app/features/auth/view/login_page.dart';// Import halaman login
import 'package:provider/provider.dart';

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
      // home: const TestModelPage(), //hanya buat test
    );
  }
}