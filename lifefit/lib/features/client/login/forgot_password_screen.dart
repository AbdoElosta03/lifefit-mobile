import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/ui/app_colors.dart';
import 'widgets/auth_widgets.dart';

/// Two-step password reset: request OTP by email, then set a new password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  int _step = 1;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearMessages() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    _clearMessages();
    setState(() => _isLoading = true);

    try {
      final message = await _auth.forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _successMessage = message;
        _isLoading = false;
      });
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() {
        _step = 2;
        _successMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    _clearMessages();
    setState(() => _isLoading = true);

    try {
      final message = await _auth.resetPassword(
        email: _emailController.text.trim(),
        otp: _otpController.text.trim(),
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _successMessage = message;
        _isLoading = false;
      });
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      formKey: _formKey,
      children: [
        if (_step == 1) ..._buildStep1() else ..._buildStep2(),
        AuthFooterLink(
          prompt: 'تذكرت كلمة المرور؟',
          actionLabel: 'سجل دخولك',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  List<Widget> _buildStep1() {
    return [
      const AuthHeader(
        title: 'نسيت كلمة المرور',
        subtitle: 'أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق مكوّن من 6 أرقام',
      ),
      AuthTextField(
        controller: _emailController,
        hint: 'البريد الإلكتروني',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: (v) {
          if (v == null || v.isEmpty) return 'البريد مطلوب';
          if (!v.contains('@')) return 'بريد غير صالح';
          return null;
        },
      ),
      const SizedBox(height: 8),
      AuthErrorMessage(message: _errorMessage),
      if (_successMessage != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _successMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      AuthPrimaryButton(
        label: 'إرسال رمز التحقق',
        isLoading: _isLoading,
        onPressed: _sendOtp,
      ),
    ];
  }

  List<Widget> _buildStep2() {
    final email = _emailController.text.trim();
    return [
      AuthHeader(
        title: 'إعادة تعيين كلمة المرور',
        subtitle: 'أرسلنا رمز التحقق إلى $email',
      ),
      AuthTextField(
        controller: _otpController,
        hint: 'رمز التحقق (6 أرقام)',
        icon: Icons.pin_outlined,
        keyboardType: TextInputType.number,
        validator: (v) {
          if (v == null || v.isEmpty) return 'رمز التحقق مطلوب';
          if (v.length != 6) return 'يجب أن يكون 6 أرقام';
          return null;
        },
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _passwordController,
        hint: 'كلمة المرور الجديدة',
        icon: Icons.lock_outline,
        isPassword: true,
        obscure: _obscurePassword,
        onToggleVisibility: () =>
            setState(() => _obscurePassword = !_obscurePassword),
        validator: (v) =>
            (v == null || v.length < 8) ? '8 أحرف على الأقل' : null,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _confirmController,
        hint: 'تأكيد كلمة المرور',
        icon: Icons.lock_reset,
        isPassword: true,
        obscure: _obscureConfirm,
        onToggleVisibility: () =>
            setState(() => _obscureConfirm = !_obscureConfirm),
        validator: (v) =>
            (v != _passwordController.text) ? 'لا يوجد تطابق' : null,
      ),
      const SizedBox(height: 8),
      AuthErrorMessage(message: _errorMessage),
      if (_successMessage != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _successMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      AuthPrimaryButton(
        label: 'تغيير كلمة المرور',
        isLoading: _isLoading,
        onPressed: _resetPassword,
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.center,
        child: TextButton(
          onPressed: _isLoading
              ? null
              : () => setState(() {
                    _step = 1;
                    _errorMessage = null;
                    _successMessage = null;
                  }),
          child: const Text(
            '← العودة لإدخال البريد',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    ];
  }
}
