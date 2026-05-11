import 'package:barber_app/features/barber/provider/home_provider.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'package:barber_app/features/auth/pages/login_page.dart';
=======
import 'package:barber_app/screens/login_page.dart'; // Import halaman login
import 'screens/test_model_page.dart';
>>>>>>> 4fe63f4c598d313e52a713346bff71e89b54eb91

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