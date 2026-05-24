import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/http/api_client.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  static const Color _purple = Color(0xFF7C3AED);

  final _emailCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        'Email inválido',
        'Ingresa un email válido.',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await AuthRepository.instance.resetPassword(email: email);
      setState(() => _sent = true);
      Get.snackbar(
        'Enlace enviado',
        'Revisa tu bandeja de entrada.',
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      final msg =
          e is ApiException ? e.message : 'No se pudo enviar el enlace.';
      Get.snackbar(
        'Error',
        msg,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back,
              color: Color(0xFF111827), size: 22),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Lock circle
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 60, color: _purple),
            ),
            const SizedBox(height: 32),
            const Text(
              'Forgot Password?',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            const Text(
              "Enter your email address and we'll send\nyou a link to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.6),
            ),
            const SizedBox(height: 40),
            // Email field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email Address',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF111827)),
              decoration: InputDecoration(
                hintText: 'name@example.com',
                hintStyle: TextStyle(
                    fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.chat_bubble_outline_rounded,
                    size: 20, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _purple, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Send button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (_sending || _sent) ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _sent ? Colors.grey.shade400 : _purple,
                  disabledBackgroundColor:
                      _sent ? Colors.grey.shade300 : _purple.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _sent ? 'Link Sent!' : 'Send Reset Link',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          if (!_sent) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward,
                                size: 18, color: Colors.white),
                          ],
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Back to login
            GestureDetector(
              onTap: () => Get.back(),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _purple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
