import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewChildPage extends StatefulWidget {
  final String childId;

  const ViewChildPage({Key? key, required this.childId}) : super(key: key);

  @override
  _ViewChildPageState createState() => _ViewChildPageState();
}

class _ViewChildPageState extends State<ViewChildPage> {
  Map<String, dynamic>? childData;

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('children')
        .doc(widget.childId)
        .get();

    if (snapshot.exists) {
      setState(() {
        childData = snapshot.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات الطفل'),
      ),
      body: childData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      '${childData!['name'] ?? ''} ${childData!['LName'] ?? ''}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoTile('تاريخ الميلاد', _formatDate(childData!['dob'])),
                  _buildInfoTile('الجنس ', childData!['sex']),
                  _buildInfoTile('بكاء عند الولادة', childData!['birthCry']),
                  _buildInfoTile('طريقة الولادة', childData!['birthMethod']),
                  _buildInfoTile('الوزن عند الولادة', '${childData!['birthWeight']} كغ'),
                  _buildInfoTile('الطول الحالي', '${childData!['height']} سم'),
                  _buildInfoTile('الوزن الحالي', '${childData!['weight']} كغ'),
                  _buildInfoTile('الحساسيات', childData!['allergies']),
                  _buildInfoTile('تعليقات الطبيب', childData!['comments']),
                  _buildInfoTile('الموعد التالي', _formatDate(childData!['nextAppointment'])),
                  const SizedBox(height: 30),
                  const Text(
                    'لا يمكن تعديل هذه المعلومات',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(String label, String? value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value ?? 'غير متوفر'),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'غير متوفر';
    final date = (timestamp as Timestamp).toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
