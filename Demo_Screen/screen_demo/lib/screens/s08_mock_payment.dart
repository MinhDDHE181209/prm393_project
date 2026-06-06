import 'package:flutter/material.dart';

class S08MockPaymentSheet extends StatefulWidget {
  final String title;
  const S08MockPaymentSheet({super.key, required this.title});

  @override
  State<S08MockPaymentSheet> createState() => _S08MockPaymentSheetState();
}

class _S08MockPaymentSheetState extends State<S08MockPaymentSheet> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Color(0xff0e0e14), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Mở Khóa Toàn Bộ: ${widget.title}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Giá vật phẩm: 29.000đ (Thanh toán giả lập)", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text("• Mở khóa vĩnh viễn tất cả bài học trong chương.\n• Lưu trữ không giới hạn từ vựng vào SQLite local.\n• Nhận thêm x2 XP khi hoàn thành bài quiz.", style: TextStyle(fontSize: 13, height: 1.6, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff8652f4), minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: isProcessing ? null : () {
              setState(() => isProcessing = true);
              Future.delayed(const Duration(milliseconds: 1500), () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🎉 Mở khóa thành công! Khởi tạo lại CSDL thành công.")));
              });
            },
            child: isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text("Xác Nhận Mua Giả Lập (Mock)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}