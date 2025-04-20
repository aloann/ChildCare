import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor_home.dart';  // Import DoctorHomePage
import 'mother_home.dart';  // Import MotherHomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // Check login credentials
  void handleLogin() async {
    setState(() {
      isLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Default login credentials
    if ((email == 'doctor' && password == 'doctor') || (email == 'mom' && password == 'mom')) {
      // Store the login state in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);  // Save email (doctor or mother)

      // Navigate to the correct screen
      if (email == 'doctor') {
        // Navigate to Doctor's Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DoctorHomePage()),
        );
      } else {
        // Navigate to Mother's Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MotherHomePage()),
        );
      }
    } else {
      // Handle invalid login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل الدخول'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Baby carriage image
              Image.asset('assets/images/baby_carriage.png', width: 80, height: 80),
              const SizedBox(height: 20),

              // Email field
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                ),
              ),
              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                ),
              ),
              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleLogin,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تسجيل الدخول'),
                ),
              ),
              const SizedBox(height: 12),

              // Register link
              TextButton(
                onPressed: () {
                  // TODO: Navigate to mother registration screen
                },
                child: const Text('تسجيل حساب جديد للأم'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}