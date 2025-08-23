import 'package:bookingapp/pages/danhgia.dart';
import 'package:bookingapp/pages/edit_booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadBookings();
  }

  Future<void> loadBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('dat_lich')
        .where('userId', isEqualTo: user.uid)
        .orderBy('checkIn', descending: true)
        .get();

    final bookings = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();

    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lịch sử đặt phòng',
          style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: const Color(0xFF666666),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: const [
            Padding(
              padding: EdgeInsets.only(left: 0), 
              child: Tab(text: 'Chờ xác nhận'),
            ),
            Tab(text: 'Đã xác nhận'),
            Tab(text: 'Đã thực hiện'),
            Tab(text: 'Đã hủy'),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList('pending'),
          _buildBookingList('confirmed'),
          _buildBookingList('completed'),
          _buildBookingList('cancelled'),
        ],
      ),
    );
  }

  Widget _buildBookingList(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchBookingsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return const Center(child: Text('Không có đơn đặt phòng nào.'));
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(14, 14, 14, MediaQuery.of(context).padding.bottom + 80),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final data = bookings[index];
            final bookingId = data['id'];

            final formattedCheckIn = data['checkIn'] != null
                ? DateFormat('dd/MM/yyyy').format(data['checkIn'])
                : '---';
            final formattedCheckOut = data['checkOut'] != null
                ? DateFormat('dd/MM/yyyy').format(data['checkOut'])
                : '---';
            final formattedPrice = NumberFormat("#,###", "vi_VN").format(data['total']);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              color: const Color.fromARGB(255, 248, 247, 253),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: data['image'],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => const SizedBox(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                data['roomName'] ?? 'Không rõ',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              children: [
                                if (status == 'pending') ...[
                                  TextButton(
                                    onPressed: () => _editBooking(data),
                                    child: const Text(
                                      'Sửa',
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _confirmDelete(bookingId),
                                    child: const Text(
                                      'Huỷ',
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                                if (status == 'completed') ...[
                                  if (data['isRated'] == false)
                                    TextButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DanhGiaPage(bookingData: data),
                                          ),
                                        );
                                        if (result == true && mounted) {
                                          setState(() {}); // hoặc gọi lại loadBookings() nếu cần cập nhật lại toàn bộ
                                        }
                                      },
                                      child: const Text(
                                        'Đánh giá',
                                        style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  else
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        'Đã đánh giá',
                                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Ngày nhận: $formattedCheckIn'),
                        Text('Ngày trả: $formattedCheckOut'),
                        Text('Người lớn: ${data['adults']} | Trẻ em: ${data['children']} | Phòng: ${data['rooms']}'),
                        const SizedBox(height: 6),
                        Text('Tổng tiền: $formattedPrice VND',
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
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
    );
  }

  Future<List<Map<String, dynamic>>> _fetchBookingsByStatus(String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('dat_lich')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: status)
          .get();

      List<Map<String, dynamic>> bookings = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final bookingId = doc.id;

        // Kiểm tra đã đánh giá chưa
        final ratingSnap = await FirebaseFirestore.instance
            .collection('danh_gia')
            .where('bookingId', isEqualTo: bookingId)
            .limit(1)
            .get();
        final isRated = ratingSnap.docs.isNotEmpty;

        bookings.add({
          'id': bookingId,
          'roomId': data['roomId'] ?? '',
          'roomName': data['roomName'] ?? 'Không rõ',
          'checkIn': (data['checkIn'] as Timestamp?)?.toDate(),
          'checkOut': (data['checkOut'] as Timestamp?)?.toDate(), 
          'status': data['status'] ?? 'pending',
          'adults': data['adults'] ?? 0,
          'children': data['children'] ?? 0,
          'rooms': data['rooms'] ?? 1,
          'total': data['totalAmount'] ?? 0,
          'image': (data.containsKey('image') && data['image'] != null && data['image'].toString().isNotEmpty)
              ? data['image']
              : 'https://via.placeholder.com/600x400.png?text=No+Image',
          'isRated': isRated, 
          'userName': data['userName'] ?? 'Ẩn danh',
        });
      }

      return bookings;
    } catch (e) {
      print('Lỗi khi lấy đơn đặt phòng: $e');
      return [];
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Đã thực hiện';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không rõ';
    }
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đặt phòng'),
        content: const Text('Bạn có chắc muốn hủy đơn đặt phòng này không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // đóng dialog
              try {
                await FirebaseFirestore.instance
                    .collection('dat_lich')
                    .doc(docId)
                    .update({'status': 'cancelled'}); // ⚠️ Cập nhật thay vì xóa

                if (mounted) {
                  setState(() {});
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã huỷ đơn đặt phòng')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi huỷ: $e')),
                );
              }
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editBooking(Map<String, dynamic> booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookingPage(
          bookingData: booking,
          docId: booking['id'], // truyền ID document từ Firestore
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {}); // Cập nhật lại danh sách sau khi chỉnh sửa
    }
  }

  void _navigateToRating(Map<String, dynamic> booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DanhGiaPage(bookingData: booking),
      ),
    );

    if (result == true && mounted) {
      // 🔁 Refetch lại danh sách
      await loadBookings();
    }
  }
}