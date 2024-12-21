import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Firebase Firestore

class SelectLocationScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng) onLocationSelected;

  const SelectLocationScreen({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? _selectedLocation;

  void _saveLocationToFirebase(LatLng location) async {
    try {
      await FirebaseFirestore.instance.collection('customers').add({
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timestamp': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil disimpan ke Firebase'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: Colors.green,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter:
              widget.initialLocation ?? LatLng(-1.609972, 103.607254),
          initialZoom: 9.2,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          if (_selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation!,
                  width: 50.0,
                  height: 50.0,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 50.0,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLocation != null) {
            _saveLocationToFirebase(_selectedLocation!);
            widget.onLocationSelected(_selectedLocation!);
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pilih lokasi terlebih dahulu'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
