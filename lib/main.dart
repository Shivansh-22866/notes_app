import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: AnimatedSplashScreen(
        splash: const SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_alt_rounded,
                size: 40,
                color: Colors.white,
              ),
              Text('Notes app', style: TextStyle(fontFamily: 'Archivo', fontWeight: FontWeight.bold, fontSize: 24,color: Colors.white)),
            ],
          ),
        ),
        nextScreen: const Home(),
        duration: 5,
        splashTransition: SplashTransition.fadeTransition,
        curve: Curves.easeIn,
        backgroundColor: const Color.fromARGB(255, 33, 33, 33),
      ),
    );
  }
}
