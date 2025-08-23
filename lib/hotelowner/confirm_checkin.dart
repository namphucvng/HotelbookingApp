import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class ConfirmCheckInPage extends StatefulWidget {
  const ConfirmCheckInPage({super.key});

  @override
  State<ConfirmCheckInPage> createState() => _ConfirmCheckInPageState();
}

class _ConfirmCheckInPageState extends State<ConfirmCheckInPage> {
  late Future<List<Map<String, dynamic>>> _confirmedBookings;

  @override
  void initState() {
    super.initState();
    _confirmedBookings = _fetchConfirmedBookings();
  }

  Future<List<Map<String, dynamic>>> _fetchConfirmedBookings() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('dat_lich')
        .where('status', isEqualTo: 'confirmed')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'roomName': data['roomName'],
        'userId': data['userId'],
        'checkIn': (data['checkIn'] as Timestamp?)?.toDate(),
        'checkOut': (data['checkOut'] as Timestamp?)?.toDate(),
        'image': data['image'] ?? 'https://via.placeholder.com/600x400.png?text=No+Image',
      };
    }).toList();
  }

  Future<void> _markAsCheckedIn(String docId) async {
    await FirebaseFirestore.instance
        .collection('dat_lich')
        .doc(docId)
        .update({'status': 'completed'});

    setState(() {
      _confirmedBookings = _fetchConfirmedBookings(); // refresh
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Xác nhận khách đã nhận phòng thành công')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận nhận phòng'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _confirmedBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(child: Text('Không có đơn nào cần xác nhận.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        booking['image'],
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['roomName'] ?? 'Không rõ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text('Ngày nhận: ${booking['checkIn'] != null ? DateFormat('dd/MM/yyyy').format(booking['checkIn']) : '---'}'),
                          Text('Ngày trả: ${booking['checkOut'] != null ? DateFormat('dd/MM/yyyy').format(booking['checkOut']) : '---'}'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Xác nhận khách đã nhận phòng'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _markAsCheckedIn(booking['id']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
