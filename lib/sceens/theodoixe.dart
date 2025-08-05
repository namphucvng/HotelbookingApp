import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TheoDoiXeScreen extends StatelessWidget {
  final String destinationText;
  final LatLng destination;

  const TheoDoiXeScreen({
    super.key,
    required this.destinationText,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final eta = DateTime.now().add(const Duration(minutes: 15));
    final formattedTime = DateFormat.Hm().format(eta);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple), // màu nút back
        title: const Text(
          "Tìm tài xế",
          style: TextStyle(
            color: Colors.deepPurple, // màu chữ
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
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
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage("images/driver.png"),
                  ),
                  title: const Text("Long Phi Phan"),
                  subtitle: const Text("Anh tài xế"),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () async {
                      const phoneNumber = "tel:0912345678";
                      final Uri launchUri = Uri.parse(phoneNumber);

                      if (await canLaunchUrl(launchUri)) {
                        await launchUrl(launchUri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Không thể thực hiện cuộc gọi.")),
                        );
                      }
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.place),
                  title: const Text("Địa chỉ đến"),
                  subtitle: Text(destinationText),
                ),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text("Thời gian đến"),
                  subtitle: Text("$formattedTime (Nhanh nhất 15 phút)"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
