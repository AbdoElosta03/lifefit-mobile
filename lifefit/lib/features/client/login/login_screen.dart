import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      // خلفية فاتحة موحدة
      backgroundColor: const Color(0xFFF8FAFC),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                // الحواشي الخارجية فقط لتنفس المحتوى
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // الشعار
                        const Icon(Icons.fitness_center, size: 85, color: Color(0xFF00C2C2)),
                        const SizedBox(height: 10),
                        const Text(
                          'FitLife',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF0f172a),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'سجل دخولك للمتابعة',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748b), fontSize: 16),
                        ),
                        const SizedBox(height: 40),

                        // الحقول مباشرة على الخلفية بدون كارد
                        _buildTextField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          validator: (v) => (v == null || !v.contains('@')) ? 'بريد غير صالح' : null,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _passwordController,
                          label: 'كلمة المرور',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscure: _obscurePassword,
                          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) => (v == null || v.length < 8) ? '8 أحرف على الأقل' : null,
                        ),

                        if (authState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              authState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),

                        const SizedBox(height: 30),

                        _buildLoginButton(authState.isLoading),

                        const SizedBox(height: 25),

                        // رابط إنشاء الحساب
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('ليس لديك حساب؟', style: TextStyle(color: Color(0xFF64748b))),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                              child: const Text(
                                'إنشاء حساب جديد',
                                style: TextStyle(color: Color(0xFF00C2C2), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFF1e293b)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748b), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF00C2C2), size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF00C2C2), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9D9),
          foregroundColor: Colors.white,
          elevation: 0, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text('تسجيل الدخول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}