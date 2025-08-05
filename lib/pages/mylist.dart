import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bookingapp/pages/detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:bookingapp/models/favorite_provider.dart';


class HotelRoomListPage extends StatefulWidget {
  final String branchId;
  final String branchName;

  const HotelRoomListPage({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<HotelRoomListPage> createState() => _HotelRoomListPageState();
}

class _HotelRoomListPageState extends State<HotelRoomListPage> {
  String _selectedFilter = 'default';

  void _onFilterSelected(String value) {
    setState(() {
      _selectedFilter = value;
    });
  }

  @override
  void initState() {
    super.initState();
    // Force reload favorites in case it was changed before arriving here
    Future.microtask(() {
      Provider.of<FavoritesProvider>(context, listen: false).loadFavorites();
    });
  }


  List<QueryDocumentSnapshot> _sortRooms(
      List<QueryDocumentSnapshot> rooms, String filter) {
    final List<QueryDocumentSnapshot> sortedRooms = List.from(rooms);

    switch (filter) {
      case 'price_asc':
        sortedRooms.sort((a, b) =>
            (a['price'] ?? 0).compareTo(b['price'] ?? 0));
        break;
      case 'price_desc':
        sortedRooms.sort((a, b) =>
            (b['price'] ?? 0).compareTo(a['price'] ?? 0));
        break;
      case 'rating_desc':
        sortedRooms.sort((a, b) =>
            (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
        break;
    }
    return sortedRooms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HotelHeader(
              branchName: widget.branchName,
              onFilterSelected: _onFilterSelected,
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('hotels')
                    .where('branchId', isEqualTo: widget.branchId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Chưa có phòng nào"));
                  }

                  List<QueryDocumentSnapshot> rooms =
                      _sortRooms(snapshot.data!.docs, _selectedFilter);

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    cacheExtent: 1000,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final data =
                          rooms[index].data() as Map<String, dynamic>;

                      final List<String> imageUrls = (data['imageUrls'] is List)
                        ? List<String>.from(data['imageUrls'])
                        : [];

                      final String description =
                          (data['description'] is String &&
                                  data['description']
                                      .toString()
                                      .trim()
                                      .isNotEmpty)
                              ? data['description']
                              : 'Không có mô tả';

                      final String title =
                          (data['name'] is String &&
                                  data['name']
                                      .toString()
                                      .trim()
                                      .isNotEmpty)
                              ? data['name']
                              : 'Không có tiêu đề';

                      final String price =
                          data['price']?.toString() ?? '0';
                      final String rating =
                          data['rating']?.toString() ?? '0';

                      return HotelRoomCard(
                        imageUrls: imageUrls,
                        imageDescription: description,
                        title: title,
                        price: price,
                        rating: rating,
                        roomData: data,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class HotelHeader extends StatelessWidget {
  final String branchName;
  final void Function(String) onFilterSelected;

  const HotelHeader({
    super.key,
    required this.branchName,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20, color: Colors.deepPurple),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Quay lại',
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 248, 247, 253),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 180),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    branchName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Danh sách · Phòng',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.tune, size: 20, color: Colors.deepPurple),
              tooltip: 'Bộ lọc',
              onSelected: onFilterSelected,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'price_asc', child: Text('Giá tăng dần')),
                PopupMenuItem(value: 'price_desc', child: Text('Giá giảm dần')),
                PopupMenuItem(value: 'rating_desc', child: Text('Đánh giá cao nhất')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class HotelRoomCard extends StatefulWidget {
  final List<String> imageUrls;
  final String imageDescription;
  final String title;
  final String price;
  final String rating;
  final Map<String, dynamic> roomData;

  const HotelRoomCard({
    super.key,
    required this.imageUrls,
    required this.imageDescription,
    required this.title,
    required this.price,
    required this.rating,
    required this.roomData,
  });

  @override
  State<HotelRoomCard> createState() => _HotelRoomCardState();
}

class _HotelRoomCardState extends State<HotelRoomCard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String formatPrice(String rawPrice) {
    try {
      final double priceValue = double.parse(rawPrice);
      final NumberFormat currencyFormatter =
          NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
      return '${currencyFormatter.format(priceValue)}/đêm';
    } catch (_) {
      return '$rawPrice/đêm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(roomData: widget.roomData),
          ),
        );
      },
      child: Card(
        color: const Color.fromARGB(255, 248, 247, 253),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 320,
                  child: widget.imageUrls.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: widget.imageUrls.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            final url = widget.imageUrls[index];
                            return ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 320,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                size: 48, color: Colors.grey),
                          ),
                        ),
                ),
                if (widget.imageUrls.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.imageUrls.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 10 : 6,
                          height: isActive ? 10 : 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        widget.rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.imageDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatPrice(widget.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

