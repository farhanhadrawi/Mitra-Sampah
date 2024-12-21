import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        onTap: (location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        markers: _selectedLocation != null
            ? {
                Marker(
                  markerId: const MarkerId('selected-location'),
                  position: _selectedLocation!,
                )
              }
            : {},
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation ?? const LatLng(-6.2, 106.8),
          zoom: 15,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLocation != null) {
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
