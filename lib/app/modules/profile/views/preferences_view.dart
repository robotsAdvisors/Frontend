import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';

class PreferencesView extends StatefulWidget {
  const PreferencesView({Key? key}) : super(key: key);

  @override
  State<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _bg = Color(0xFFF2F2F7);

  bool _loading = true;
  bool _saving = false;

  // Mapa campo-backend → valor booleano actual.
  // Las claves coinciden exactamente con lo que espera setattr() en el backend.
  final Map<String, bool> _prefs = {
    'email_notifications': true,
    'push_notifications': true,
    'police_alert': false,
    'road_alert': true,
    'traffic_alert': true,
    'marketplace_alert': false,
    'rewards_alert': true,
    'weather_alert': false,
    'events_alert': false,
    'friends_alert': true,
  };

  // Snapshot de lo que hay en backend (para enviar solo lo que cambió).
  late Map<String, bool> _original;

  @override
  void initState() {
    super.initState();
    _original = Map.of(_prefs);
    _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    try {
      final me = await AuthRepository.instance.fetchMe();
      if (me != null) {
        final src = AuthRepository.extractPreferences(me);
        setState(() {
          for (final key in _prefs.keys) {
            final v = src[key];
            if (v is bool) _prefs[key] = v;
          }
          _original = Map.of(_prefs);
        });
      }
    } catch (_) {
      // Si no hay conexión se muestran los valores por defecto.
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Solo envía los campos que cambiaron respecto al snapshot.
      final changed = _prefs.entries
          .where((e) => _original[e.key] != e.value)
          .toList();

      await Future.wait(
        changed.map(
          (e) => AuthRepository.instance.changePreferenceAlert(e.key, e.value),
        ),
      );

      _original = Map.of(_prefs);
      Get.back();
      Get.snackbar(
        'Preferencias guardadas',
        'Tus preferencias de notificación fueron actualizadas.',
        backgroundColor: _purple,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudieron guardar las preferencias. Intenta de nuevo.',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  void _toggle(String key, bool value) => setState(() => _prefs[key] = value);

  bool get _hasChanges =>
      _prefs.entries.any((e) => _original[e.key] != e.value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _purple))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          _notificationsSection(),
                          const SizedBox(height: 16),
                          _alertTypesSection(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _saveButton(),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: _bg,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.close,
                size: 22, color: Color(0xFF111827)),
          ),
          const Expanded(
            child: Text(
              'Preferences',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _purple),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFFD1D5DB), width: 1.5),
            ),
            child: const Icon(Icons.question_mark_rounded,
                size: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // ─── SECTIONS ────────────────────────────────────────────────────────────

  Widget _notificationsSection() {
    return _sectionCard(
      title: 'Notifications',
      children: [
        _toggleRow(
          label: 'Email Notifications',
          subtitle: 'Updates on transactions and security',
          key: 'email_notifications',
        ),
        _divider(),
        _toggleRow(
          label: 'Push Notifications',
          subtitle: 'Real-time alerts and community news',
          key: 'push_notifications',
        ),
      ],
    );
  }

  Widget _alertTypesSection() {
    return _sectionCard(
      title: 'Alert Types',
      children: [
        _alertRow(
          iconBg: const Color(0xFF8B5CF6),
          icon: Icons.shield_outlined,
          label: 'Police presence',
          key: 'police_alert',
        ),
        _divider(),
        _alertRow(
          iconBg: const Color(0xFFF87171),
          icon: Icons.block_rounded,
          label: 'Road closures',
          key: 'road_alert',
        ),
        _divider(),
        _alertRow(
          iconBg: const Color(0xFFF97316),
          icon: Icons.traffic_rounded,
          label: 'Heavy traffic jams',
          key: 'traffic_alert',
        ),
        _divider(),
        _alertRow(
          iconBg: const Color(0xFFD97706),
          icon: Icons.price_change_outlined,
          label: 'Marketplace price drops',
          key: 'marketplace_alert',
        ),
        _divider(),
        _alertRow(
          iconBg: const Color(0xFF7C3AED),
          icon: Icons.workspace_premium_outlined,
          label: 'New reward challenges',
          key: 'rewards_alert',
        ),
        _divider(),
        _alertRow(
          iconBg: const Color(0xFF60A5FA),
          icon: Icons.thunderstorm_outlined,
          label: 'Severe weather alerts',
          key: 'weather_alert',
        ),
        _divider(),
        _alertRow(
          iconBg: const Color(0xFF34D399),
          icon: Icons.event_outlined,
          label: 'Local event reminders',
          key: 'events_alert',
        ),
        _divider(),
        _alertRow(
          iconBg: const Color(0xFF38BDF8),
          icon: Icons.people_outlined,
          label: 'Friends nearby',
          key: 'friends_alert',
        ),
      ],
    );
  }

  // ─── WIDGETS ─────────────────────────────────────────────────────────────

  Widget _sectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _toggleRow({
    required String label,
    required String subtitle,
    required String key,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          _switch(key),
        ],
      ),
    );
  }

  Widget _alertRow({
    required Color iconBg,
    required IconData icon,
    required String label,
    required String key,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconBg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827))),
          ),
          _switch(key),
        ],
      ),
    );
  }

  Widget _switch(String key) {
    return Switch(
      value: _prefs[key] ?? false,
      onChanged: (v) => _toggle(key, v),
      activeColor: Colors.white,
      activeTrackColor: _purple,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFD1D5DB),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _divider() => const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Color(0xFFF3F4F6));

  Widget _saveButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (_saving || !_hasChanges) ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              disabledBackgroundColor: _purple.withValues(alpha: 0.4),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Preferences',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
