import 'package:flutter/material.dart';

void showTermsAndPolicyBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const TermsAndPolicyContent(),
  );
}

class TermsAndPolicyContent extends StatelessWidget {
  const TermsAndPolicyContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: const [
              Center(
                child: Text(
                  'Chính sách & Điều khoản Sử dụng',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Cập nhật lần cuối: 01/08/2025\n\n'
                'Chào mừng bạn đến với ứng dụng BookingApp. Khi sử dụng ứng dụng này, bạn đồng ý với các điều khoản và điều kiện sau:\n',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              _SectionTitle('1. Thu thập & Bảo mật Thông tin'),
              _SectionText(
                '• Chúng tôi thu thập các thông tin như: họ tên, email, số điện thoại và các thông tin liên quan đến việc đặt lịch.\n'
                '• Dữ liệu được lưu trữ an toàn và chỉ dùng cho mục đích cải thiện dịch vụ.\n'
                '• Chúng tôi cam kết không chia sẻ thông tin cá nhân của bạn cho bên thứ ba khi chưa được sự đồng ý.',
              ),
              _SectionTitle('2. Quy định khi sử dụng ứng dụng'),
              _SectionText(
                '• Người dùng cần cung cấp thông tin chính xác khi đăng ký và đặt lịch.\n'
                '• Không sử dụng ứng dụng vào các mục đích trái pháp luật hoặc gian lận.\n'
                '• Người dùng chịu trách nhiệm cho tất cả hoạt động diễn ra dưới tài khoản của mình.',
              ),
              _SectionTitle('3. Hủy & Hoàn tiền (nếu áp dụng)'),
              _SectionText(
                '• Việc hủy đặt lịch cần thực hiện trước thời gian quy định (tùy theo dịch vụ cụ thể).\n'
                '• Chính sách hoàn tiền (nếu có) sẽ được hiển thị rõ tại thời điểm đặt lịch.',
              ),
              _SectionTitle('4. Quyền & Trách nhiệm của BookingApp'),
              _SectionText(
                '• Chúng tôi có quyền từ chối hoặc tạm ngưng tài khoản vi phạm điều khoản.\n'
                '• BookingApp có thể tạm dừng dịch vụ để bảo trì hoặc nâng cấp mà không cần thông báo trước.\n'
                '• Mọi thông báo sẽ được gửi qua email hoặc hiển thị trên ứng dụng.',
              ),
              _SectionTitle('5. Thay đổi điều khoản'),
              _SectionText(
                '• Điều khoản sử dụng có thể được cập nhật bất kỳ lúc nào.\n'
                '• Việc tiếp tục sử dụng ứng dụng sau khi điều khoản thay đổi đồng nghĩa với việc bạn đã đồng ý với thay đổi đó.',
              ),
              _SectionTitle('6. Liên hệ'),
              _SectionText(
                'Nếu bạn có bất kỳ câu hỏi nào liên quan đến chính sách & điều khoản sử dụng, vui lòng liên hệ với chúng tôi qua:\n'
                '• Email hỗ trợ: support@bookingapp.vn\n'
                '• Hotline: 1900 123 456',
              ),
              SizedBox(height: 24),
              Text(
                'Cảm ơn bạn đã sử dụng BookingApp.\nChúng tôi cam kết mang lại trải nghiệm đặt lịch an toàn và thuận tiện nhất.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.5),
    );
  }
}
