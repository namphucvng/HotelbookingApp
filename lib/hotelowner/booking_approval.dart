import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingApproval extends StatefulWidget {
  const BookingApproval({super.key});

  @override
  State<BookingApproval> createState() => _BookingApprovalState();
}

class _BookingApprovalState extends State<BookingApproval> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Duyệt đơn đặt phòng', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('dat_lich').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có đơn chờ duyệt'));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;
              final docId = bookings[index].id;
              final checkIn = (data['checkIn'] as Timestamp?)?.toDate();
              final checkOut = (data['checkOut'] as Timestamp?)?.toDate();
              final formattedPrice = NumberFormat("#,###", "vi_VN").format(data['totalAmount'] ?? 0);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['image'] != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          data['image'],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(
                            height: 160,
                            child: Center(child: Icon(Icons.broken_image, size: 40)),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['roomName'] ?? 'Không rõ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Chi nhánh: ${data['branchName'] ?? 'Không rõ'}'),
                          Text('Ngày nhận: ${checkIn != null ? DateFormat('dd/MM/yyyy').format(checkIn) : '---'}'),
                          Text('Ngày trả: ${checkOut != null ? DateFormat('dd/MM/yyyy').format(checkOut) : '---'}'),
                          Text('Người lớn: ${data['adults']} | Trẻ em: ${data['children']} | Phòng: ${data['rooms']}'),
                          const SizedBox(height: 6),
                          Text('Tổng tiền: $formattedPrice VND', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _updateStatus(docId, 'confirmed'),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Xác nhận'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () => _confirmReject(docId),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Từ chối'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
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

  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      if (newStatus == 'rejected') {
        await FirebaseFirestore.instance.collection('dat_lich').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đơn đặt phòng đã bị từ chối và xoá.')),
        );
      } else {
        await FirebaseFirestore.instance.collection('dat_lich').doc(docId).update({
          'status': newStatus,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đơn đặt phòng đã được xác nhận.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _confirmReject(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận từ chối'),
        content: const Text('Bạn có chắc chắn muốn từ chối và xoá đơn đặt phòng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // đóng dialog
              _updateStatus(docId, 'rejected');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá đơn'),
          ),
        ],
      ),
    );
  }
}
