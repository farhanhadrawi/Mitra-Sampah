import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectLocationPage extends StatefulWidget {
  final String customerId;

  const SelectLocationPage({Key? key, required this.customerId})
      : super(key: key);

  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(-6.2088, 106.8456), // Lokasi awal (Jakarta)
              zoom: 12.0,
            ),
            myLocationEnabled: true,
            onTap: (LatLng position) {
              setState(() {
                _selectedLocation = position;
              });
            },
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selectedLocation'),
                      position: _selectedLocation!,
                    ),
                  }
                : {},
          ),
          if (_selectedLocation == null)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Ketuk pada peta untuk memilih lokasi.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedLocation == null
            ? null
            : () {
                _saveLocationToFirebase();
              },
        label: const Text('Simpan Lokasi'),
        icon: const Icon(Icons.save),
        backgroundColor:
            _selectedLocation != null ? Colors.green : Colors.grey,
      ),
    );
  }

  Future<void> _saveLocationToFirebase() async {
    if (_selectedLocation == null) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final uid = "your-user-id"; // Ganti dengan UID pengguna yang valid

      // Simpan lokasi ke Firebase
      await firestore
          .collection('users')
          .doc(uid)
          .collection('customers')
          .doc(widget.customerId)
          .update({
        'location': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi berhasil disimpan!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan lokasi: $e')),
      );
    }
  }
}
