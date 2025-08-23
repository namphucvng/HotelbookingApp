import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AddHotelRoomPage extends StatefulWidget {
  const AddHotelRoomPage({super.key});

  @override
  State<AddHotelRoomPage> createState() => _AddHotelRoomPageState();
}

class _AddHotelRoomPageState extends State<AddHotelRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();

  List<File> _roomImages = [];
  bool _isLoading = false;

  final List<String> selectedAmenities = [];
  final List<Map<String, dynamic>> foodList = [];

  final List<String> allAmenities = [
    'Wifi', 'Gym', 'Bữa sáng', 'Bể bơi', 'Chỗ đậu xe',
    'Pet Friendly', 'Giặt ủi', 'Bar', 'Xe đưa đón', 'Spa',
  ];

  List<DocumentSnapshot> _roomTypes = [];
  List<DocumentSnapshot> _branches = [];

  String? _selectedRoomTypeId;
  String? _selectedBranchId;

  // Thay bằng API Key của bạn từ ImgBB
  final String imgbbApiKey = '361f12986317858811135f18c5a01a6b';

  @override
  void initState() {
    super.initState();
    _fetchRoomTypes();
    _fetchBranches();
  }

  Future<void> _fetchRoomTypes() async {
    final snapshot = await _firestore.collection('roomTypes').orderBy('name').get();
    setState(() {
      _roomTypes = snapshot.docs;
    });
  }

  Future<void> _fetchBranches() async {
    final snapshot = await _firestore.collection('branches').orderBy('name').get();
    setState(() {
      _branches = snapshot.docs;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await ImagePicker().pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          _roomImages = picked.map((e) => File(e.path)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi chọn ảnh: $e')));
    }
  }

  Future<List<String>> _uploadImages(List<File> images) async {
  List<String> urls = [];

  for (var image in images) {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      image.path,
      minWidth: 800, // giảm kích thước ảnh
      minHeight: 800,
      quality: 75, // giảm chất lượng ảnh xuống 75%
    );

    if (compressedBytes == null) {
      throw Exception('Lỗi nén ảnh');
    }

    final base64Image = base64Encode(compressedBytes);

    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');
    final response = await http.post(uri, body: {
      'image': base64Image,
    }).timeout(const Duration(seconds: 15)); // thêm timeout

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final imageUrl = data['data']['url'];
      urls.add(imageUrl);
    } else {
      throw Exception('Upload thất bại: ${response.body}');
    }
  }

  return urls;
}

  void _addFood() async {
    final nameCtrl = TextEditingController();
    File? foodImage;
    bool isUploading = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickImage() async {
              final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (picked != null) {
                setState(() => foodImage = File(picked.path));
              }
            }

            Future<void> uploadAndAddFood() async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty || foodImage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tên món và chọn hình ảnh')),
                );
                return;
              }

              setState(() => isUploading = true);

              try {
                final urls = await _uploadImages([foodImage!]);
                Navigator.pop(context, {'name': name, 'image': urls.first});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải ảnh: $e')));
              } finally {
                setState(() => isUploading = false);
              }
            }

            return AlertDialog(
              title: const Text('Thêm món ăn'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên món'),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: foodImage == null
                          ? const Center(child: Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey))
                          : Image.file(foodImage!, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : uploadAndAddFood,
                  child: isUploading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        foodList.add(result); // {name: ..., image: ...}
      });
    }
  }

  void _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;
    if (_roomImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn hình ảnh")));
      return;
    }
    if (_selectedRoomTypeId == null || _selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn loại phòng và chi nhánh")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrls = await _uploadImages(_roomImages);
      final selectedRoomType = _roomTypes.firstWhere((doc) => doc.id == _selectedRoomTypeId);
      final selectedBranch = _branches.firstWhere((b) => b.id == _selectedBranchId);

      final snapshot = await _firestore
          .collection('hotels')
          .orderBy('roomId', descending: true)
          .limit(1)
          .get();

      await _firestore.collection('hotels').add({
        'name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'branch': selectedBranch['name'],
        'branchId': _selectedBranchId,
        'type': selectedRoomType['name'],
        'typeId': _selectedRoomTypeId,
        'price': int.tryParse(priceController.text.trim()) ?? 0,
        'description': descriptionController.text.trim(),
        'imageUrls': imageUrls,
        'latitude': double.tryParse(latController.text.trim()) ?? 0.0,
        'longitude': double.tryParse(lngController.text.trim()) ?? 0.0,
        'amenities': selectedAmenities,
        'foods': foodList.map((f) => {
          'name': f['name'],
          'image': f['image'],
        }).toList(),
        'rating': 0.0,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm phòng')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm phòng mới')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: AbsorbPointer(
                absorbing: _isLoading,
                child: Opacity(
                  opacity: _isLoading ? 0.5 : 1.0,
                  child: Column(children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: _roomImages.isNotEmpty
                          ? SizedBox(
                              height: 200,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _roomImages.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _roomImages[index],
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _roomImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          : Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                              child: const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey)),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Tên phòng'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Không được để trống';
                        if (!RegExp(r"^[a-zA-Z0-9\s\u00C0-\u1EF9]+$").hasMatch(value)) return 'Không chứa ký tự đặc biệt';
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Chi nhánh'),
                      value: _selectedBranchId,
                      items: _branches.map((doc) {
                        final name = doc['name'] ?? 'Không rõ';
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBranchId = value;
                          final selected = _branches.firstWhere((b) => b.id == value);
                          locationController.text = selected['address'] ?? '';
                          latController.text = (selected['latitude'] ?? 0.0).toString();
                          lngController.text = (selected['longitude'] ?? 0.0).toString();
                        });
                      },
                      validator: (value) => value == null ? 'Vui lòng chọn chi nhánh' : null,
                    ),
                    TextFormField(controller: locationController, readOnly: true, decoration: const InputDecoration(labelText: 'Địa điểm')),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Loại phòng'),
                      value: _selectedRoomTypeId,
                      items: _roomTypes.map((doc) {
                        final name = doc['name'] ?? 'Không rõ';
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedRoomTypeId = value),
                      validator: (value) => value == null ? 'Vui lòng chọn loại phòng' : null,
                    ),
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Giá (VNĐ)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Không được để trống';
                        final price = int.tryParse(value);
                        if (price == null || price <= 0) return 'Giá phải lớn hơn 0';
                        return null;
                      },
                    ),
                    TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Không để trống' : null),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: latController, decoration: const InputDecoration(labelText: 'Vĩ độ'), readOnly: true)),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: lngController, decoration: const InputDecoration(labelText: 'Kinh độ'), readOnly: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Align(alignment: Alignment.centerLeft, child: Text('Tiện nghi:', style: TextStyle(fontWeight: FontWeight.bold))),
                    Wrap(
                      spacing: 8,
                      children: allAmenities.map((amenity) {
                        return FilterChip(
                          label: Text(amenity),
                          selected: selectedAmenities.contains(amenity),
                          onSelected: (selected) {
                            setState(() {
                              selected ? selectedAmenities.add(amenity) : selectedAmenities.remove(amenity);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Danh sách món ăn:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...foodList.asMap().entries.map((entry) {
                      int index = entry.key;
                      var f = entry.value;

                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (f['image'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(f['image'], height: 80, width: 80, fit: BoxFit.cover),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(f['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  foodList.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                    TextButton.icon(onPressed: _addFood, icon: const Icon(Icons.add), label: const Text('Thêm món ăn')),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveHotel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: const Text('LƯU PHÒNG'),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
