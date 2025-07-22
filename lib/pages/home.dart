import 'package:bookingapp/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'mylist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


// ngoc them phan tien nghi 
const List<Map<String, dynamic>> amenities = [
  {"name": "Free Wi‑Fi",      "icon": Icons.wifi},
  {"name": "Gym",             "icon": Icons.fitness_center},
  {"name": "Bữa sáng",        "icon": Icons.breakfast_dining},
  {"name": "Bể bơi",          "icon": Icons.pool},
  {"name": "Bãi xe",          "icon": Icons.local_parking},
  {"name": "Pet Friendly",    "icon": Icons.pets},
];

// ngoc them phan dich vu
const List<Map<String, String>> services = [
  {
    "name": "Chèo Kayak",
    "image": "https://images.pexels.com/photos/1371360/pexels-photo-1371360.jpeg"
  },
  {
    "name": "Tắm biển",
    "image": "https://images.pexels.com/photos/457882/pexels-photo-457882.jpeg"
  },
  {
    "name": "Lặn ngắm San hô",
    "image": "https://images.pexels.com/photos/3046582/pexels-photo-3046582.jpeg"
  },
  {
    "name": "Dù lượn",
    "image": "https://images.pexels.com/photos/2132116/pexels-photo-2132116.jpeg"
  },
  {
    "name": "Công viên nước",
    "image": "https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg"
  },
];

class _HomeState extends State<Home> {
  int _selectedTab = 0;
  String _searchKeyword = '';

  // ngoc them
  final Set<String> _selectedAmenities = {};   // lưu các tiện nghi đang được chọn
  final Set<String> _selectedServices  = {};  // lưu các dịch vụ đang được chọn

  final List<TabItem> tabs = [
    TabItem(icon: Icons.room, label: 'Phòng'),
    TabItem(icon: Icons.widgets, label: 'Tiện nghi'),
    TabItem(icon: Icons.room_service_outlined, label: 'Dịch vụ'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SearchBar(
            onChanged: (value) {
              setState(() {
                _searchKeyword = value.toLowerCase();
              });
            },
          ),
          Tabs(
            tabs: tabs,
            selectedIndex: _selectedTab,
            onTabSelected: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: _selectedTab == 0
                    ? StaysTabContent(searchKeyword: _searchKeyword)
                    : _selectedTab == 1
                        ? const ExperiencesSection()
                        : const ServicesSection(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatCurrency(String priceString) {
  try {
    final price = int.tryParse(priceString) ?? 0;
    final formatter = NumberFormat("#,###", "vi_VN");
    return '${formatter.format(price).replaceAll(",", ".")}';
  } catch (_) {
    return priceString;
  }
}

class SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const SearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.search, size: 20, color: Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TabItem {
  final IconData icon;
  final String label;

  TabItem({required this.icon, required this.label});
}

class Tabs extends StatelessWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const Tabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int idx = entry.key;
          TabItem tab = entry.value;
          final bool isSelected = idx == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(idx),
              child: Container(
                padding: const EdgeInsets.only(bottom: 8),
                decoration: isSelected
                    ? const BoxDecoration(
                        border: Border(bottom: BorderSide(width: 3, color: Colors.deepPurple)),
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.icon, size: 24, color: isSelected ? Colors.deepPurple : const Color(0xFF666666)),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 12,
                        color: isSelected ? Colors.deepPurple : const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class StaysTabContent extends StatelessWidget {
  final String searchKeyword;

  const StaysTabContent({super.key, required this.searchKeyword});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return FutureBuilder(
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

        final branchesSnapshot = snapshot.data![0];
        final hotelsSnapshot = snapshot.data![1];

        final branches = branchesSnapshot.docs;
        final hotels = hotelsSnapshot.docs;

        final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> branchRoomsMap = {};

        for (var room in hotels) {
          final data = room.data();
          final branchId = data['branchId'];
          if (branchId == null) continue;

          branchRoomsMap.putIfAbsent(branchId, () => []).add(room);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: branches.map((branchDoc) {
            final branchData = branchDoc.data();
            final branchName = branchData['name'] ?? 'Chi nhánh không tên';
            final branchTitle = 'Danh sách các phòng tại $branchName';

            final branchId = branchDoc.id;
            final rooms = branchRoomsMap[branchId] ?? [];

            final filteredRooms = rooms.where((roomDoc) {
              final roomName = (roomDoc.data()['name'] ?? '').toString().toLowerCase();
              return roomName.contains(searchKeyword);
            }).toList();

            final cards = filteredRooms.map((roomDoc) {
              final roomData = roomDoc.data();
              final imageUrls = roomData['imageUrls'] ?? [];
              final String imageUrl = (imageUrls.isNotEmpty) ? imageUrls[0] : '';

              return StayCard(
                imagePath: imageUrl,
                title: roomData['name'] ?? '',
                price: roomData['price']?.toString() ?? '',
                rating: roomData['rating']?.toString() ?? '0.0',
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
              );
            }).toList();

            return ReusableStaysSection(
              title: branchTitle,
              cards: cards.isNotEmpty
                  ? cards.cast<StayCard>()
                  : [const StayCard(
                      imagePath: '',
                      title: 'Chưa có phòng',
                      price: '',
                      rating: '',
                    )],
              branchId: branchId,
              branchName: branchName, // 👈 Thêm dòng này để truyền đúng tên
            );
          }).toList(),
        );
      },
    );
  }
}

class ReusableStaysSection extends StatelessWidget {
  final String title;
  final List<StayCard> cards;
  final String branchId;
  final String branchName;

  const ReusableStaysSection({
    super.key,
    required this.title,
    required this.cards,
    required this.branchId,
    required this.branchName, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, branchId: branchId, branchName: branchName),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => cards[index],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String branchId;
  final String branchName;

  const SectionHeader({
    super.key,
    required this.title,
    required this.branchId,
    required this.branchName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelRoomListPage(
                  branchId: branchId,
                  branchName: branchName,
                ),
              ),
            );
          },
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelRoomListPage(
                  branchId: branchId,
                  branchName: branchName,
                ),
              ),
            );
          },
          child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.deepPurple),
        ),
      ],
    );
  }
}

class StayCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String price;
  final String rating;
  final bool isLiked;
  final VoidCallback? onTap;

  const StayCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.rating,
    this.isLiked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( 
      onTap: onTap,
      child: SizedBox(
        width: 200,
        height: 250,
        child: Card(
          color: const Color.fromARGB(255, 248, 247, 253),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    imagePath,
                    width: 200,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isLiked ? Colors.red.shade900 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatCurrency(price)} VND/đêm',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('★', style: TextStyle(color: Colors.amber)),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExperiencesSection extends StatelessWidget {
  const ExperiencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Trải nghiệm (Nội dung chưa có)', style: TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }
}

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dịch vụ (Nội dung chưa có)', style: TextStyle(fontSize: 16, color: Colors.grey)),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}

