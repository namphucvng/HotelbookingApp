import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBranchPage extends StatefulWidget {
  const AddBranchPage({super.key});

  @override
  State<AddBranchPage> createState() => _AddBranchPageState();
}

class _AddBranchPageState extends State<AddBranchPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();

  bool _isLoading = false;

  void _saveBranch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('branches').add({
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'latitude': double.parse(latController.text.trim()),
        'longitude': double.parse(lngController.text.trim()),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm chi nhánh')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm chi nhánh')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên chi nhánh'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Không để trống' : null,
            ),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Không để trống' : null,
            ),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: latController,
                  decoration: const InputDecoration(labelText: 'Vĩ độ'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Không để trống';
                    final lat = double.tryParse(v.trim());
                    if (lat == null || lat < -90 || lat > 90) return 'Vĩ độ từ -90 đến 90';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: lngController,
                  decoration: const InputDecoration(labelText: 'Kinh độ'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Không để trống';
                    final lng = double.tryParse(v.trim());
                    if (lng == null || lng < -180 || lng > 180) return 'Kinh độ từ -180 đến 180';
                    return null;
                  },
                ),
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveBranch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Màu nền nút
                  foregroundColor: Colors.white,       // Màu chữ
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LƯU CHI NHÁNH'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
