import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_fonts/google_fonts.dart";
import "home.dart";
import "login.dart";

class AndroidApp extends StatelessWidget {
  const AndroidApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: "Android",
      theme: ThemeData(
        textTheme: GoogleFonts.calistogaTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green, 
          primary: Colors.black,
        ),
        primaryColor: Colors.white,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}