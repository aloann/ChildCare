import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SizesPage extends StatefulWidget {
  final String childId;
  final DateTime dob;

  const SizesPage({Key? key, required this.childId, required this.dob}) : super(key: key);

  @override
  _SizesPageState createState() => _SizesPageState();
}

class _SizesPageState extends State<SizesPage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  List<Map<String, dynamic>> sizeEntries = [];

  @override
  void initState() {
    super.initState();
    _loadSizeData();
  }

  Future<void> _loadSizeData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('children')
          .doc(widget.childId)
          .collection('sizes')
          .orderBy('date')
          .get();

      setState(() {
        sizeEntries = snapshot.docs.map((doc) {
          final data = doc.data();
          final DateTime date = (data['date'] as Timestamp).toDate();
          final int ageInMonths = _calculateAgeInMonths(widget.dob, date);
          
          // Safely convert weight and height to double
          final weight = _toDouble(data['weight']);
          final height = _toDouble(data['height']);
          
          return {
            'weight': weight,
            'height': height,
            'date': date,
            'ageInMonths': ageInMonths,
          };
        }).where((entry) {
          // Filter out entries with invalid weight/height
          return entry['weight'] != null && entry['height'] != null;
        }).toList();
      });
    } on FirebaseException catch (e) {
      String message = 'خطأ أثناء تحميل بيانات الحجم';
      if (e.code == 'permission-denied') {
        message = 'ليس لديك الصلاحية لعرض بيانات الحجم';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$message: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ غير متوقع: $e')),
      );
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return null; // Skip invalid types
  }

  int _calculateAgeInMonths(DateTime dob, DateTime date) {
    return (date.year - dob.year) * 12 + (date.month - dob.month);
  }

  Future<void> _addSizeEntry() async {
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);

    if (weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال قيم صحيحة للطول والوزن')),
      );
      return;
    }

    try {
      final now = DateTime.now();
      await FirebaseFirestore.instance
          .collection('children')
          .doc(widget.childId)
          .collection('sizes')
          .add({
        'weight': weight, // Store as double
        'height': height, // Store as double
        'date': now,
      });

      _weightController.clear();
      _heightController.clear();
      await _loadSizeData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة قياسات الطفل بنجاح')),
      );
    } on FirebaseException catch (e) {
      String message = 'خطأ أثناء إضافة القياسات';
      if (e.code == 'permission-denied') {
        message = 'ليس لديك الصلاحية لإضافة قياسات';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$message: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ غير متوقع: $e')),
      );
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weightSpots = sizeEntries
        .map((entry) => FlSpot(
              entry['ageInMonths'].toDouble(),
              entry['weight'] as double,
            ))
        .toList();

    final heightSpots = sizeEntries
        .map((entry) => FlSpot(
              entry['ageInMonths'].toDouble(),
              entry['height'] as double,
            ))
        .toList();

    // Calculate maxY for weight chart
    double getWeightMaxY() {
      if (weightSpots.isEmpty) return 20.0;
      final maxWeight = weightSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      return (maxWeight * 1.2).clamp(10.0, 50.0);
    }

    // Calculate maxY for height chart
    double getHeightMaxY() {
      if (heightSpots.isEmpty) return 100.0;
      final maxHeight = heightSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      return (maxHeight * 1.2).clamp(50.0, 150.0);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('تطور الحجم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'الوزن (كغ)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'الطول (سم)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.pink),
                    onPressed: _addSizeEntry,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: sizeEntries.isEmpty
                    ? const Center(child: Text('لا توجد بيانات حتى الآن.'))
                    : Column(
                        children: [
                          // Weight Chart
                          const Text(
                            'تطور الوزن (كغ)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: weightSpots,
                                    isCurved: true,
                                    color: Colors.pink,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.pink.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${value.toInt()}');
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${value.toInt()} شهر');
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: true),
                                minX: 0,
                                maxX: (sizeEntries.isNotEmpty
                                        ? sizeEntries.last['ageInMonths'].toDouble()
                                        : 24)
                                    .clamp(6, 24),
                                minY: 0,
                                maxY: getWeightMaxY(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Height Chart
                          const Text(
                            'تطور الطول (سم)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: heightSpots,
                                    isCurved: true,
                                    color: Colors.blue,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.blue.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${value.toInt()}');
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${value.toInt()} شهر');
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: true),
                                minX: 0,
                                maxX: (sizeEntries.isNotEmpty
                                        ? sizeEntries.last['ageInMonths'].toDouble()
                                        : 24)
                                    .clamp(6, 24),
                                minY: 0,
                                maxY: getHeightMaxY(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'سجل الطول والوزن',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: sizeEntries.length,
                              itemBuilder: (context, index) {
                                final entry = sizeEntries[index];
                                return ListTile(
                                  title: Text(
                                    '${entry['weight']} كغ - ${entry['height']} سم',
                                    textDirection: TextDirection.rtl,
                                  ),
                                  subtitle: Text(
                                    '${entry['ageInMonths']} شهر - ${entry['date'].toLocal().toString().split(' ')[0]}',
                                    textDirection: TextDirection.rtl,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}