import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBookingPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final String docId;

  const EditBookingPage({super.key, required this.bookingData, required this.docId});

  @override
  State<EditBookingPage> createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  late DateTime _checkIn;
  late DateTime _checkOut;
  late int _adults;
  late int _children;
  late int _rooms;
  late int _pricePerRoom;
  late int _total;

  final int maxRooms = 5;
  final int maxPeople = 10;

  int get _minRequiredRooms => (_adults / 2).ceil();

  @override
  void initState() {
    super.initState();
    final checkInData = widget.bookingData['checkIn'];
    final checkOutData = widget.bookingData['checkOut'];

    _checkIn = checkInData is DateTime
        ? checkInData
        : (checkInData as Timestamp?)?.toDate() ?? DateTime.now();
    _checkOut = checkOutData is DateTime
        ? checkOutData
        : (checkOutData as Timestamp?)?.toDate() ?? _checkIn.add(const Duration(days: 1));

    _adults = widget.bookingData['adults'] ?? 1;
    _children = widget.bookingData['children'] ?? 0;
    _rooms = widget.bookingData['rooms'] ?? 1;

    _pricePerRoom = widget.bookingData['total'] ~/ (_rooms * (_checkOut.difference(_checkIn).inDays).clamp(1, 100));
    _recalculateTotal();
  }

  void _recalculateTotal() {
    final nights = _checkOut.difference(_checkIn).inDays;
    if (nights > 0) {
      setState(() {
        _total = _rooms * _pricePerRoom * nights;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _checkIn, end: _checkOut),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      if (picked.start == picked.end) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ngày trả phòng phải sau ngày nhận phòng.")),
        );
        return;
      }

      setState(() {
        _checkIn = picked.start;
        _checkOut = picked.end;
      });
      _recalculateTotal();
    }
  }

  Future<void> _saveBooking() async {
    if (_checkIn.isAtSameMomentAs(_checkOut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ngày trả phòng phải sau ngày nhận phòng.")),
      );
      return;
    }

    if (_rooms < _minRequiredRooms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cần ít nhất $_minRequiredRooms phòng cho $_adults người lớn.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('dat_lich')
          .doc(widget.docId)
          .update({
        'checkIn': Timestamp.fromDate(_checkIn),
        'checkOut': Timestamp.fromDate(_checkOut),
        'adults': _adults,
        'children': _children,
        'rooms': _rooms,
        'totalAmount': _total,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,###", "vi_VN");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa đặt phòng',
          style: TextStyle(color: Colors.deepPurple),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (widget.bookingData['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.bookingData['image'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(height: 180, child: Center(child: Icon(Icons.broken_image, size: 40))),
                ),
              ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                widget.bookingData['roomName'] ?? 'Tên phòng không rõ',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Ngày nhận - Ngày trả'),
              subtitle: Text(
                '${DateFormat('dd/MM/yyyy').format(_checkIn)} - ${DateFormat('dd/MM/yyyy').format(_checkOut)}',
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: _selectDateRange,
            ),
            const SizedBox(height: 10),
            _buildStepper(
              'Người lớn',
              _adults,
              (val) {
                if (val >= 1 && val <= maxPeople) {
                  setState(() => _adults = val);
                  if (_rooms < _minRequiredRooms) {
                    _rooms = _minRequiredRooms;
                  }
                  _recalculateTotal();
                }
              },
            ),
            _buildStepper(
              'Trẻ em',
              _children,
              (val) {
                if (val >= 0 && val <= maxPeople) {
                  setState(() => _children = val);
                }
              },
            ),
            _buildStepper(
              'Số phòng',
              _rooms,
              (val) {
                if (val >= _minRequiredRooms && val <= maxRooms) {
                  setState(() => _rooms = val);
                  _recalculateTotal();
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Tổng tiền: ${currencyFormat.format(_total)} VND',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Lưu thay đổi',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveBooking,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(String label, int value, Function(int) onChanged) {
    final isAdults = label == 'Người lớn';
    final isRooms = label == 'Số phòng';

    final canDecrease = isRooms
        ? value > _minRequiredRooms
        : isAdults
            ? value > 1
            : value > 0;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(
                onPressed: canDecrease ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$value', style: const TextStyle(fontSize: 16)),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
