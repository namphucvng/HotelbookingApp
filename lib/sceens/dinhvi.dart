import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theodoixe.dart';

class DinhViScreen extends StatefulWidget {
  final LatLng destinationLatLng;

  const DinhViScreen({super.key, required this.destinationLatLng});

  @override
  State<DinhViScreen> createState() => _DinhViScreenState();
}

class _DinhViScreenState extends State<DinhViScreen> {
  String? _selectedCar;
  String? _selectedLuggage;
  String? _selectedService;
  String? _destination;

  void _openGoogleMaps() async {
    if (_destination != null && _destination!.isNotEmpty) {
      final uri = Uri.parse(
          "https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(_destination!)}");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập nơi đến.")),
      );
    }
  }

  void _showBottomSheet(String type) {
    List<String> options = [];

    switch (type) {
      case 'car':
        options = ['4 chỗ', '7 chỗ', '16 chỗ'];
        break;
      case 'luggage':
        options = ['4 kg', '8 kg', '12 kg'];
        break;
      case 'service':
        options = ['Wifi', 'Nước suối', 'Bánh mì', 'Khăn lạnh'];
        break;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: options
            .map(
              (e) => ListTile(
                title: Text(e),
                onTap: () {
                  setState(() {
                    if (type == 'car') _selectedCar = e;
                    if (type == 'luggage') _selectedLuggage = e;
                    if (type == 'service') _selectedService = e;
                  });
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.deepPurple, size: 16),
            const SizedBox(width: 6),
            Text(label),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng destination = widget.destinationLatLng;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        title: const Text(
          "Định vị",
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 450,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: destination,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: destination,
                        child: const Icon(Icons.location_pin,
                            size: 40, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Nhập nơi đến",
                      prefixIcon: const Icon(Icons.place, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.deepPurple, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                      ),
                    ),
                    onChanged: (val) => _destination = val,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Tùy chọn",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildOption(
                        icon: Icons.directions_car,
                        label: _selectedCar ?? "Chọn xe",
                        onTap: () => _showBottomSheet('car'),
                      ),
                      _buildOption(
                        icon: Icons.luggage,
                        label: _selectedLuggage ?? "Hành lý",
                        onTap: () => _showBottomSheet('luggage'),
                      ),
                      _buildOption(
                        icon: Icons.miscellaneous_services,
                        label: _selectedService ?? "Dịch vụ",
                        onTap: () => _showBottomSheet('service'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedCar != null &&
                              _selectedLuggage != null &&
                              _selectedService != null &&
                              _destination != null &&
                              _destination!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TheoDoiXeScreen(
                                  destination: _destination!,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Vui lòng nhập nơi đến và chọn đầy đủ thông tin."),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Tài xế",
                            style: TextStyle(color: Colors.white)),
                      ),
                      OutlinedButton(
                        onPressed: _openGoogleMaps,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Tự di chuyển"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
