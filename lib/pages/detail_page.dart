import 'package:bookingapp/sceens/dinhvi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:bookingapp/sceens/feedback.dart';
import 'package:bookingapp/sceens/datlich.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:bookingapp/models/favorite_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; 


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

  Map<String, dynamic>? _liveRoomData;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roomSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _reviewsSub;

  // 👉 CHỈNH: getter hợp nhất dữ liệu realtime và dữ liệu ban đầu
  Map<String, dynamic> get _effectiveRoomData =>
      _liveRoomData ?? widget.roomData;

  String get _roomDocId {
    final raw = widget.roomData['roomId'] ?? widget.roomData['id'];
    return (raw ?? '').toString();
  }

  @override
  void initState() {
    super.initState();
    _subscribeRoom();
    _subscribeReviews(); 
    checkIfFavorite();
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _reviewsSub?.cancel();
    super.dispose();
  }

  void _subscribeRoom() {
    final id = _roomDocId;
    if (id.isEmpty) return;

    _roomSub = FirebaseFirestore.instance
        .collection('hotels')
        .doc(id)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;
      setState(() {
        _liveRoomData = {
          'roomId': id,
          ...?doc.data(),
        };
      });
    }, onError: (e) => debugPrint('Lỗi subscribe room: $e'));
  }

  void _subscribeReviews() {
    final roomId = _roomDocId;
    if (roomId.isEmpty) return;

    _reviewsSub = FirebaseFirestore.instance
        .collection('danh_gia')
        .where('roomId', isEqualTo: roomId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      double total = 0;
      final loaded = snapshot.docs.map((d) {
        final data = d.data();
        final ratingNum = (data['rating'] ?? 0) as num;
        total += ratingNum.toDouble();

        // createdAt có thể null (serverTimestamp đang chờ), fallback now
        final created = data['createdAt'];
        final createdTs = (created is Timestamp)
            ? created
            : Timestamp.now();

        return {
          'userName': (data['userName'] ?? 'Ẩn danh').toString(),
          'avatar': (data['avatar'] ?? '').toString(),
          'rating': ratingNum.toDouble(),
          'review': (data['review'] ?? '').toString(),
          'createdAt': createdTs,
        };
      }).toList();

      setState(() {
        reviews = loaded;
        averageRating = loaded.isNotEmpty ? (total / loaded.length) : 0.0;
      });
    }, onError: (e) {
      debugPrint('Lỗi subscribe reviews: $e');
    });
  }

  Future<void> checkIfFavorite() async {
    final roomId = _roomDocId;
    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    final exists = provider.isFavorite(roomId);
    setState(() => isFavorite = exists);
  }

  String _getTimeAgo(dynamic ts) {
    Timestamp t;
    if (ts is Timestamp) {
      t = ts;
    } else if (ts is DateTime) {
      t = Timestamp.fromDate(ts);
    } else {
      t = Timestamp.now();
    }

    final date = t.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) return '${date.day}/${date.month}/${date.year}';
    if (diff.inDays >= 1) return '${diff.inDays} ngày trước';
    if (diff.inHours >= 1) return '${diff.inHours} giờ trước';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }

  @override
  Widget build(BuildContext context) {
    final data = _effectiveRoomData; // 👉 CHỈNH: dùng getter thống nhất

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildImageHeader(data),   // 👉 CHỈNH: truyền data vào
              _buildDescription(data),   // 👉 CHỈNH
              _buildAmenities(data),     // 👉 CHỈNH
              const SizedBox(height: 24),
              _buildFoodSection(data),   // 👉 CHỈNH
              const SizedBox(height: 24),
              _buildReviewSection(),
              const SizedBox(height: 24),
              _buildStaticMap(data),     // 👉 CHỈNH
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(data), // 👉 CHỈNH
    );
  }

  // ===================== UI BUILDERS =====================

  Widget _buildImageHeader(Map<String, dynamic> data) {
    final imageUrls = List<String>.from(data['imageUrls'] ?? []);
    final title = (data['name'] ?? 'Không có tên').toString();
    final location = (data['location'] ?? 'Đang cập nhật').toString();
    final type = (data['type'] ?? 'Hotel').toString();
    final price = (data['price'] ?? 0) as num;

    // Ưu tiên điểm trung bình từ reviews (nếu có), fallback rating lưu trong hotels
    final double headerRating = reviews.isNotEmpty
    ? double.parse(averageRating.toStringAsFixed(1))
    : ((data['rating'] ?? 0) as num).toDouble();

    final int reviewCount = reviews.length;

    return Stack(
      children: [
        SizedBox(
          height: 600,
          width: double.infinity,
          child: PageView.builder(
            itemCount: imageUrls.isNotEmpty ? imageUrls.length : 1,
            itemBuilder: (context, index) {
              final img = imageUrls.isNotEmpty
                  ? imageUrls[index]
                  : 'https://via.placeholder.com/1200x800.png?text=No+Image';
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
                    Text(
                      '${headerRating.toStringAsFixed(1)}/5'
                      '${reviewCount > 0 ? ' ($reviewCount)' : ''}',
                      style: const TextStyle(color: Colors.white),
                    ),
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

  Widget _buildDescription(Map<String, dynamic> data) {
    final description = (data['description'] ?? 'Không có mô tả').toString();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          description,
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.grey.shade700, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildAmenities(Map<String, dynamic> data) {
    final amenities = List<String>.from(data['amenities'] ?? []);
    final amenityIcons = <String, IconData>{
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
          if (amenities.isEmpty)
            const Text('Chưa cập nhật tiện nghi.')
          else
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              children: amenities.map((label) {
                final icon = amenityIcons[label] ?? Icons.check;
                return _buildAmenity(icon, label);
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
        Text(label, style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildFoodSection(Map<String, dynamic> data) {
    final foodList = List<Map<String, dynamic>>.from(data['foods'] ?? []);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thức ăn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (foodList.isEmpty)
            const Text('Chưa có món ăn kèm.')
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: foodList.length,
                itemBuilder: (context, index) {
                  final food = foodList[index];
                  final name = (food['name'] ?? 'Tên món').toString();
                  final imageUrl = (food['image'] ?? '').toString();
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
    final showSeeMore = reviews.length > 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Đánh giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  if (reviews.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        Text(averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(' (${reviews.length} lượt)'),
                      ],
                    ),
                ],
              ),
              if (showSeeMore)
                GestureDetector(
                  onTap: () {
                    final roomId = _roomDocId;
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DanhGiaScreen(roomId: roomId)));
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
              itemCount: showSeeMore ? 2 : reviews.length,
              itemBuilder: (context, index) => _buildCustomReviewTile(reviews[index]),
            ),
        ],
      ),
    );
  }

    Widget _buildCustomReviewTile(Map<String, dynamic> review) {
    final String userName = (review['userName'] ?? 'Người dùng').toString();
    final String avatar = (review['avatar'] ?? '').toString();
    final double rating = (review['rating'] is num) ? (review['rating'] as num).toDouble() : 0.0;
    final String content = (review['review'] ?? '').toString();
    final dynamic createdAtRaw = review['createdAt'];

    Timestamp createdAtTs;
    if (createdAtRaw is Timestamp) {
      createdAtTs = createdAtRaw;
    } else if (createdAtRaw is DateTime) {
      createdAtTs = Timestamp.fromDate(createdAtRaw);
    } else {
      createdAtTs = Timestamp.now();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: (avatar.isNotEmpty)
                ? NetworkImage(avatar)
                : const AssetImage('images/user_icon.png') as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 18.0,
                  direction: Axis.horizontal,
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeAgo(createdAtTs),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticMap(Map<String, dynamic> data) {
    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Vị trí trên bản đồ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Chưa có toạ độ cho phòng này.'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vị trí trên bản đồ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 450,
              child: FlutterMap(
                options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 15),
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
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
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
                  MaterialPageRoute(builder: (_) => DinhViScreen(destinationLatLng: LatLng(lat, lng))),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text('Xem vị trí', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildBottomBar(Map<String, dynamic> data) {
    final imageUrls = List<String>.from(data['imageUrls'] ?? []);
    final firstImage = imageUrls.isNotEmpty
        ? imageUrls[0]
        : 'https://via.placeholder.com/600x400.png?text=No+Image';

    final roomId = _roomDocId;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Nút yêu thích giống Home & Danh sách
          Selector<FavoritesProvider, bool>(
            selector: (ctx, p) => p.isFavorite(roomId),
            builder: (ctx, isFav, _) {
              return GestureDetector(
                onTap: () {
                  context.read<FavoritesProvider>().toggleFavorite({
                    ...data,
                    'roomId': roomId,
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    size: 22,
                    color: isFav ? Colors.purple : Colors.purple[200],
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Nút ĐẶT LỊCH NGAY
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DatLichScreen(
                        roomData: {
                          ...data,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ĐẶT LỊCH NGAY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
