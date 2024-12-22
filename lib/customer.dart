import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'select_location_screen.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  LatLng? selectedLocation; // Variabel untuk menyimpan lokasi pelanggan

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<QueryDocumentSnapshot>? allCustomers; // Semua pelanggan dari Firestore
  List<QueryDocumentSnapshot>? filteredCustomers; // Hasil pencarian
  String? uid; // UID akun yang sedang login

  @override
  void initState() {
    super.initState();
    uid = auth.currentUser?.uid;
    _resetPaymentStatusIfNewMonth(); // Reset status pembayaran jika bulan baru
    _fetchCustomers(); // Ambil data pelanggan
  }

  Future<void> _resetPaymentStatusIfNewMonth() async {
    if (uid == null) return;

    final now = DateTime.now();
    final lastReset = await firestore
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) => doc.data()?['lastReset']?.toDate());

    // Jika belum pernah direset atau bulan telah berubah
    if (lastReset == null ||
        now.month != lastReset.month ||
        now.year != lastReset.year) {
      // Reset semua status pembayaran pelanggan
      final batch = firestore.batch();
      final customers = await firestore
          .collection('users')
          .doc(uid)
          .collection('customers')
          .get();

      for (final customer in customers.docs) {
        batch.update(customer.reference, {'isPaid': false});
      }

      // Perbarui waktu reset terakhir
      batch.update(
        firestore.collection('users').doc(uid),
        {'lastReset': now},
      );

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Status pembayaran telah direset untuk bulan baru.')),
      );

      _fetchCustomers(); // Perbarui daftar pelanggan
    }
  }

  Future<void> _fetchCustomers() async {
    if (uid == null) return;

    final querySnapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('customers')
        .get();

    setState(() {
      allCustomers = querySnapshot.docs;

      // Urutkan secara manual berdasarkan nama
      allCustomers?.sort((a, b) {
        String nameA = a['name'].toString().toLowerCase();
        String nameB = b['name'].toString().toLowerCase();
        return nameA.compareTo(nameB); // A-Z
      });

      filteredCustomers = allCustomers; // Mengisi data untuk pencarian
    });
  }

  void _filterCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCustomers = allCustomers;
      });
      return;
    }

    final results = allCustomers?.where((customer) {
      final name = customer['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCustomers = results;
    });
  }

  Future<void> _addCustomer() async {
    if (uid == null) return;

    try {
      await firestore.collection('users').doc(uid).collection('customers').add({
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
        'phone': phoneController.text.trim(),
        'isPaid': false,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelanggan berhasil ditambahkan')),
      );

      _fetchCustomers(); // Refresh data pelanggan
      nameController.clear();
      locationController.clear();
      phoneController.clear();
      addressController.clear();
      selectedLocation = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan pelanggan: $e')),
      );
    }
  }

  void _showPaymentHistoryDialog(QueryDocumentSnapshot customer) async {
    final history = await firestore
        .collection('users')
        .doc(uid)
        .collection('customers')
        .doc(customer.id)
        .collection('paymentHistory')
        .orderBy('date', descending: true)
        .get();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Riwayat Pembayaran - ${customer['name']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: history.docs.length,
              itemBuilder: (context, index) {
                final payment = history.docs[index];
                final date = payment['date'].toDate();
                final amount = payment['amount'] ?? 0;
                return ListTile(
                  title: Text(
                    'Tanggal: ${date.day}-${date.month}-${date.year}',
                  ),
                  subtitle: Text('Jumlah: Rp${amount.toString()}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  bool _isHovered = false; // Status hover untuk animasi

  void _clearCustomerFields() {
    nameController.clear();
    addressController.clear();
    locationController.clear();
    phoneController.clear();
    selectedLocation = null;
  }

  void _showAddCustomerDialog() {
    _clearCustomerFields();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Agar bisa memperbarui state di dalam dialog
          builder: (context, setState) {
            bool isLoading = false; // Status loading untuk tombol

            Future<void> addCustomerWithValidation() async {
              if (nameController.text.trim().isEmpty ||
                  locationController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap isi semua bidang!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() {
                isLoading = true;
              });

              try {
                await _addCustomer();
                Navigator.pop(context); // Tutup dialog setelah berhasil
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menambahkan pelanggan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Tambah Mitra'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Mitra'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Alamat'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Koodinat'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final LatLng? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectLocationScreen(
                              initialLocation: selectedLocation ??
                                  const LatLng(-1.609972, 103.607254),
                              onLocationSelected: (location) {
                                setState(() {
                                  selectedLocation =
                                      location; // Simpan lokasi yang dipilih
                                  locationController.text =
                                      'Lat: ${location.latitude}, Lng: ${location.longitude}';
                                });
                              },
                            ),
                          ),
                        );

                        // Jika lokasi dipilih, perbarui kontrol lokasi
                        if (result != null) {
                          setState(() {
                            selectedLocation = result;
                            locationController.text =
                                'Lat: ${result.latitude}, Lng: ${result.longitude}';
                          });
                        }
                      },
                      child: Text(
                        selectedLocation == null
                            ? "Pilih Lokasi (Koordinat)"
                            : "Lat: ${selectedLocation!.latitude}, Lng: ${selectedLocation!.longitude}",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: 'No. Handphone'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                  },
                  child: const Text('Batal'),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      right: 10), // Memberikan jarak ke kanan
                  child: ElevatedButton(
                    onPressed: isLoading ? null : addCustomerWithValidation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Membuat tombol bulat
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Tambah',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCustomerDialog(QueryDocumentSnapshot customer) {
    nameController.text = customer['name'];
    addressController.text = customer['address'];
    phoneController.text = customer['phone'];
    selectedLocation = LatLng(
      customer['latitude'],
      customer['longitude'],
    );
    locationController.text =
        'Lat: ${customer['latitude']}, Lng: ${customer['longitude']}';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            Future<void> editCustomerWithValidation() async {
              if (nameController.text.trim().isEmpty ||
                  addressController.text.trim().isEmpty ||
                  locationController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap isi semua bidang!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() {
                isLoading = true;
              });

              try {
                await _updateCustomer(customer.id);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal memperbarui pelanggan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Edit Mitra'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Mitra'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Alamat'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Koordinat'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final LatLng? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectLocationScreen(
                              initialLocation: selectedLocation ??
                                  const LatLng(-1.609972, 103.607254),
                              onLocationSelected: (location) {
                                setState(() {
                                  selectedLocation = location;
                                  locationController.text =
                                      'Lat: ${location.latitude}, Lng: ${location.longitude}';
                                });
                              },
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            selectedLocation = result;
                            locationController.text =
                                'Lat: ${result.latitude}, Lng: ${result.longitude}';
                          });
                        }
                      },
                      child: Text(
                        selectedLocation == null
                            ? "Pilih Lokasi (Koordinat)"
                            : "Lat: ${selectedLocation!.latitude}, Lng: ${selectedLocation!.longitude}",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: 'No. Handphone'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : editCustomerWithValidation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateCustomer(String customerId) async {
    try {
      if (uid == null) return;

      // Pastikan `selectedLocation` sudah berisi data lokasi
      final Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      // Tambahkan latitude dan longitude jika lokasi dipilih
      if (selectedLocation != null) {
        updateData['latitude'] = selectedLocation!.latitude;
        updateData['longitude'] = selectedLocation!.longitude;
      }

      await firestore
          .collection('users')
          .doc(uid)
          .collection('customers')
          .doc(customerId)
          .update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pelanggan berhasil diperbarui')),
      );

      _fetchCustomers(); // Perbarui daftar pelanggan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data pelanggan: $e')),
      );
    }
  }

  Future<void> _deleteCustomer(String customerId) async {
    try {
      if (uid == null) return;

      await firestore
          .collection('users')
          .doc(uid)
          .collection('customers')
          .doc(customerId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pelanggan berhasil dihapus')),
      );

      _fetchCustomers(); // Perbarui daftar pelanggan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data pelanggan: $e')),
      );
    }
  }

  Future<void> _togglePaymentStatus(String customerId, bool newStatus) async {
    try {
      final now = DateTime.now();

      // Perbarui status pembayaran
      await firestore
          .collection('users')
          .doc(uid)
          .collection('customers')
          .doc(customerId)
          .update({'isPaid': newStatus});

      // Jika pelanggan sudah membayar, tambahkan ke riwayat
      if (newStatus) {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('customers')
            .doc(customerId)
            .collection('paymentHistory')
            .add({
          'date': now,
          'amount': 30000, // Menyimpan jumlah pembayaran Rp30.000
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Pelanggan telah membayar Rp30.000'
                : 'Pembayaran pelanggan dibatalkan',
          ),
          backgroundColor: newStatus ? Colors.green : Colors.red,
        ),
      );

      _fetchCustomers(); // Refresh data pelanggan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status pembayaran: $e')),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Sudah Membayar'),
                onTap: () {
                  Navigator.pop(context);
                  _applyPaymentFilter(
                      true); // Tampilkan hanya yang sudah membayar
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle_outlined, color: Colors.red),
                title: const Text('Belum Membayar'),
                onTap: () {
                  Navigator.pop(context);
                  _applyPaymentFilter(
                      false); // Tampilkan hanya yang belum membayar
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetFilters(); // Tampilkan semua pelanggan
              },
              child: const Text('Tampilkan Semua'),
            ),
          ],
        );
      },
    );
  }

  void _applyPaymentFilter(bool isPaid) {
    setState(() {
      filteredCustomers = allCustomers?.where((customer) {
        return customer['isPaid'] == isPaid;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      filteredCustomers = allCustomers; // Tampilkan semua pelanggan
    });
  }

  void _showCustomerDetailsDialog(QueryDocumentSnapshot<Object?> document) {
    // Konversi data menjadi Map<String, dynamic>
    final Map<String, dynamic> customer =
        document.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detail Pelanggan: ${customer['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text('Nama: ${customer['name']}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.home, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text('Alamat: ${customer['address']}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text('Telepon: ${customer['phone']}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  // Menggunakan Flexible untuk membungkus teks koordinat
                  Flexible(
                    child: Text(
                      'Koordinat: ${customer['latitude']}, ${customer['longitude']}',
                      overflow: TextOverflow
                          .ellipsis, // Menambahkan overflow jika koordinat terlalu panjang
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    customer['isPaid'] == true
                        ? Icons.check_circle
                        : Icons.cancel,
                    color:
                        customer['isPaid'] == true ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status Pembayaran: ${customer['isPaid'] == true ? 'Lunas' : 'Belum Lunas'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: customer['isPaid'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Mitra - Mitra'),
      //   backgroundColor: Colors.green,
      // ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight, // Menempatkan tombol di kanan bawah
        child: Padding(
          padding: const EdgeInsets.only(
              right: 16.0, bottom: 16.0), // Jarak dari tepi
          child: InkWell(
            onTap: () {
              // Fungsi yang dijalankan saat tombol ditekan
              _showAddCustomerDialog();
            },
            onHover: (hovering) {
              setState(() {
                _isHovered = hovering;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56, // Tinggi tombol tetap
              width: _isHovered ? 140 : 56, // Lebar berubah saat hover
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(28), // Membuat tombol bulat
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white), // Ikon "+"
                  if (_isHovered)
                    const SizedBox(width: 8), // Jarak antara ikon dan teks
                  if (_isHovered)
                    const Text(
                      'Tambah Mitra',
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Posisi tombol di kanan bawah

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 15.0),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: _filterCustomers,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.green),
                        labelText: 'Cari Nama Mitra',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.black),
                    onPressed: _showFilterDialog,
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 16),

            // Daftar pelanggan
            Expanded(
              child: filteredCustomers == null
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCustomers!.isEmpty
                      ? const Center(
                          child: Text('Belum ada pelanggan yang ditambahkan.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              )),
                        )
                      : ListView.builder(
                          itemCount: filteredCustomers!.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers![index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            customer['isPaid'] == true
                                                ? Colors.green
                                                : Colors.red,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        customer['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.home,
                                                  size: 16, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  customer['address'],
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 16, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  '${customer['latitude']}, ${customer['longitude']}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone,
                                                  size: 16, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  customer['phone'],
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              (customer['isPaid'] ?? false)
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              color:
                                                  (customer['isPaid'] ?? false)
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                            onPressed: () async {
                                              await _togglePaymentStatus(
                                                  customer.id,
                                                  !(customer['isPaid'] ??
                                                      false));
                                            },
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) async {
                                              if (value == 'edit') {
                                                _showEditCustomerDialog(
                                                    customer);
                                              } else if (value == 'delete') {
                                                _deleteCustomer(customer.id);
                                              } else if (value == 'history') {
                                                _showPaymentHistoryDialog(
                                                    customer);
                                              } else if (value == 'details') {
                                                _showCustomerDetailsDialog(
                                                    customer); // Fungsi baru untuk menampilkan detail
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'history',
                                                child: Text('Riwayat'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'details',
                                                child: Text(
                                                    'Detail'), // Tombol baru
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
