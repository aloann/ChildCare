import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe2025/pages/edit_child.dart';

class ChildListDocPage extends StatefulWidget {
  const ChildListDocPage({super.key});

  @override
  _ChildListDocPageState createState() => _ChildListDocPageState();
}

class _ChildListDocPageState extends State<ChildListDocPage> {
  // Function to fetch the list of children for the doctor
  Future<List<Map<String, dynamic>>> _fetchChildren() async {
    final snapshot = await FirebaseFirestore.instance.collection('children').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الأطفال'),  // Page title
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Trigger a refresh by rebuilding the widget
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching children.'));
          }

          final children = snapshot.data;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                // Trigger a refresh by rebuilding the widget
              });
            },
            child: ListView.builder(
              itemCount: children?.length ?? 0,
              itemBuilder: (context, index) {
                final child = children![index];
                final childId = child['nationalID'];  // Assuming the child document ID is the nationalID

                return ListTile(
                  title: Text('${child['name']} ${child['LName']}'),
                  subtitle: Text('DOB: ${child['dob']}'),
                  onTap: () {
                    // Navigate to the EditChildPage when a child is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditChildPage(childId: childId),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
