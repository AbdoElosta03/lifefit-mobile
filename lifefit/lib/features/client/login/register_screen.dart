import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/routing/app_entry.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: 'client', 
        );

    final state = ref.read(authProvider);
    if (mounted && state.user != null && state.errorMessage == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppEntry()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      // خلفية فاتحة موحدة (نفس شاشة الدخول)
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // أيقونة إنشاء حساب
                        const Icon(
                          Icons.person_add_alt_1,
                          size: 80,
                          color: Color(0xFF00C2C2),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'إنشاء حساب جديد',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0f172a),
                          ),
                        ),
                        const Text(
                          'انضم إلى لايف فت\n  وابدأ رحلتك اليوم',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748b), fontSize: 15),
                        ),
                        const SizedBox(height: 35),

                        _buildField(
                          controller: _nameController,
                          label: 'الاسم الكامل',
                          icon: Icons.person_outline,
                          validator: (v) => v!.isEmpty ? 'الاسم مطلوب' : null,
                        ),
                        const SizedBox(height: 14),

                        _buildField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'البريد مطلوب';
                            if (!v.contains('@')) return 'صيغة البريد غير صحيحة';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _buildField(
                          controller: _passwordController,
                          label: 'كلمة المرور',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscure: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) => v!.length < 8 ? '8 أحرف على الأقل' : null,
                        ),
                        const SizedBox(height: 14),

                        _buildField(
                          controller: _confirmController,
                          label: 'تأكيد كلمة المرور',
                          icon: Icons.lock_reset,
                          isPassword: true,
                          obscure: _obscureConfirm,
                          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: (v) => v != _passwordController.text ? 'لا يوجد تطابق' : null,
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

                        // زر الإنشاء
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _onRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D9D9),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('إنشاء الحساب', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('لديك حساب بالفعل؟', style: TextStyle(color: Color(0xFF64748b))),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'سجل دخولك',
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
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
                onPressed: onToggle,
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
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: validator,
    );
  }
}