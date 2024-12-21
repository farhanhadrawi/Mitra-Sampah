import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerDialog extends StatefulWidget {
  final LatLng? initialLocation; // Tambah parameter untuk lokasi awal

  const LocationPickerDialog({
    Key? key,
    this.initialLocation,
  }) : super(key: key);

  @override
  _LocationPickerDialogState createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  LatLng? selectedLocation;
  final MapController mapController = MapController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Gunakan initial location jika ada, jika tidak baru get current location
    if (widget.initialLocation != null) {
      selectedLocation = widget.initialLocation;
      // Delay diperlukan untuk memastikan map sudah ter-render
      Future.delayed(Duration(milliseconds: 100), () {
        mapController.move(widget.initialLocation!, 15.0);
      });
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          selectedLocation = LatLng(position.latitude, position.longitude);
          mapController.move(selectedLocation!, 15.0);
        });
      }
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get current location')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                height: 400,
                width: 600,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: selectedLocation ??
                        widget.initialLocation ??
                        LatLng(-6.200000, 106.816666),
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: selectedLocation!,
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Current Location Button
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: 'locationButton',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: isLoading ? null : _getCurrentLocation,
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.my_location,
                          color: Colors.blue,
                        ),
                ),
              ),
              // Coordinates display
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: selectedLocation != null
                      ? Text(
                          '${selectedLocation!.latitude.toStringAsFixed(4)}, '
                          '${selectedLocation!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 12),
                        )
                      : Text('Pilih lokasi'),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                TextButton(
                  onPressed: selectedLocation != null
                      ? () => Navigator.pop(context, selectedLocation)
                      : null,
                  child: Text('Pilih'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
