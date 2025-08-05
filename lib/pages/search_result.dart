import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:bookingapp/models/favorite_provider.dart';
import 'package:bookingapp/pages/detail_page.dart'; 
import 'package:intl/intl.dart';
import 'package:bookingapp/pages/stay_card.dart';

String formatCurrency(String priceString) {
  try {
    final price = int.tryParse(priceString) ?? 0;
    final formatter = NumberFormat("#,###", "vi_VN");
    return '${formatter.format(price).replaceAll(",", ".")}';
  } catch (_) {
    return priceString;
  }
}

class SearchResultPage extends StatelessWidget {
  final String searchKeyword;

  const SearchResultPage({super.key, required this.searchKeyword});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple), 
        title: const Text(
          'Kết quả tìm kiếm',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          firestore.collection('branches').get(),
          firestore.collection('hotels').get(),
        ]),
        builder: (context, AsyncSnapshot<List<QuerySnapshot<Map<String, dynamic>>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          final hotels = snapshot.data![1].docs;
          final favoritesProvider = Provider.of<FavoritesProvider>(context);

          final matchedRooms = hotels.where((roomDoc) {
            final name = (roomDoc.data()['name'] ?? '').toString().toLowerCase();
            return name.contains(searchKeyword.toLowerCase());
          }).toList();

          if (matchedRooms.isEmpty) {
            return const Center(child: Text('Không tìm thấy phòng phù hợp'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matchedRooms.length,
            itemBuilder: (context, index) {
              final roomDoc = matchedRooms[index];
              final roomData = roomDoc.data();
              final roomId = roomDoc.id;

              final imageUrls = roomData['imageUrls'] ?? [];
              final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

              final isFavorite = favoritesProvider.isFavorite(roomId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StayCard(
                  imagePath: imageUrl,
                  title: roomData['name'] ?? '',
                  price: roomData['price']?.toString() ?? '',
                  rating: roomData['rating']?.toString() ?? '0.0',
                  isLiked: isFavorite,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(roomData: {
                          ...roomData,
                          'roomId': roomId,
                        }),
                      ),
                    );
                  },
                  onLikePressed: () {
                    favoritesProvider.toggleFavorite({
                      ...roomData,
                      'roomId': roomId,
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
