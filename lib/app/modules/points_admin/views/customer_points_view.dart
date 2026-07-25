import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/points_admin_models.dart';
import '../../general_admin/views/backoffice_sidebar.dart';
import '../controllers/customer_points_controller.dart';

/// Ficha de puntos de un cliente: pestañas Saldo y Movimientos + Ajustar.
class CustomerPointsView extends GetView<CustomerPointsController> {
  const CustomerPointsView({super.key});

  static const Color _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BackofficeSidebar(current: 'clientes'),
          const VerticalDivider(width: 1),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const TabBar(
                    isScrollable: true,
                    labelColor: _purple,
                    indicatorColor: _purple,
                    tabs: [Tab(text: 'Saldo'), Tab(text: 'Movimientos')],
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      children: [_saldoTab(), _movimientosTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.email.isEmpty ? 'Cliente' : controller.email,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                if (controller.name.isNotEmpty)
                  Text(controller.name,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Ajustar puntos'),
            onPressed: () => _openAdjustDialog(context),
          ),
        ],
      ),
    );
  }

  // ── Saldo ──────────────────────────────────────────────────────────────────
  Widget _saldoTab() {
    return Obx(() {
      if (controller.isLoadingBalance.value && controller.balance.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final b = controller.balance.value;
      if (b == null) {
        return _empty('Sin datos de saldo.');
      }
      return RefreshIndicator(
        onRefresh: controller.loadBalance,
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _saldoCard('Disponible', b.disponible, Colors.green),
                _saldoCard('Pendiente', b.pendiente, Colors.orange),
                _saldoCard('Bloqueado', b.bloqueado, Colors.blueGrey),
                _saldoCard('Expirado', b.expirado, Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            Text('Total histórico: ${b.totalHistorico} puntos',
                style: const TextStyle(color: Colors.grey)),
            if (b.actualizadoEn != null)
              Text('Actualizado: ${_fmt(b.actualizadoEn!)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    });
  }

  Widget _saldoCard(String label, int value, Color color) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.stars, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ]),
          const SizedBox(height: 10),
          Text('$value',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  // ── Movimientos ──────────────────────────────────────────────────────────
  Widget _movimientosTab() {
    return Column(
      children: [
        _filters(),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingMovements.value &&
                controller.movements.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.movements.isEmpty) {
              return _empty('Sin movimientos con estos filtros.');
            }
            return RefreshIndicator(
              onRefresh: controller.loadMovements,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                itemCount: controller.movements.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _movRow(controller.movements[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _filters() {
    const directions = ['', 'SUMA', 'CONSUMO', 'BLOQUEO', 'LIBERACION', 'EXPIRACION', 'AJUSTE'];
    const statuses = ['', 'PENDIENTE', 'VALIDADO', 'BLOQUEADO', 'LIBERADO', 'CONSUMIDO', 'RECHAZADO', 'EXPIRADO', 'AJUSTADO'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
      child: Obx(
        () => Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _dropdown('Tipo', directions, controller.directionFilter.value,
                controller.setDirectionFilter),
            _dropdown('Estado', statuses, controller.statusFilter.value,
                controller.setStatusFilter),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> options, String value,
      void Function(String) onChanged) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: value,
        isDense: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: options
            .map((o) => DropdownMenuItem(
                value: o, child: Text(o.isEmpty ? 'Todos' : o)))
            .toList(),
        onChanged: (v) => onChanged(v ?? ''),
      ),
    );
  }

  Widget _movRow(PointsMovement m) {
    final positive = m.isPositive;
    final color = positive ? Colors.green : Colors.red;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(positive ? Icons.add_circle_outline : Icons.remove_circle_outline,
          color: color),
      title: Text(
        m.reason.isNotEmpty
            ? m.reason
            : (m.description.isNotEmpty ? m.description : m.sourceType),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text([
        m.direction,
        m.status,
        if (m.createdAt != null) _fmt(m.createdAt!),
        if (m.actorEmail != null && m.actorEmail!.isNotEmpty) 'por ${m.actorEmail}',
        if (m.auditReference != null) m.auditReference!,
      ].where((s) => s.isNotEmpty).join(' · '),
          style: const TextStyle(fontSize: 12)),
      trailing: Text('${positive ? '+' : ''}${m.amount}',
          style: TextStyle(
              fontWeight: FontWeight.w800, color: color, fontSize: 16)),
    );
  }

  // ── Ajuste ────────────────────────────────────────────────────────────────
  void _openAdjustDialog(BuildContext context) {
    Get.dialog(_AdjustDialog(controller: controller));
  }

  Widget _empty(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text, style: const TextStyle(color: Colors.grey)),
        ),
      );

  static String _fmt(DateTime d) =>
      '${d.year}-${_2(d.month)}-${_2(d.day)} ${_2(d.hour)}:${_2(d.minute)}';
  static String _2(int n) => n.toString().padLeft(2, '0');
}

/// Diálogo de ajuste manual. Genera una Idempotency-Key estable por intento
/// (se reutiliza si el usuario reintenta tras un error transitorio).
class _AdjustDialog extends StatefulWidget {
  const _AdjustDialog({required this.controller});
  final CustomerPointsController controller;

  @override
  State<_AdjustDialog> createState() => _AdjustDialogState();
}

class _AdjustDialogState extends State<_AdjustDialog> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  final _ticket = TextEditingController();
  final _idempotencyKey = CustomerPointsController.newIdempotencyKey();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    _ticket.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amount.text.trim());
    if (amount == null || amount == 0) {
      setState(() => _error = 'Importe entero distinto de 0 (negativo retira).');
      return;
    }
    if (_reason.text.trim().isEmpty) {
      setState(() => _error = 'El motivo es obligatorio.');
      return;
    }
    if (_ticket.text.trim().isEmpty) {
      setState(() => _error = 'La referencia (ticket) es obligatoria.');
      return;
    }
    setState(() => _error = null);
    final ok = await widget.controller.adjust(
      amount: amount,
      reasonText: _reason.text.trim(),
      auditReference: _ticket.text.trim(),
      idempotencyKey: _idempotencyKey,
    );
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajustar puntos'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${widget.controller.email}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: const InputDecoration(
                labelText: 'Importe (con signo: -500 retira, +100 acredita)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reason,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ticket,
              decoration: const InputDecoration(
                labelText: 'Referencia / ticket (ej: ticket:1234)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 6),
            const Text('Solo afecta al bucket "disponible". El saldo no puede quedar negativo.',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        Obx(() => ElevatedButton(
              onPressed: widget.controller.isAdjusting.value ? null : _submit,
              child: widget.controller.isAdjusting.value
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Aplicar'),
            )),
      ],
    );
  }
}
