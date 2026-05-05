import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'features/home/home_provider.dart';
import 'features/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BarberCaveApp());
}

class BarberCaveApp extends StatelessWidget {
  const BarberCaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MaterialApp(
        title: 'Barber Cave',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000000),
          fontFamily: 'SF Pro Display',
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFC107),
            surface: Color(0xFF1C1C1E),
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
