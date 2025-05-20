import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_child.dart';

class ChildListMomPage extends StatefulWidget {
  const ChildListMomPage({super.key});

  @override
  State<ChildListMomPage> createState() => _ChildListMomPageState();
}

class _ChildListMomPageState extends State<ChildListMomPage> {
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
      appBar: AppBar(
        title: const Text('أطفالي'),
      ),
      body: motherEmail == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('children')
                  .where('motherMail', isEqualTo: motherEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('لا يوجد أطفال مرتبطين بهذا الحساب.'));
                }

                final children = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    final data = child.data() as Map<String, dynamic>;

return Directionality(
  textDirection: TextDirection.rtl,
  child: Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: ListTile(
      title: Text(
        '${data['LName'] ?? 'بدون اسم'} ${data['name'] ?? ''}',
        textDirection: TextDirection.rtl,
      ),
      subtitle: Text(
        'تاريخ الميلاد: ${data['dob'] != null ? (data['dob'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'غير معروف'}',
      ),
      trailing: const Icon(Icons.chevron_left),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewChildPage(childId: child.id),
          ),
        );
      },
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
