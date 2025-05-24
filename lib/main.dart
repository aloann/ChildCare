import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login.dart';
import 'pages/doctor_home.dart';
import 'pages/mother_home.dart';
import 'pages/admin_home.dart';
import 'pages/chatbot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ChildHealthApp());
}

class ChildHealthApp extends StatefulWidget {
  const ChildHealthApp({super.key});

  @override
  _ChildHealthAppState createState() => _ChildHealthAppState();
}

class _ChildHealthAppState extends State<ChildHealthApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
  }  Future<void> checkLogin() async {
    if (!mounted) return;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role != null && mounted) {
      if (role == 'doctor') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DoctorHomePage()),
        );
      } else if (role == 'mother') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MotherHomePage()),
        );
      } else if (role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/adminHome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دفتر صحة الطفل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        primaryColor: Colors.teal.shade700,
        scaffoldBackgroundColor: Colors.teal.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.teal.shade200,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade700,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.teal.shade700,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.teal.shade700,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.teal.shade700,
              width: 2,
            ),
          ),
          labelStyle: TextStyle(
            color: Colors.teal.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shadowColor: Colors.teal.shade100,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      // Add localization support here
      locale: const Locale('ar', ''),
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/adminHome': (context) => const AdminHomePage(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
      home: const LoginPage(),
    );
  }
}