import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'addbranch.dart';
import 'addroom.dart';
import 'booking_approval.dart';
import 'confirm_checkin.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang quản trị'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminCard(
            context,
            icon: Icons.business,
            title: 'Quản lý chi nhánh',
            description: 'Thêm, sửa, xóa các chi nhánh khách sạn.',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBranchPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Icons.meeting_room,
            title: 'Quản lý phòng',
            description: 'Thêm, sửa, xóa các phòng theo chi nhánh.',
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddHotelRoomPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Icons.book_online,
            title: 'Quản lý đơn đặt phòng',
            description: 'Duyệt và xác nhận khách nhận phòng.',
            color: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingApproval()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookingApproval()),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Duyệt đơn'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConfirmCheckInPage()),
                    );
                  },
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Xác nhận checkin'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Icons.logout,
            title: 'Đăng xuất',
            description: 'Thoát khỏi tài khoản admin.',
            color: Colors.red,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: child == null ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(description),
              if (child != null) ...[
                const SizedBox(height: 12),
                child,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
