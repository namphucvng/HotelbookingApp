import 'package:flutter/material.dart';
import 'dart:async';
import 'signup.dart';
import 'login.dart';
import 'package:flutter/gestures.dart';

void main() {
  runApp(const Start());
}

class Start extends StatelessWidget {
  const Start({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Start',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  bool _isExpandedLeft = false;
  bool _isExpandedRight = false;
  
  static const Color primaryColor = Colors.deepPurple;
  static const Color readMoreColor = Color(0xFFF7A600);
  static const double borderRadius = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: double.infinity,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Slider ảnh tự động
                      _SliderWidget(height: MediaQuery.of(context).size.height * 0.45),
                      const SizedBox(height: 24),

                      // Grid with images and text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left block
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    'images/view15.jpg',
                                    width: double.infinity,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 11,
                                      height: 1.3,
                                      color: Color(0xFF444444),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _isExpandedLeft
                                            ? 'Nằm nép mình bên bãi biển hoang sơ của bán đảo Sơn Trà, InterContinental Danang Sun Peninsula Resort là khu nghỉ dưỡng 5 sao đẳng cấp quốc tế. Với thiết kế kiến trúc độc đáo của Bill Bensley và tầm nhìn hướng biển tuyệt đẹp, nơi đây là lựa chọn lý tưởng cho kỳ nghỉ thư giãn sang trọng giữa thiên nhiên.'
                                            : 'Nằm nép mình bên bãi biển hoang sơ của bán đảo Sơn Trà, InterContinental Danang Sun Peninsula Resort là khu nghỉ dưỡng 5 sao đẳng cấp quốc tế...',
                                      ),
                                      TextSpan(
                                        text: _isExpandedLeft ? ' Thu gọn' : ' Đọc thêm',
                                        style: const TextStyle(
                                          color: readMoreColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            setState(() {
                                              _isExpandedLeft = !_isExpandedLeft;
                                            });
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Right block
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    'images/view16.jpg',
                                    width: double.infinity,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 10,
                                      height: 1.3,
                                      color: Color(0xFF444444),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _isExpandedRight
                                            ? 'Tại DiMeiHome, du khách được trải nghiệm ẩm thực tinh hoa tại nhà hàng La Maison 1888, thư giãn tuyệt đối tại HARNN Heritage Spa, và tận hưởng những phút giây yên bình với thiên nhiên. Đây là điểm đến hoàn hảo để khám phá vẻ đẹp văn hóa và thiên nhiên của miền Trung Việt Nam.'
                                            : 'Tại DiMeiHome, du khách được trải nghiệm ẩm thực tinh hoa tại nhà hàng La Maison 1888...',
                                      ),
                                      TextSpan(
                                        text: _isExpandedRight ? ' Thu gọn' : ' Đọc thêm',
                                        style: const TextStyle(
                                          color: readMoreColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            setState(() {
                                              _isExpandedRight = !_isExpandedRight;
                                            });
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LogIn()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          child: const Text('ĐĂNG NHẬP'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Signup text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                          children: [
                            const TextSpan(text: 'Bạn chưa có tài khoản? '),
                            TextSpan(
                              text: 'Đăng ký',
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------
// Widget hiển thị slider ảnh tự động
// -----------------------------
class _SliderWidget extends StatefulWidget {
  final double height;

  const _SliderWidget({Key? key, required this.height}) : super(key: key);

  @override
  State<_SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<_SliderWidget> {
  static const int _infiniteLoopOffset = 1000;
  late final PageController _pageController;
  final List<String> imageUrls = [
    'images/view7.jpg',
    'images/view8.jpg',
    'images/view1.png',
    'images/view14.jpg',
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _infiniteLoopOffset);

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, index) {
            final realIndex = index % imageUrls.length;
            return Image.asset(
              imageUrls[realIndex],
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
        ),
      ),
    );
  }
}

