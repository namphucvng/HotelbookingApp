import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TheoDoiXeScreen extends StatelessWidget {
  final String destination;

  const TheoDoiXeScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    // Lấy thời gian hiện tại + 15 phút
    final eta = DateTime.now().add(const Duration(minutes: 15));
    final formattedTime = DateFormat.Hm().format(eta);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Theo dõi tài xế",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.asset("images/map_mock.png", fit: BoxFit.cover),
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
                    onPressed: () {
                      // thêm logic gọi điện nếu cần
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.place),
                  title: const Text("Địa chỉ đến"),
                  subtitle: Text(destination),
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
