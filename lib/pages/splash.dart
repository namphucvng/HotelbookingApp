import 'package:flutter/material.dart';
import 'dart:async';
import 'start.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
    State<SplashScreen> createState() => _SplashScreenState();
  }

  class _SplashScreenState extends State<SplashScreen> {
    @override
    void initState() {
      super.initState();
      Timer(const Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StartPage()),
        );
      });
    }

  @override 
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 181, 147, 239), // Đậm trên
              //Color(0xFFD9D9FF), // Nhạt dưới
              Color.fromARGB(255, 163, 163, 248),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 🌥️ Cloud 1 - top left
            Positioned(
              top: screenHeight * 0.28,
              left: screenWidth * 0.12,
              child: Icon(Icons.cloud, size: 28, color: Colors.white.withOpacity(0.85)),
            ),
            // 🌥️ Cloud 2 - top right, cao hơn logo
            Positioned(
              top: screenHeight * 0.26,
              right: screenWidth * 0.15,
              child: Icon(Icons.cloud, size: 26, color: Colors.white.withOpacity(0.8)),
            ),
            // 🌥️ Cloud 3 - dưới trái, xa logo
            Positioned(
              top: screenHeight * 0.43,
              left: screenWidth * 0.10,
              child: Icon(Icons.cloud, size: 24, color: Colors.white.withOpacity(0.75)),
            ),
            // 🌥️ Cloud 4 - dưới phải, lệch hẳn khỏi logo
            Positioned(
              top: screenHeight * 0.46,
              right: screenWidth * 0.08,
              child: Icon(Icons.cloud, size: 24, color: Colors.white.withOpacity(0.7)),
            ),

            // 🐳 Logo
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'images/logo3.png',
                    width: 240,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
