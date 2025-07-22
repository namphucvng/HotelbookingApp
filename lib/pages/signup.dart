  import 'package:flutter/material.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:bookingapp/pages/login.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(const SignUp());
  }

  class SignUp extends StatelessWidget {
    const SignUp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Đăng ký Tài khoản',
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Inter',
        ),
        home: const SignUpPage(),
        debugShowCheckedModeBanner: false,
      );
    }
  }

  class SignUpPage extends StatefulWidget {
    const SignUpPage({Key? key}) : super(key: key);

    @override
    State<SignUpPage> createState() => _SignUpPageState();
  }

  class _SignUpPageState extends State<SignUpPage> {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();

    bool _agree = false;
    bool _isLoading = false;
    bool _obscurePassword = true;
    bool _obscureConfirmPassword = true;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Image.asset('images/logo1.png', width: 64, height: 64),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'Tạo ',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                            children: [
                              TextSpan(text: 'Tài khoản', style: TextStyle(color: Colors.deepPurple)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Điền thông tin của bạn bên dưới hoặc đăng ký bằng tài khoản mạng xã hội.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Color(0xFF7A7A7A)),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(_usernameController, Icons.person_outline, 'Tên người dùng'),
                            const SizedBox(height: 14),
                            _buildTextField(_emailController, Icons.email_outlined, 'Email',
                                keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 14),
                            _buildTextField(_phoneController, Icons.phone_outlined, 'Số điện thoại',
                                keyboardType: TextInputType.phone),
                            const SizedBox(height: 14),
                            _buildTextField(
                              _passwordController,
                              Icons.lock_outline,
                              'Mật khẩu',
                              obscureText: _obscurePassword,
                              toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                                hintText: 'Nhập lại mật khẩu',
                                hintStyle: const TextStyle(fontSize: 13),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng xác nhận lại mật khẩu';
                                } else if (value != _passwordController.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: _agree,
                                  onChanged: (value) => setState(() => _agree = value ?? false),
                                  activeColor: const Color(0xFF6B7AFA),
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Tôi xác nhận đã đọc và đồng ý với ',
                                      style: const TextStyle(fontSize: 12, color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: 'Chính sách & Điều khoản sử dụng',
                                          style: const TextStyle(
                                              color: Colors.deepPurple, decoration: TextDecoration.underline),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  'ĐĂNG KÝ',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: const [
                          Expanded(child: Divider(color: Color(0xFFCFCFFF))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('Hoặc', style: TextStyle(fontSize: 12, color: Color(0xFF7A7A7A))),
                          ),
                          Expanded(child: Divider(color: Color(0xFFCFCFFF))),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('images/icon_fb.png', width: 32),
                          const SizedBox(width: 24),
                          Image.asset('images/icon_int.png', width: 32),
                          const SizedBox(width: 24),
                          Image.asset('images/icon_gg.png', width: 32),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Bạn đã có tài khoản? ',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF7A7A7A)),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => const LogIn())),
                              child: const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  //color: Color(0xFF5A5AC9),
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontSize: 12,
                                ),
                              ),
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

    Widget _buildTextField(
      TextEditingController controller,
      IconData icon,
      String hintText, {
      TextInputType keyboardType = TextInputType.text,
      bool obscureText = false,
      VoidCallback? toggleVisibility,
    }) {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          suffixIcon: toggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Vui lòng nhập $hintText' : null,
      );
    }


    Future<void> _signUp() async {
      if (!_formKey.currentState!.validate()) return;
      if (!_agree) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn phải đồng ý với điều khoản sử dụng.')));
        return;
      }
      setState(() => _isLoading = true);
      try {
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
          'id': userCred.user!.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'createdAt': Timestamp.now(),
          'role': 'user',
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công.')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LogIn()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.message}')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra.')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
