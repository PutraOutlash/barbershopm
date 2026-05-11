import 'package:flutter/material.dart';
// Pastikan path import ini sesuai dengan lokasi file user_model.dart Anda
import '../models/user_model.dart';

class TestModelPage extends StatelessWidget {
  const TestModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test User Model'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          onPressed: () {
            // 1. Kita buat Data Dummy (Seolah-olah ini balasan dari API Laravel)
            Map<String, dynamic> dataJsonDariApi = {
              "id": "1",
              "name": "Aladdinnn",
              "username": "4laddin_dev",
              "email": "aladdin_hi@exsample.com",
              "role": "user",
            };

            // 2. Kita masukkan data mentah tersebut ke dalam "Cetakan" UserModel
            UserModel userKita = UserModel.fromJson(dataJsonDariApi);

            // 3. Kita cek hasilnya dengan mencetaknya di Terminal (Debug Console)
            print("=== HASIL TEST USER MODEL ===");
            print("Nama User : ${userKita.name}");
            print("Username  : ${userKita.username}");
            print("Email     : ${userKita.email}");
            print("Role      : ${userKita.role}");
            print("=============================");
          },
          child: const Text(
            'Jalankan Test Print',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
