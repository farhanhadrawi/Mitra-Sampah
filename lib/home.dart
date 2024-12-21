import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add.dart';
import 'profile.dart';
import 'customer.dart';

// COlorado
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  double totalWeight = 0;
  int totalSampah = 0;
  Map<String, double> wasteCount = {'Organik': 0.0, 'Anorganik': 0.0};
  double selectedWeight = 0;

  final List<Map<String, String>> routes = [
    {"route": "Jalan Merdeka", "time": "08:00 AM"},
    {"route": "Jalan Sudirman", "time": "10:00 AM"},
    {"route": "Jalan Thamrin", "time": "01:00 PM"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('wasteData').get();

    double weight = 0;
    int sampahCount = 0;
    Map<String, double> count = {'Organik': 0.0, 'Anorganik': 0.0};

    for (var doc in snapshot.docs) {
      double docWeight = doc['weight']?.toDouble() ?? 0.0;
      weight += docWeight;
      sampahCount++;

      String wasteType = doc['wasteType'] ?? '';
      if (count.containsKey(wasteType)) {
        count[wasteType] = count[wasteType]! + docWeight;
      }
    }

    setState(() {
      totalWeight = weight;
      totalSampah = sampahCount;
      wasteCount = count;
      selectedWeight = weight; // Default: total semua sampah
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    const AddDataScreen(),
    const CustomerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: _selectedIndex == 0 ? Colors.green : Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle,
                color: _selectedIndex == 1 ? Colors.green : Colors.black),
            label: 'Tambah Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people,
                color: _selectedIndex == 2 ? Colors.green : Colors.black),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _selectedIndex == 3 ? Colors.green : Colors.black),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final _HomeScreenState homeState =
        context.findAncestorStateOfType<_HomeScreenState>()!;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.greenAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Grafik Perbandingan Sampah + Total Berat
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Perbandingan Sampah',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SfCircularChart(
                    legend: Legend(
                        isVisible: true, position: LegendPosition.bottom),
                    series: <CircularSeries>[
                      PieSeries<MapEntry<String, double>, String>(
                        dataSource: homeState.wasteCount.entries.toList(),
                        xValueMapper: (MapEntry<String, double> data, _) =>
                            data.key,
                        yValueMapper: (MapEntry<String, double> data, _) =>
                            data.value,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        pointColorMapper: (MapEntry<String, double> data, _) {
                          if (data.key == 'Organik') {
                            return Colors.green;
                          } else {
                            return Colors.blue;
                          }
                        },
                        onPointTap: (ChartPointDetails details) {
                          String selectedType =
                              details.pointIndex == 0 ? 'Organik' : 'Anorganik';
                          homeState.setState(() {
                            homeState.selectedWeight =
                                homeState.wasteCount[selectedType] ?? 0;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Total Berat Sampah
                  Column(
                    children: [
                      const Text(
                        'Total Berat Sampah',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${homeState.selectedWeight.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Rute Pengambilan Sampah
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rute Pengambilan Sampah Hari Ini',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...homeState.routes.map((route) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${route['route']} - ${route['time']}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
