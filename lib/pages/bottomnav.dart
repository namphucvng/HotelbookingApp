import 'package:bookingapp/pages/history.dart';
import 'package:bookingapp/pages/yeuthich.dart';
import 'package:bookingapp/sceens/dinhvi.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


import 'home.dart';
import 'profile.dart';// Thêm trang khám phá

class Bottomnav extends StatefulWidget {
  final int initialIndex;

  const Bottomnav({super.key, this.initialIndex = 0});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  late int currentTabIndex;

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.initialIndex;
  }

  final List<Widget> pages = [
    Home(),
    YeuThich(),
    DinhViScreen(
      destinationLatLng: LatLng(10.762622, 106.660172), // Tọa độ mẫu
    ),
    History(),                                                                                                                                         
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: active ? Colors.deepPurple : const Color(0xFFB0B0B0),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: active ? Colors.deepPurple : const Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Thanh điều hướng nền
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavButton(
                    icon: Icons.home,
                    label: 'Trang chủ',
                    active: currentTabIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                  _buildNavButton(
                    icon: Icons.search,
                    label: 'Tìm kiếm',
                    active: currentTabIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                  const SizedBox(width: 64), // chừa chỗ cho nút giữa
                  _buildNavButton(
                    icon: Icons.access_time,
                    label: 'Lịch sử',
                    active: currentTabIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                  _buildNavButton(
                    icon: Icons.person,
                    label: 'Hồ sơ',
                    active: currentTabIndex == 4,
                    onTap: () => _onItemTapped(4),
                  ),
                ],
              ),
            ),
          ),

          // Nút nổi "Khám phá"
          Positioned(
            bottom: 32, // Nổi lên trên nền
            left: MediaQuery.of(context).size.width / 2 - 32,
            child: InkWell(
              onTap: () => _onItemTapped(2),
              borderRadius: BorderRadius.circular(36),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Color(0xFF6F8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255,244,241,241),
      body: pages[currentTabIndex],
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
}
