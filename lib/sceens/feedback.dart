import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class DanhGiaScreen extends StatefulWidget {
  final String roomId;

  const DanhGiaScreen({super.key, required this.roomId});

  @override
  State<DanhGiaScreen> createState() => _DanhGiaScreenState();
}

class _DanhGiaScreenState extends State<DanhGiaScreen> {
  List<Map<String, dynamic>> allReviews = [];
  double averageRating = 0;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('danh_gia')
        .where('roomId', isEqualTo: widget.roomId)
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      allReviews = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'user': data['userName'] ?? 'Ẩn danh',
          'comment': data['review'] ?? '',
          'rating': (data['rating'] ?? 0).toDouble(),
          'timeAgo': _getTimeAgo(data['createdAt']),
          'avatar': data['avatar'],
        };
      }).toList();

      if (allReviews.isNotEmpty) {
        final total = allReviews.fold(0.0, (sum, item) => sum + (item['rating'] ?? 0));
        averageRating = total / allReviews.length;
      }
    });
  }

  String _getTimeAgo(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tất cả đánh giá',
          style: TextStyle(
            color: Colors.deepPurple, // Màu chữ tiêu đề
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // Nền trắng
        iconTheme: const IconThemeData(color: Colors.deepPurple), // Màu nút back
        elevation: 1, // Đổ bóng nhẹ (tùy chọn)
      ),
      body: allReviews.isEmpty
          ? const Center(child: Text('Chưa có đánh giá nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allReviews.length,
              itemBuilder: (context, index) {
                final review = allReviews[index];

                ImageProvider avatarProvider;
                if (review['avatar'] != null &&
                    review['avatar'].toString().startsWith('http')) {
                  avatarProvider = NetworkImage(review['avatar']);
                } else {
                  avatarProvider = const AssetImage('images/user_icon.png');
                }

                return _reviewTile(
                  review['user'],
                  review['comment'],
                  review['rating'],
                  review['timeAgo'],
                  avatarProvider,
                );
              },
            ),
    );
  }

  Widget _reviewTile(String user, String comment, double rating, String timeAgo, ImageProvider avatar) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Nền xám nhạt
        borderRadius: BorderRadius.circular(12), // Bỏ viền, giữ bo góc
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: avatar, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: Axis.horizontal,
                ),
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
