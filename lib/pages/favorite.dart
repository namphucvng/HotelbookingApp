import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:bookingapp/models/favorite_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isEditMode = true; // "Chỉnh sửa" bật/tắt nút xoá


  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favoritesList = List<Map<String, dynamic>>.from(favoritesProvider.favorites);

    // Sắp xếp bản sao, không làm thay đổi danh sách gốc trong provider
    favoritesList.sort((a, b) {
      final dateA = DateTime.tryParse(a['dateViewed'] ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b['dateViewed'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Phòng yêu thích',
          style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (favoritesList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditMode = !_isEditMode;
                  });
                },
                child: Center(
                  child: Text(
                    _isEditMode ? 'Chỉnh sửa' : 'Hoàn tất',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: favoritesList.isEmpty
          ? const Center(child: Text('Chưa có phòng nào được yêu thích.'))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                itemCount: favoritesList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final room = favoritesList[index];
                  final imageUrls = List<String>.from(room['imageUrls'] ?? []);
                  final imageUrl = imageUrls.isNotEmpty
                      ? imageUrls[0]
                      : 'https://via.placeholder.com/600x400.png?text=No+Image';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(roomData: room),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: double.infinity,
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: double.infinity,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                            ),
                            if (!_isEditMode)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: GestureDetector(
                                  onTap: () {
                                    favoritesProvider.toggleFavorite(room);
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close, size: 16),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room['name'] ?? 'Không tên',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
