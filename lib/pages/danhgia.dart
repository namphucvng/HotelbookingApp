import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DanhGiaPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const DanhGiaPage({super.key, required this.bookingData});

  @override
  State<DanhGiaPage> createState() => _DanhGiaPageState();
}

class _DanhGiaPageState extends State<DanhGiaPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;
  bool _isSubmitting = false;
  String _userName = '...';

  @override
  void initState() {
    super.initState();
    // Ưu tiên tên đi kèm booking (History đã truyền),
    // fallback sẽ lấy từ users collection (username)
    _userName = (widget.bookingData['userName'] ?? 'Ẩn danh').toString();
    if (_userName == 'Ẩn danh') {
      _loadUserName(); // không chặn UI
    }
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = userDoc.data();
      final name = (data?['username'] ?? data?['name'] ?? 'Ẩn danh').toString();
      if (mounted) setState(() => _userName = name);
    } catch (_) {
      if (mounted) setState(() => _userName = 'Ẩn danh');
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_rating < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 sao')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bookingId = (widget.bookingData['id'] ?? '').toString();
      final roomId = (widget.bookingData['roomId'] ?? '').toString();
      final roomName = (widget.bookingData['roomName'] ?? 'Không rõ').toString();

      // 1) Lưu đánh giá
      await FirebaseFirestore.instance.collection('danh_gia').add({
        'bookingId': bookingId,
        'userId': user.uid,
        'roomId': roomId,
        'roomName': roomName,
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(), // dùng giờ server
        'userName': _userName,
        'avatar': user.photoURL ?? '',
      });

      // 2) Đánh dấu booking đã được đánh giá (để History đỡ phải truy vấn phụ)
      if (bookingId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('dat_lich')
            .doc(bookingId)
            .update({'isRated': true});
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi đánh giá: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final filled = starIndex <= _rating.round();
        return IconButton(
          icon: Icon(filled ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
          onPressed: () => setState(() => _rating = starIndex.toDouble()),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomName = (widget.bookingData['roomName'] ?? 'Không rõ').toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đánh giá phòng'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        titleTextStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phòng: $roomName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Người đánh giá: $_userName', style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 24),

            const Text('Chất lượng phòng', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            _buildStarRating(),

            const SizedBox(height: 24),
            const Text('Nhận xét', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Viết cảm nhận của bạn về phòng...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Gửi đánh giá', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
