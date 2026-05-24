import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/http/api_client.dart';
import '../../../routes/app_pages.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bg = Color(0xFFF2F2F7);

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _saving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentCtrl.text.trim();
    final newPwd = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      _showError('Completa todos los campos.');
      return;
    }
    if (newPwd.length < 8) {
      _showError('La nueva contraseña debe tener al menos 8 caracteres.');
      return;
    }
    if (newPwd != confirm) {
      _showError('Las contraseñas nuevas no coinciden.');
      return;
    }

    setState(() => _saving = true);
    try {
      await AuthRepository.instance.changePassword(
        currentPassword: current,
        newPassword: newPwd,
      );
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
      Get.snackbar(
        '',
        'Password updated successfully!',
        titleText: const SizedBox.shrink(),
        messageText: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text('Password updated successfully!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.zero,
        borderRadius: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      final msg = e is ApiException ? e.message : 'Error al cambiar la contraseña.';
      _showError(msg);
    } finally {
      setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back,
              color: Color(0xFF111827), size: 22),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _purple),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert,
                color: Color(0xFF111827), size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Lock icon circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 54, color: _purple),
            ),
            const SizedBox(height: 28),
            const Text(
              'Update Password',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please enter your current password and\ncreate a new secure one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5),
            ),
            const SizedBox(height: 36),
            // Current Password
            _fieldLabel('Current Password'),
            const SizedBox(height: 8),
            _passwordField(
              controller: _currentCtrl,
              hint: '••••••••',
              prefixIcon: Icons.vpn_key_outlined,
              show: _showCurrent,
              onToggle: () => setState(() => _showCurrent = !_showCurrent),
            ),
            const SizedBox(height: 20),
            // New Password
            _fieldLabel('New Password'),
            const SizedBox(height: 8),
            _passwordField(
              controller: _newCtrl,
              hint: 'Create new password',
              prefixIcon: Icons.history_outlined,
              show: _showNew,
              onToggle: () => setState(() => _showNew = !_showNew),
            ),
            const SizedBox(height: 20),
            // Confirm New Password
            _fieldLabel('Confirm New Password'),
            const SizedBox(height: 8),
            _passwordField(
              controller: _confirmCtrl,
              hint: 'Repeat new password',
              prefixIcon: Icons.shield_outlined,
              show: _showConfirm,
              onToggle: () => setState(() => _showConfirm = !_showConfirm),
            ),
            const SizedBox(height: 32),
            // Update button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  disabledBackgroundColor: _purple.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Update Password',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Forgot password link
            GestureDetector(
              onTap: () => Get.toNamed(Routes.FORGOT_PASSWORD),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF6B7280)),
                  children: [
                    TextSpan(text: "Can't remember? "),
                    TextSpan(
                      text: 'Forgot password',
                      style: TextStyle(
                          color: _purple,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151))),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !show,
      style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 14, color: Color(0xFFBBBBBB)),
        prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF9CA3AF)),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            show ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
      ),
    );
  }
}
