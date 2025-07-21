import 'package:flutter/material.dart';

class DanhGiaScreen extends StatelessWidget {
  const DanhGiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ĐÁNH GIÁ', style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24), // <-- khoảng cách giữa AppBar và nội dung
          // Tổng kết đánh giá
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _circleRating('5★', 30),
                    _circleRating('4★', 40),
                    _circleRating('3★', 20),
                    _circleRating('2★', 5),
                    _circleRating('1★', 5),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _criteria('Phòng', 4.5),
                    _criteria('Tiện ích', 4.8),
                    _criteria('Dịch vụ', 4.4),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '4.4 Rất tốt',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.star, color: Colors.orange, size: 28),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          // Danh sách đánh giá
          Expanded(
            child: ListView(
              children: [
                _reviewItem(
                  name: 'Thiếu za Đắk Lắk',
                  comment: 'Đồ ăn ngon, chủ khách sạn xinh đẹp',
                  timeAgo: '20 phút trước',
                  rating: 4,
                  avatarUrl: 'images/avatar1.png',
                ),
                _reviewItem(
                  name: 'Anh da đen',
                  comment: 'Tiện ích đầy đủ, phòng ốc sạch sẽ',
                  timeAgo: '2 ngày trước',
                  rating: 5,
                  avatarUrl: 'images/avatar2.png',
                ),
                _reviewItem(
                  name: 'Chị bán chè',
                  comment: 'Phao chuối rất vui, chủ nhiệt tình',
                  timeAgo: '2 ngày trước',
                  rating: 4,
                  avatarUrl: 'images/avatar3.png',
                ),
                _reviewItem(
                  name: 'Nhỏ tên Ngân Hà',
                  comment: 'Thích thú, 10 điểm không có nhưng',
                  timeAgo: '3 ngày trước',
                  rating: 4,
                  avatarUrl: 'images/avatar4.png',
                ),
                TextButton(
                  onPressed: () {
                    // TODO: load more reviews
                  },
                  child: const Text('Thêm', style: TextStyle(decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleRating(String text, int percent) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                value: percent / 100,
                backgroundColor: Colors.grey[300],
                color: Colors.deepPurple,
                strokeWidth: 4,
              ),
            ),
            Text(text, style: const TextStyle(fontSize: 10)),
          ],
        ),
        Text('$percent%'),
      ],
    );
  }

  Widget _criteria(String label, double score) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(score.toString(), style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _reviewItem({
    required String name,
    required String comment,
    required String timeAgo,
    required int rating,
    required String avatarUrl,
  }) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage(avatarUrl)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 14,
              ),
            ),
          ),
          Text(timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      trailing: Text('$rating/5', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
