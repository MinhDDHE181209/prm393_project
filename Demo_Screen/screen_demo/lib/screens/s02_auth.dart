import 'package:flutter/material.dart';

class S02AuthScreen extends StatefulWidget {
  const S02AuthScreen({super.key});

  @override
  State<S02AuthScreen> createState() => _S02AuthScreenState();
}

class _S02AuthScreenState extends State<S02AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  bool obscureText = true;

  void _submitAuth() {
    setState(() => isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => isLoading = false);
        Navigator.pushReplacementNamed(context, '/main_tabs');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isLogin ? "Chào Mừng Trở Lại 🔐" : "Tạo Tài Khoản Mới ✨", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text("Vui lòng nhập thông tin để tiếp tục học OrigamiLearn.", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: ChoiceChip(label: const Center(child: Text("Đăng Nhập")), selected: isLogin, onSelected: (_) => setState(() => isLogin = true))),
                const SizedBox(width: 12),
                Expanded(child: ChoiceChip(label: const Center(child: Text("Đăng Ký")), selected: !isLogin, onSelected: (_) => setState(() => isLogin = false))),
              ],
            ),
            const SizedBox(height: 30),
            if (!isLogin) ...[
              TextFormField(decoration: InputDecoration(labelText: "Tên người dùng", filled: true, fillColor: const Color(0xff0e0e14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 16),
            ],
            TextFormField(decoration: InputDecoration(labelText: "Email", filled: true, fillColor: const Color(0xff0e0e14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: "Mật khẩu", filled: true, fillColor: const Color(0xff0e0e14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => obscureText = !obscureText)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4083ff), minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: isLoading ? null : _submitAuth,
              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isLogin ? "Đăng Nhập" : "Đăng Ký Thành Viên", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), side: const BorderSide(color: Color(0xff202030)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
              label: const Text("Tiếp tục với Google Auth", style: TextStyle(color: Colors.white)),
              onPressed: _submitAuth,
            )
          ],
        ),
      ),
    );
  }
}