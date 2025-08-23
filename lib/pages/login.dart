import 'package:bookingapp/pages/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:bookingapp/pages/signup.dart';
import 'package:bookingapp/pages/reset_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const LogIn());
}

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LogInPage(),
    );
  }
}

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  void _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('saved_email') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email và mật khẩu")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng nhập thành công")),
      );

      // ✅ Chuyển hướng sang Trang Chủ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Bottomnav()),
      );
      // TODO: Điều hướng đến trang chính
    } on FirebaseAuthException catch (e) {
      String message = "Đăng nhập thất bại.";
      if (e.code == 'wrong-password') {
        message = "Sai mật khẩu.";
      } else if (e.code == 'user-not-found') {
        message = "Tài khoản không tồn tại.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return; // user cancel

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        // 👉 ĐẢM BẢO users/{uid} tồn tại
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _ensureUserDocument(user);
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng nhập Google thành công")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Bottomnav()),
        );
      } catch (e) {
      debugPrint("Lỗi đăng nhập Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng nhập bằng Google thất bại")),
      );
    }
  }

  Future<void> _ensureUserDocument(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await ref.get();

    final data = {
      'uid': user.uid,
      'email': user.email ?? '',
      'username': user.displayName ?? '',  // tên từ Google
      'avatarUrl': user.photoURL ?? '',    // avatar từ Google
      'provider': 'google',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (snap.exists) {
      await ref.set(data, SetOptions(merge: true));
    } else {
      await ref.set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 375),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  Center(
                    child: Image.asset('images/logomain.png', width: 64, height: 64),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Chào mừng ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: Color(0xFF1A1A1A),
                        ),
                        children: [
                          TextSpan(
                            text: 'trở lại',
                            style: TextStyle(color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    'Đăng nhập để tiếp tục hành trình cùng chúng tôi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF7A7A7A)),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      labelStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                            activeColor: Colors.deepPurple,
                          ),
                          const Text('Ghi nhớ tôi', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                          );
                        },
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text(
                              'ĐĂNG NHẬP',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white, // <-- chữ màu trắng
                              ),
                            ),
                    )
                  ),

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () => signInWithGoogle(context),
                      // onPressed: () {
                        
                      // },
                      icon: Image.asset("images/icon_gg.png", width: 20, height: 20),
                      label: const Text(
                        'Đăng nhập với Google',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Bạn chưa có tài khoản? ',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF7A7A7A)),
                        children: [
                          TextSpan(
                            text: 'Đăng ký',
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUp()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Image.asset(
                      "images/booking2.jpg",
                      width: 300, // chỉnh nhỏ hơn nếu muốn
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
