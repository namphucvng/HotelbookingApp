import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:bookingapp/models/favorite_provider.dart';
import 'package:bookingapp/pages/detail_page.dart'; 
import 'package:intl/intl.dart';
import 'package:bookingapp/pages/stay_card.dart';
import 'package:cached_network_image/cached_network_image.dart'; 

String formatCurrency(String priceString) {
  try {
    final price = int.tryParse(priceString) ?? 0;
    final formatter = NumberFormat("#,###", "vi_VN");
    return '${formatter.format(price).replaceAll(",", ".")}';
  } catch (_) {
    return priceString;
  }
}

class SearchResultPage extends StatefulWidget {
  final String searchKeyword;

  const SearchResultPage({super.key, required this.searchKeyword});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late Future<QuerySnapshot> _roomsFuture;
  late Future<QuerySnapshot> _branchesFuture;
  Map<String, String> _branchNames = {};

  @override
  void initState() {
    super.initState();
    _roomsFuture = FirebaseFirestore.instance.collection('hotels').get();
    _branchesFuture = FirebaseFirestore.instance.collection('branches').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả tìm kiếm: "${widget.searchKeyword}"'),
      ),
      body: FutureBuilder(
        future: Future.wait([_roomsFuture, _branchesFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Lỗi tải dữ liệu'));
          }

          final roomsSnapshot = snapshot.data![0] as QuerySnapshot;
          final branchesSnapshot = snapshot.data![1] as QuerySnapshot;

          // Tạo map branchId -> branchName
          _branchNames = {
            for (var branch in branchesSnapshot.docs)
              branch.id: branch['name'] ?? 'Không tên'
          };

          final filteredRooms = roomsSnapshot.docs.where((roomDoc) {
            final roomData = roomDoc.data() as Map<String, dynamic>;
            final keyword = widget.searchKeyword.toLowerCase();
            
            final roomName = (roomData['name'] ?? '').toString().toLowerCase();
            final roomType = (roomData['type'] ?? '').toString().toLowerCase();
            final branchId = roomData['branchId']?.toString() ?? '';
            final branchName = _branchNames[branchId]?.toLowerCase() ?? '';

            return roomName.contains(keyword) ||
                  roomType.contains(keyword) ||
                  branchName.contains(keyword);
          }).toList();

          if (filteredRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy kết quả phù hợp',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Thử với từ khóa khác hoặc ít cụ thể hơn',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredRooms.length,
            itemBuilder: (context, index) {
              final roomDoc = filteredRooms[index];
              final roomData = roomDoc.data() as Map<String, dynamic>;
              final imageUrls = roomData['imageUrls'] ?? [];
              final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';
              final branchId = roomData['branchId'] ?? '';
              final branchName = _branchNames[branchId] ?? 'Không rõ chi nhánh';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        width: 80,
                        height: 80,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  title: Text(roomData['name'] ?? 'Không tên'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chi nhánh: $branchName'),
                      Text('Loại: ${roomData['type'] ?? 'Không rõ'}'),
                      Text(
                        '${formatCurrency(roomData['price']?.toString() ?? '0')} VND/đêm',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(
                          roomData: {
                            ...roomData,
                            'roomId': roomDoc.id,
                          },
                        ),
                      ),
                    );
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