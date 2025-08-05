import 'package:bookingapp/pages/bottomnav.dart';
import 'package:bookingapp/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StyledDropdown extends StatelessWidget {
  final int value;
  final List<int> items;
  final void Function(int?) onChanged;
  final String label;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          style: const TextStyle(fontSize: 16, color: Colors.black),
          items: items
              .map((item) => DropdownMenuItem<int>(
                    value: item,
                    child: Text('$item'),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}


class DatLichScreen extends StatefulWidget {
  final Map<String, dynamic> roomData;

  const DatLichScreen({super.key, required this.roomData});

  @override
  State<DatLichScreen> createState() => _DatLichScreenState();
}


class _DatLichScreenState extends State<DatLichScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  String name = '';
  int price = 0;
  String formattedPrice = '';


  DateTime? _checkInDate, _checkOutDate;
  TimeOfDay? _checkInTime, _checkOutTime;
  int _adults = 2, _children = 1, _rooms = 1;
  final int _pricePerPerson = 100000;

  int get _numberOfNights {
    if (_checkInDate == null || _checkOutDate == null) return 1;
    return _checkOutDate!.difference(_checkInDate!).inDays.clamp(1, 365);
  }

  int get _totalAmount {
    return price * _rooms * _numberOfNights;
  }



  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    name = widget.roomData['name'] ?? 'Không có tên';
    price = widget.roomData['price'] ?? 0;
    formattedPrice = NumberFormat("#,###", "vi_VN").format(price);
  }

  void _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          setState(() {
            _nameController.text = userData['username'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
          });
        }
      }
    }
  }

  int get _totalPeople => _adults + _children;

  bool _validateBookingInfo() {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày nhận và ngày trả phòng')),
      );
      return false;
    }
    if (_totalPeople <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số lượng người không hợp lệ')),
      );
      return false;
    }
    if (_rooms <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số lượng phòng phải lớn hơn 0')),
      );
      return false;
    }
    return true;
  }

  void _adjustRoomCount() {
    const maxAdultsPerRoom = 2;

    int requiredRoomsForAdults = (_adults / maxAdultsPerRoom).ceil();

    if (requiredRoomsForAdults > _rooms) {
      setState(() {
        _rooms = requiredRoomsForAdults;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Số phòng đã được cập nhật tự động thành $requiredRoomsForAdults dựa trên số người lớn.')),
      );
    }
  }


  void _selectDateTime({required bool isCheckIn}) async {
    if (!mounted) return;

    final pickedDate = await showDatePicker(
      context: Navigator.of(context, rootNavigator: true).context,
      locale: const Locale('vi', 'VN'),
      initialDate: isCheckIn ? (_checkInDate ?? DateTime.now()) : (_checkOutDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: Navigator.of(context, rootNavigator: true).context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    if (!mounted) return;

    setState(() {
      final dateTimeStr = '${DateFormat('dd/MM/yyyy').format(pickedDate)} ${pickedTime.format(context)}';

      if (isCheckIn) {
        _checkInDate = pickedDate;
        _checkInTime = pickedTime;
        _checkInController.text = dateTimeStr;

        // Nếu ngày trả phòng nhỏ hơn ngày nhận, thì cập nhật lại cho hợp lệ
        if (_checkOutDate != null && pickedDate.isAfter(_checkOutDate!)) {
          _checkOutDate = pickedDate;
          _checkOutTime = pickedTime;
          _checkOutController.text = dateTimeStr;
        }
      } else {
        if (_checkInDate != null && pickedDate.isBefore(_checkInDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ngày trả không được trước ngày nhận')),
          );
          return;
        }
        if (_checkInDate != null &&
            pickedDate.year == _checkInDate!.year &&
            pickedDate.month == _checkInDate!.month &&
            pickedDate.day == _checkInDate!.day) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ngày trả không được trùng với ngày nhận. Vui lòng chọn lại.')),
          );
          return;
        }
        _checkOutDate = pickedDate;
        _checkOutTime = pickedTime;
        _checkOutController.text = dateTimeStr;
      }
    });
  }

  void _showQuantitySheet(String title, int current, Function(int) onSave) {
    final isRoom = title == 'Phòng';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        int selected = current;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StyledDropdown(
                    value: selected,
                    items: List.generate(isRoom ? 5 : 10, (i) => i + (isRoom ? 1 : 0)),
                    onChanged: (val) => setModalState(() => selected = val ?? selected),
                    label: 'Chọn số $title',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      onSave(selected);
                      Navigator.pop(context);
                      _adjustRoomCount();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Xác nhận'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _confirmBooking() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 40, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              'Xác nhận đặt phòng',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn có chắc chắn muốn đặt phòng này với tổng tiền là\n${NumberFormat("#,###", "vi_VN").format(_totalAmount)} VND?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Huỷ', style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _saveBooking();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Xác nhận', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _saveBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final checkIn = _checkInDate != null && _checkInTime != null
        ? DateTime(_checkInDate!.year, _checkInDate!.month, _checkInDate!.day, _checkInTime!.hour, _checkInTime!.minute)
        : null;

    final checkOut = _checkOutDate != null && _checkOutTime != null
        ? DateTime(_checkOutDate!.year, _checkOutDate!.month, _checkOutDate!.day, _checkOutTime!.hour, _checkOutTime!.minute)
        : null;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userName = userDoc.data()?['username'] ?? 'Ẩn danh';
    // In dữ liệu debug trước khi lưu
    print('roomData: ${widget.roomData}');

    await FirebaseFirestore.instance.collection('dat_lich').add({
      'userId': user.uid,
      'userName': userName,
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'checkIn': checkIn != null ? Timestamp.fromDate(checkIn) : null,
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut) : null,
      'adults': _adults,
      'children': _children,
      'rooms': _rooms,
      'totalAmount': _totalAmount,
      'roomName': widget.roomData['name'],
      'roomId': widget.roomData['roomId'],
      'image': (widget.roomData['image'] != null && widget.roomData['image'].toString().isNotEmpty)
          ? widget.roomData['image']
          : 'https://via.placeholder.com/600x400.png?text=No+Image',
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookingSuccessScreen()),
      );
    }
  }

  Widget _buildReadOnlyField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Đặt phòng',
        style: TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView(
          children: [
            _buildReadOnlyField(_nameController, 'Tên người dùng'),
            _buildReadOnlyField(_phoneController, 'Số điện thoại'),
            _buildReadOnlyField(_emailController, 'Email'),
                  const SizedBox(height: 14),
                    const Text(
                      "Thông tin phòng",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tên phòng: $name',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Giá phòng: $formattedPrice VND/đêm',
                      style: const TextStyle(fontSize: 16),
                    ),
            const SizedBox(height: 14),
            const Text("Thông tin đặt phòng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showQuantitySheet('Người lớn', _adults, (val) {
                      setState(() => _adults = val);
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('Người lớn ($_adults)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showQuantitySheet('Trẻ em', _children, (val) {
                      setState(() => _children = val);
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('Trẻ em ($_children)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showQuantitySheet('Phòng', _rooms, (val) {
                      setState(() => _rooms = val);
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('Phòng ($_rooms)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateTime(isCheckIn: true),
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _checkInController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Ngày nhận phòng',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateTime(isCheckIn: false),
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _checkOutController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Ngày trả phòng',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_checkInDate != null && _checkOutDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Số ngày đặt phòng: $_numberOfNights ngày',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${NumberFormat("#,###", "vi_VN").format(_totalAmount)} VND',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_validateBookingInfo()) {
                  _confirmBooking();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'ĐẶT PHÒNG',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, color: Colors.deepPurple, size: 100),
                const SizedBox(height: 24),
                const Text(
                  'Đặt phòng thành công!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi. Đơn đặt phòng của bạn đã được ghi nhận.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.assignment),
                  label: const Text('Xem đặt phòng của tôi', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Bottomnav(initialIndex: 3)),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // TODO: Thay đổi theo route trang chủ
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Bottomnav()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Về trang chủ', style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


