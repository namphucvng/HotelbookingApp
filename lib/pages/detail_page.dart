import 'package:bookingapp/sceens/dinhvi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:bookingapp/sceens/feedback.dart';
import 'package:bookingapp/sceens/datlich.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:bookingapp/models/favorite_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class DetailPage extends StatefulWidget {
  final Map<String, dynamic> roomData;

  const DetailPage({super.key, required this.roomData});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false;
  List<Map<String, dynamic>> reviews = [];
  double averageRating = 0;
  
  @override
  void initState() {
    super.initState();
    checkIfFavorite();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final roomId = widget.roomData['roomId'].toString(); // Đảm bảo kiểu String

      print('RoomId cần lấy đánh giá: $roomId');
      // print('Số lượng đánh giá lấy được: ${snapshot.docs.length}');
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('danh_gia')
          .where('roomId', isEqualTo: roomId)
          .orderBy('createdAt', descending: true)
          .get();

      // ✅ THÊM BƯỚC 3 Ở ĐÂY:
      for (var doc in snapshot.docs) {
        print('---');
        print('user: ${doc['userName']}');
        print('roomId: ${doc['roomId']}');
        print('rating: ${doc['rating']}');
        print('createdAt: ${doc['createdAt']}');
      }

      double totalRating = 0.0;
      final loadedReviews = snapshot.docs.map((doc) {
        final data = doc.data();
        final rating = (data['rating'] ?? 0) as num;
        totalRating += rating.toDouble();
        return {
          'userName': data['userName'] ?? 'Ẩn danh',
          'avatar': data['avatar'] ?? '',
          'rating': rating.toDouble(),
          'review': data['review'] ?? '',
          'createdAt': data['createdAt'] ?? Timestamp.now(),
        };
      }).toList();

      setState(() {
        reviews = loadedReviews;
        if (loadedReviews.isNotEmpty) {
          averageRating = totalRating / loadedReviews.length;
        }
      });
    } catch (e) {
      print('Lỗi khi lấy đánh giá: $e');
    }
  }

  Widget _buildReviewTile(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(review['avatar'] ?? ''),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['userName'] ?? 'Người dùng',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  RatingBarIndicator(
                    rating: review['rating'],
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 18.0,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review['review'] ?? '',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getTimeAgo(review['createdAt']),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkIfFavorite() async {
    final roomId = widget.roomData['roomId'].toString();
    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    final exists = provider.isFavorite(roomId);

    setState(() {
      isFavorite = exists;
    });
  }

  String _getTimeAgo(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildImageHeader(),
              _buildDescription(),
              _buildAmenities(),
              const SizedBox(height: 24),
              _buildFoodSection(),
              const SizedBox(height: 24),
              _buildReviewSection(),
              const SizedBox(height: 24),
              _buildStaticMap(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildImageHeader() {
    final data = widget.roomData;
    final imageUrls = List<String>.from(data['imageUrls'] ?? []);
    final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';
    final title = data['name'] ?? 'Không có tên';
    final location = data['location'] ?? 'Đang cập nhật';
    final type = 'Hotel';
    final price = data['price'] ?? 0;
    final rating = (data['rating'] ?? 0).toDouble();

    return Stack(
      children: [
        SizedBox(
          height: 600,
          width: double.infinity,
          child: PageView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final img = imageUrls[index];
              return CachedNetworkImage(
                imageUrl: img,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey,
                  child: const Center(child: Text("Không tải được ảnh")),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(location, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 15),
                    const SizedBox(width: 4),
                    Text('($rating/5)', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${NumberFormat("#,###", "vi_VN").format(price)} VND/đêm',
                        style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final description = widget.roomData['description'] ?? 'Không có mô tả';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          description,
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _buildAmenities() {
    final amenities = List<String>.from(widget.roomData['amenities'] ?? []);
    final amenityIcons = {
      'Wifi': Icons.wifi,
      'Gym': Icons.fitness_center,
      'Bữa sáng': Icons.breakfast_dining,
      'Bể bơi': Icons.pool,
      'Chỗ đậu xe': Icons.local_parking,
      'Pet Friendly': Icons.pets,
      'Giặt ủi': Icons.local_laundry_service,
      'Bar': Icons.local_bar,
      'Xe đưa đón': Icons.car_rental_sharp,
      'Spa': Icons.spa,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tiện nghi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4, // mỗi dòng có 4 tiện nghi
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            children: amenities.map((item) {
              return _buildAmenity(amenityIcons[item] ?? Icons.check, item);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenity(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFoodSection() {
    final foodList = List<Map<String, dynamic>>.from(widget.roomData['foods'] ?? []);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thức ăn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: foodList.length,
              itemBuilder: (context, index) {
                final food = foodList[index];
                final name = food['name'] ?? 'Tên món';
                final imageUrl = food['image'] ?? '';
                return _foodCard(name, imageUrl);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodCard(String name, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 70,
              width: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 70,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 70,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Đánh giá',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  final roomId = widget.roomData['roomId'].toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DanhGiaScreen(roomId: roomId),
                    ),
                  );
                },
                child: const Text(
                  'Xem thêm',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (reviews.isEmpty)
            const Text('Chưa có đánh giá nào.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length > 3 ? 3 : reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _buildReviewTile(review);
              },
            ),
        ],
      ),
    );
  }


  Widget _buildStaticMap() {
    final lat = (widget.roomData['latitude'] as num?)?.toDouble() ?? 12.238791;
    final lng = (widget.roomData['longitude'] as num?)?.toDouble() ?? 109.196749;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vị trí trên bản đồ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 450,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.bookingapp',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DinhViScreen(
                      destinationLatLng: LatLng(lat, lng),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text(
                'Xem vị trí',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final imageUrls = List<String>.from(widget.roomData['imageUrls'] ?? []);
    final firstImage = imageUrls.isNotEmpty
        ? imageUrls[0]
        : 'https://via.placeholder.com/600x400.png?text=No+Image';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DatLichScreen(
                  roomData: {
                    ...widget.roomData,
                    'image': firstImage,
                  },
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'ĐẶT LỊCH NGAY',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
