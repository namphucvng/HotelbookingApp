import 'package:flutter/material.dart';
import '../models/favorite_provider.dart'; // đúng đường dẫn
import 'package:provider/provider.dart';

class YeuThich extends StatelessWidget {
  const YeuThich({super.key});

  @override
Widget build(BuildContext context) {
  final favoriteProvider = Provider.of<FavoriteProvider>(context);
  final favoritesMap = favoriteProvider.favorites;
  final favoriteList = favoritesMap.entries.toList(); // ✅ chuyển sang List<MapEntry>

  return Scaffold(
    appBar: AppBar(
      title: const Text('Yêu thích'),
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        TextButton(
          onPressed: () {
            favoriteProvider.toggleEdit();
          },
          child: Text(
            favoriteProvider.isEditing ? 'Xong' : 'Chỉnh sửa',
            style: const TextStyle(color: Colors.blue),
          ),
        )
      ],
    ),
    body: favoriteList.isEmpty
        ? const Center(child: Text('Chưa có phòng nào được yêu thích.'))
        : ListView.builder(
            itemCount: favoriteList.length,
            itemBuilder: (context, index) {
              final entry = favoriteList[index];
              final roomId = entry.key;
              final room = entry.value;

              return ListTile(
                leading: Image.network(
                  room['image'] ?? '',
                  width: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(room['name'] ?? ''),
                subtitle: Text('${room['beds'] ?? '?'} giường • ⭐ ${room['rating'] ?? '?'}'),
                trailing: favoriteProvider.isEditing
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          favoriteProvider.removeFavorite(roomId);
                        },
                      )
                    : null,
              );
            },
          ),
  );
}

}