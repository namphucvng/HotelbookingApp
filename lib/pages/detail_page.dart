import 'package:bookingapp/sceens/dinhvi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:bookingapp/sceens/danhgia.dart';
import 'package:bookingapp/sceens/datlich.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';


class DetailPage extends StatefulWidget {
  final Map<String, dynamic> roomData;

  const DetailPage({super.key, required this.roomData});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
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
              return Image.network(
                img,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Center(child: Text("Không tải được ảnh")),
                  );
                },
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
      'Chỗ đậu xe': Icons.car_rental,
      'Wifi': Icons.wifi,
      'Giặt ủi': Icons.local_laundry_service,
      'Hồ bơi': Icons.pool,
      'Bar': Icons.local_bar,
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
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 16,
            runSpacing: 8,
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
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
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
            child: Image.network(
              imageUrl,
              height: 70,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 70,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image)),
                );
              },
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DanhGiaScreen()));
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
          _reviewTile('Chị Phiến',
              'Dịch vụ tốt, phòng sạch đẹp giá mà có anh Virus nhỉ', 5,
              '2 giờ trước', const AssetImage('images/chiphien.png')),
          _reviewTile('Capybara mini', 'Dịch vụ tốt, phòng sạch đẹp', 5,
              '2 tuần trước', const AssetImage('images/capybara.png')),
        ],
      ),
    );
  }

  Widget _reviewTile(String user, String content, int rating, String timeAgo,
      ImageProvider avatar) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
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
    final firstImage = imageUrls.isNotEmpty ? imageUrls[0] : 'https://via.placeholder.com/600x400.png?text=No+Image';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.deepPurple.shade100),
            ),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.purple[200],
              ),
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DatLichScreen(
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
          ),
        ],
      ),
    );
  }
}
