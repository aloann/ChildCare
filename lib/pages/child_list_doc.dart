import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfe2025/pages/edit_child.dart';

class ChildListDocPage extends StatefulWidget {
  const ChildListDocPage({super.key});

  @override
  _ChildListDocPageState createState() => _ChildListDocPageState();
}

class _ChildListDocPageState extends State<ChildListDocPage> {
  List<Map<String, dynamic>> _allChildren = [];
  List<Map<String, dynamic>> _filteredChildren = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChildren();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchChildren() async {
    final snapshot = await FirebaseFirestore.instance.collection('children').get();
    final children = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id; // Include Firestore doc ID
      return data;
    }).toList();

    setState(() {
      _allChildren = children;
      _filteredChildren = children;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    setState(() {
      _filteredChildren = _allChildren.where((child) {
        final fullName = '${child['name']} ${child['LName']}'.trim();
        return fullName.contains(query) ||
            child['motherMail'].contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الأطفال'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchChildren,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: 'ابحث عن اسم الطفل أو بريد الأم',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchChildren,
              child: ListView.builder(
                itemCount: _filteredChildren.length,
                itemBuilder: (context, index) {
                  final child = _filteredChildren[index];
                  final childId = child['docId']; // Using Firestore document ID

                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text(
                          '${child['LName'] ?? 'بدون اسم'} ${child['name'] ?? ''}',
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: Text(
                          'تاريخ الميلاد: ${child['dob'] != null ? (child['dob'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'غير معروف'}',
                        ),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditChildPage(childId: childId),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
