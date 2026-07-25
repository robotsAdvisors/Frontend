import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/antifraud_report_model.dart';
import '../../routes/app_pages.dart';
import 'antifraude_screen.dart' show antifraudStatusLabel;
import 'controllers/antifraude_controller.dart';

/// Detalle de una contribución sospechosa + decisión del moderador
/// (validate / reject / observe), cableado al backend.
class AntifraudeDetail extends GetView<AntifraudeController> {
  const AntifraudeDetail({super.key});

  static const Color _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de contribución'),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final r = controller.selected.value;
        if (r == null) {
          return const Center(
              child: Text('Selecciona una contribución de la cola.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('Usuario', r.user ?? '—'),
              if (r.userId != null && r.userId!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 120, top: 2, bottom: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                      label: const Text('Ver puntos del cliente'),
                      onPressed: () => Get.toNamed(
                        Routes.CUSTOMER_POINTS_DETAIL,
                        arguments: {'id': r.userId, 'email': r.user ?? '', 'name': ''},
                      ),
                    ),
                  ),
                ),
              _field('Tipo', (r.type ?? '—').toString()),
              _field('Modalidad', r.kind),
              _field('Zona (geohash)', r.zone.isEmpty ? '—' : r.zone),
              _field('Ubicación', r.streetName.isEmpty ? '—' : r.streetName),
              _field('Creada', r.created?.toString() ?? '—'),
              Row(
                children: [
                  const SizedBox(width: 120, child: Text('Estado')),
                  Text(antifraudStatusLabel(r.status),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Señales detectadas',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (r.signals.isEmpty)
                const Text('Sin señales.', style: TextStyle(color: Colors.grey))
              else
                ...r.signals.map(_signalTile),
              const SizedBox(height: 24),
              const Text('Decisión',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _decisionButtons(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _signalTile(AntifraudSignal s) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8F7FF),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.flag_outlined, color: _purple),
        title: Text(s.signal, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(s.detail),
        trailing: Text(s.action,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ),
    );
  }

  Widget _decisionButtons(BuildContext context) {
    return Obx(() {
      final busy = controller.isDeciding.value;
      return Column(
        children: [
          _decisionBtn(context, 'Validar', 'validate', Colors.green, busy),
          const SizedBox(height: 10),
          _decisionBtn(context, 'Rechazar', 'reject', Colors.red, busy),
          const SizedBox(height: 10),
          _decisionBtn(
              context, 'Mantener en observación', 'observe', Colors.orange, busy),
        ],
      );
    });
  }

  Widget _decisionBtn(BuildContext context, String label, String decision,
      Color color, bool busy) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: busy ? null : () => _confirm(context, label, decision),
        child: busy
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label),
      ),
    );
  }

  Future<void> _confirm(
      BuildContext context, String label, String decision) async {
    final reasonCtrl = TextEditingController();
    final isReject = decision == 'reject';
    bool revoke = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(label),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Motivo (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (isReject)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: revoke,
                  onChanged: (v) => setState(() => revoke = v ?? false),
                  title: const Text('Retirar los puntos de esta contribución',
                      style: TextStyle(fontSize: 13)),
                  subtitle: const Text('Genera un ajuste negativo (tope no-negativo).',
                      style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final done = await controller.decide(decision,
        reason: reasonCtrl.text.trim(), revokePoints: isReject && revoke);
    if (done) Get.back(); // vuelve a la cola
  }
}
