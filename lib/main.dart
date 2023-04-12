import 'package:flutter/material.dart';
import 'package:minhas_viagens/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Minhas viagens",
    home: SplashScreen(),
  ));
}
