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
          'rating': data['rating'] ?? 0,
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
        title: const Text('Tất cả đánh giá'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: allReviews.isEmpty
          ? const Center(child: Text('Chưa có đánh giá nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allReviews.length,
              itemBuilder: (context, index) {
                final review = allReviews[index];
                return _reviewTile(
                  review['user'],
                  review['comment'],
                  review['rating'],
                  review['timeAgo'],
                  review['avatar'] != null
                      ? (review['avatar'].toString().startsWith('http')
                          ? NetworkImage(review['avatar'])
                          : AssetImage(review['avatar']) as ImageProvider)
                      : const AssetImage('images/default_avatar.png'),
                );
              },
            ),
    );
  }

  Widget _reviewTile(String user, String content, int rating, String timeAgo, ImageProvider avatar) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(backgroundImage: avatar),
      title: Text(user),
      subtitle: Text(content),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$rating/5', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
