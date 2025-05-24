// ignore_for_file: unused_import


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AppointmentsMotherPage extends StatefulWidget {
  const AppointmentsMotherPage({super.key});

  @override
  State<AppointmentsMotherPage> createState() => _AppointmentsMotherPageState();
}

class _AppointmentsMotherPageState extends State<AppointmentsMotherPage> {
  String? motherEmail;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      motherEmail = prefs.getString('email');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قادم المواعيد')),
      body: motherEmail == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('children')
                  .where('motherMail', isEqualTo: motherEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('لا توجد مواعيد قادمة.'));
                }

                final now = DateTime.now();
                final children = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final next = data['nextAppointment'];
                  return next != null;
                }).toList();

                return ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    final data = child.data() as Map<String, dynamic>;
                    final name = '${data['LName'] ?? ''} ${data['name'] ?? ''}';
                    final nextAppointment = (data['nextAppointment'] as Timestamp).toDate();

                    final daysDifference = nextAppointment.difference(now).inDays;
                    final isToday = daysDifference == 0;
                    final isTomorrow = daysDifference == 1;

                    Color buttonColor = Colors.grey[300]!;
                    if (isTomorrow) {
                      buttonColor = Colors.amber;
                      // TODO: Send local notification if not already sent.
                    } else if (isToday) {
                      buttonColor = Colors.green;
                    }

                    return Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        onPressed: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الموعد: ${DateFormat('yyyy-MM-dd').format(nextAppointment)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('الطفل: $name'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}