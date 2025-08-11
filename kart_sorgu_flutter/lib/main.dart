import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/card_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Kart verilerini yükle
  await CardService.loadCards();
  
  runApp(const KartSorguApp());
}

class KartSorguApp extends StatelessWidget {
  const KartSorguApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kart Kime Ait',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthService.isLoggedIn() 
        ? const HomeScreen() 
        : const LoginScreen();
  }
}
