import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'add.dart';
import 'profile.dart';
import 'customer.dart';

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
  List<Map<String, dynamic>> customerLocations = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _fetchCustomerLocations();
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

  Future<void> _fetchCustomerLocations() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc('UID_USER') // Ganti dengan ID pengguna yang sesuai
          .collection('customers')
          .get();

      List<Map<String, dynamic>> locations = snapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'latitude': doc['latitude'],
          'longitude': doc['longitude'],
        };
      }).toList();

      setState(() {
        customerLocations = locations;
      });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = [
      HomeContent(
        wasteCount: wasteCount,
        selectedWeight: selectedWeight,
        customerLocations: customerLocations,
      ),
      const AddDataScreen(),
      const CustomerScreen(),
      const ProfileScreen(),
    ];

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
  final Map<String, double> wasteCount;
  final double selectedWeight;
  final List<Map<String, dynamic>> customerLocations;

  const HomeContent({
    Key? key,
    required this.wasteCount,
    required this.selectedWeight,
    required this.customerLocations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Bagian Statistik Sampah
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
                  'Berat Sampah',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SfCircularChart(
                  legend:
                      Legend(isVisible: true, position: LegendPosition.bottom),
                  series: <CircularSeries>[
                    PieSeries<MapEntry<String, double>, String>(
                      dataSource: wasteCount.entries.toList(),
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                      '${selectedWeight.toStringAsFixed(0)} kg',
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

          // Bagian Daftar Lokasi Pelanggan
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
                  'Lokasi Pelanggan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: customerLocations.length,
                  itemBuilder: (context, index) {
                    final location = customerLocations[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(location['name']),
                      subtitle: Text(
                          'Lat: ${location['latitude']}, Lng: ${location['longitude']}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
