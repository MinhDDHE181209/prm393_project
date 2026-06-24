import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';
import '../screens/home_screen.dart';
import 'package:go_router/go_router.dart';

enum _FormStatus { idle, loading, error }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _authService = AuthService();

  // ── Login form ──
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // ── Register form ──
  final _registerFormKey = GlobalKey<FormState>();
  final _registerNameCtrl = TextEditingController();
  final _registerEmailCtrl = TextEditingController();
  final _registerPasswordCtrl = TextEditingController();

  _FormStatus _status = _FormStatus.idle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Đổi tab thì xoá lỗi cũ, tránh lẫn lỗi giữa 2 form.
      setState(() {
        _status = _FormStatus.idle;
        _errorMessage = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _registerNameCtrl.dispose();
    _registerEmailCtrl.dispose();
    _registerPasswordCtrl.dispose();
    super.dispose();
  }



void _goHome() {
  if (!mounted) return;
  context.go('/home');
}


  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() {
      _status = _FormStatus.loading;
      _errorMessage = null;
    });
    try {
      await _authService.signInWithEmail(
        email: _loginEmailCtrl.text,
        password: _loginPasswordCtrl.text,
      );
      _goHome();
    } on AuthException catch (e) {
      setState(() {
        _status = _FormStatus.error;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _status = _FormStatus.error;
        _errorMessage = 'Đã có lỗi không xác định. Vui lòng thử lại.';
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() {
      _status = _FormStatus.loading;
      _errorMessage = null;
    });
    try {
      await _authService.register(
        email: _registerEmailCtrl.text,
        password: _registerPasswordCtrl.text,
        displayName: _registerNameCtrl.text,
      );
      _goHome();
    } on AuthException catch (e) {
      setState(() {
        _status = _FormStatus.error;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _status = _FormStatus.error;
        _errorMessage = 'Đã có lỗi không xác định. Vui lòng thử lại.';
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _status = _FormStatus.loading;
      _errorMessage = null;
    });
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        // Người dùng tự huỷ — không phải lỗi, chỉ về trạng thái idle.
        setState(() => _status = _FormStatus.idle);
        return;
      }
      _goHome();
    } on AuthException catch (e) {
      setState(() {
        _status = _FormStatus.error;
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _status == _FormStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'OrigamiLearn',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.amber,
              labelColor: AppTheme.amber,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'Đăng nhập'),
                Tab(text: 'Đăng ký'),
              ],
            ),
            if (_status == _FormStatus.error && _errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginTab(isLoading),
                  _buildRegisterTab(isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _loginEmailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _loginPasswordCtrl,
              label: 'Mật khẩu',
              obscure: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(
              label: 'Đăng nhập',
              isLoading: isLoading,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 16),
            _buildDivider(),
            const SizedBox(height: 16),
            _buildGoogleButton(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _registerNameCtrl,
              label: 'Tên hiển thị',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _registerEmailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _registerPasswordCtrl,
              label: 'Mật khẩu (tối thiểu 6 ký tự)',
              obscure: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(
              label: 'Tạo tài khoản',
              isLoading: isLoading,
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 16),
            _buildDivider(),
            const SizedBox(height: 16),
            _buildGoogleButton(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.amber),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(label),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('hoặc', style: TextStyle(color: Colors.white54)),
        ),
        Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  Widget _buildGoogleButton(bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : _handleGoogleSignIn,
      icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.white),
      label: const Text('Tiếp tục với Google', style: TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Email không hợp lệ';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }
}