import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/points_admin_models.dart';
import '../controllers/configuracion_puntos_controller.dart';
import 'backoffice_sidebar.dart';

/// Configuración del programa de puntos (ADM-PT-01), cableada a
/// `GET/PUT /admin/points/config/` (forma real `{settings, rules}`).
class ConfiguracionPuntosView extends StatelessWidget {
  const ConfiguracionPuntosView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConfiguracionPuntosController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BackofficeSidebar(current: 'configuracion_puntos'),
          const VerticalDivider(width: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.config.value == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final cfg = controller.config.value;
              if (cfg == null) {
                return const Center(child: Text('No se pudo cargar la configuración.'));
              }
              // Key por versión de datos: al recargar tras guardar, re-siembra el form.
              return _ConfigForm(
                key: ValueKey(identityHashCode(cfg)),
                config: cfg,
                controller: controller,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ConfigForm extends StatefulWidget {
  const _ConfigForm({super.key, required this.config, required this.controller});
  final PointsConfig config;
  final ConfiguracionPuntosController controller;

  @override
  State<_ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<_ConfigForm> {
  late final TextEditingController _maxPerOrder;
  late final TextEditingController _pointsPerEur;
  late final TextEditingController _maxReferrals;
  late final TextEditingController _validityDays;
  late final TextEditingController _maxPerCampaign;
  late final Map<String, TextEditingController> _rulePoints;
  late final Map<String, bool> _ruleActive;
  late bool _validateReferrals;
  late bool _validarDuplicados;

  @override
  void initState() {
    super.initState();
    final s = widget.config.settings;
    _maxPerOrder = TextEditingController(text: s.maxPointsPerOrder.toString());
    _pointsPerEur = TextEditingController(text: s.pointsPerEur.toString());
    _maxReferrals = TextEditingController(text: s.maxReferralsPerMonth.toString());
    _validityDays =
        TextEditingController(text: s.redemptionCodeValidityDays.toString());
    _maxPerCampaign =
        TextEditingController(text: s.maxPointsPerCampaign.toString());
    _validateReferrals = s.validateReferrals;
    _validarDuplicados = widget.config.validarDuplicados;
    _rulePoints = {
      for (final r in widget.config.rules)
        r.action: TextEditingController(text: r.basePoints.toString())
    };
    _ruleActive = {for (final r in widget.config.rules) r.action: r.isActive};
  }

  @override
  void dispose() {
    _maxPerOrder.dispose();
    _pointsPerEur.dispose();
    _maxReferrals.dispose();
    _validityDays.dispose();
    _maxPerCampaign.dispose();
    for (final c in _rulePoints.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _int(TextEditingController c, int fallback) =>
      int.tryParse(c.text.trim()) ?? fallback;

  void _save() {
    final s = widget.config.settings;
    final settings = {
      'max_points_per_order': _int(_maxPerOrder, s.maxPointsPerOrder),
      'points_per_eur': _int(_pointsPerEur, s.pointsPerEur),
      'max_referrals_per_month': _int(_maxReferrals, s.maxReferralsPerMonth),
      'redemption_code_validity_days':
          _int(_validityDays, s.redemptionCodeValidityDays),
      'max_points_per_campaign': _int(_maxPerCampaign, s.maxPointsPerCampaign),
      'validate_referrals': _validateReferrals,
    };
    final rules = widget.config.rules
        .map((r) => {
              'action': r.action,
              'base_points': _int(_rulePoints[r.action]!, r.basePoints),
              'is_active': _ruleActive[r.action] ?? r.isActive,
            })
        .toList();
    widget.controller.save(
      settings: settings,
      rules: rules,
      antifraud: {'validar_duplicados': _validarDuplicados},
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const Text('Configuración del programa de puntos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Los cambios se auditan (valor anterior/nuevo) y no aplican retroactivamente.',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 24),

        _sectionTitle('Ajustes generales'),
        _num('Límite máximo de puntos por pedido', _maxPerOrder),
        _num('Puntos por cada EUR', _pointsPerEur),
        _num('Máximo de referidos por mes', _maxReferrals),
        _num('Validez del código de canje (días)', _validityDays),

        const SizedBox(height: 20),
        _sectionTitle('Puntos por acción'),
        ...widget.config.rules.map(_ruleRow),

        const SizedBox(height: 20),
        _sectionTitle('Campañas y antifraude'),
        _num('Máximo de puntos por campaña (default global)', _maxPerCampaign),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Validar referidos antes de pagar'),
          subtitle: const Text(
              'Si está activo, el referido debe verificar su cuenta antes de conceder los puntos.',
              style: TextStyle(fontSize: 11)),
          value: _validateReferrals,
          onChanged: (v) => setState(() => _validateReferrals = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Validar duplicados (antifraude)'),
          subtitle: const Text(
              'Activa/desactiva la regla CROSS_USER_DUPLICATE del motor antifraude.',
              style: TextStyle(fontSize: 11)),
          value: _validarDuplicados,
          onChanged: (v) => setState(() => _validarDuplicados = v),
        ),

        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Obx(() => FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: widget.controller.isSaving.value ? null : _save,
                icon: widget.controller.isSaving.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Guardar configuración',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              )),
        ),
      ],
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      );

  Widget _num(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      );

  Widget _ruleRow(PointsConfigRule r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _rulePoints[r.action],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: r.labelEs,
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text('Activa', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Switch(
                    value: _ruleActive[r.action] ?? true,
                    onChanged: (v) => setState(() => _ruleActive[r.action] = v),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

}
