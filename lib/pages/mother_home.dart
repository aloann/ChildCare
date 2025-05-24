import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'child_list_mom.dart';
import 'appointments_mother.dart';
import 'smart_assistant.dart';

class MotherHomePage extends StatelessWidget {
  const MotherHomePage({super.key});

  // Logout function
  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية للأم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            ChildCareMenuButton(
              text: 'قائمة أولادي',
              icon: Icons.list_alt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChildListMomPage()),
                );
              },
            ),
            const SizedBox(height: 8),
            ChildCareMenuButton(
              text: 'المواعيد القادمة',
              icon: Icons.calendar_today, // Using calendar icon for appointments
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppointmentsMotherPage()),
                );
              },
            ),
            const SizedBox(height: 8),
            ChildCareMenuButton(
              text: 'المساعد الذكي',
              icon: Icons.smart_toy,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SmartAssistantPage()),

                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChildCareMenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const ChildCareMenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: Colors.pinkAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}