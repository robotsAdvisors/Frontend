import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/campaign_model.dart';
import '../controllers/general_admin_controller.dart';

/// Pantalla de campañas promocionales del superadmin, cableada al backend
/// (`/admin/campaigns/`): lista, crea, edita, elimina y sube el banner.
class CampaignsView extends GetView<GeneralAdminController> {
  const CampaignsView({super.key});

  static const Color _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.campaigns.isEmpty) controller.loadCampaigns();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campañas Promocionales'),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva campaña'),
        onPressed: () => _openForm(context),
      ),
      body: Obx(() {
        if (controller.isLoadingCampaigns.value && controller.campaigns.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: _purple));
        }
        if (controller.campaigns.isEmpty) {
          return const Center(
            child: Text('No hay campañas publicadas.',
                style: TextStyle(color: Colors.grey)),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadCampaigns,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: controller.campaigns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _campaignCard(context, controller.campaigns[i]),
          ),
        );
      }),
    );
  }

  Widget _campaignCard(BuildContext context, CampaignModel c) {
    final hasBanner =
        c.bannerImage != null && c.bannerImage!.startsWith('http');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: ListTile(
        onTap: () => _openForm(context, campaign: c),
        leading: hasBanner
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  c.bannerImage!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported_outlined),
                ),
              )
            : const CircleAvatar(
                backgroundColor: Color(0xFFEDE9FE),
                child: Icon(Icons.local_offer_outlined, color: _purple),
              ),
        title: Text(c.name.isNotEmpty ? c.name : 'Sin nombre',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(_subtitle(c)),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _openForm(context, campaign: c);
            if (v == 'delete') _confirmDelete(context, c);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  String _subtitle(CampaignModel c) {
    final parts = <String>[];
    if (c.affects.isNotEmpty) parts.add(c.affects);
    if (c.earningMultiplier.isNotEmpty) parts.add('×${c.earningMultiplier}');
    if (c.redemptionMultiplier.isNotEmpty &&
        c.redemptionMultiplier != c.earningMultiplier) {
      parts.add('canje ×${c.redemptionMultiplier}');
    }
    if (c.discountPercent > 0) {
      parts.add('${c.discountPercent.toStringAsFixed(0)}%');
    }
    final b = c.budget;
    if (b != null) parts.add('${b.consumedPoints} pts usados');
    if (!c.isActive) parts.add('inactiva');
    return parts.isEmpty ? '—' : parts.join('  ·  ');
  }

  void _confirmDelete(BuildContext context, CampaignModel c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar campaña'),
        content: Text('¿Seguro que quieres eliminar "${c.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              controller.removeCampaign(c.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {CampaignModel? campaign}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CampaignForm(controller: controller, campaign: campaign),
    );
  }
}

/// Formulario de creación/edición de campaña, en un bottom sheet.
class _CampaignForm extends StatefulWidget {
  const _CampaignForm({required this.controller, this.campaign});

  final GeneralAdminController controller;
  final CampaignModel? campaign;

  @override
  State<_CampaignForm> createState() => _CampaignFormState();
}

class _CampaignFormState extends State<_CampaignForm> {
  static const Color _purple = Color(0xFF7C3AED);

  late final TextEditingController _name;
  late final TextEditingController _multiplier;
  late final TextEditingController _budget;
  String _affects = 'EARNING';
  String _startDate = '';
  String _endDate = '';
  XFile? _image;

  bool get _isEdit => widget.campaign != null;

  @override
  void initState() {
    super.initState();
    final c = widget.campaign;
    _name = TextEditingController(text: c?.name ?? '');
    _affects = (c?.affects.isNotEmpty ?? false) ? c!.affects : 'EARNING';
    final mult = _affects == 'REDEMPTION'
        ? (c?.redemptionMultiplier ?? '')
        : (c?.earningMultiplier ?? '');
    _multiplier = TextEditingController(text: mult);
    _budget = TextEditingController(
        text: c?.budget?.maxPointsGlobal?.toString() ?? '');
    _startDate = _fmtOrEmpty(c?.startDate);
    _endDate = _fmtOrEmpty(c?.endDate);
  }

  @override
  void dispose() {
    _name.dispose();
    _multiplier.dispose();
    _budget.dispose();
    super.dispose();
  }

  static String _fmtOrEmpty(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${_two(d.month)}-${_two(d.day)}';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        final v = '${picked.year}-${_two(picked.month)}-${_two(picked.day)}';
        if (isStart) {
          _startDate = v;
        } else {
          _endDate = v;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = picked);
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Falta el nombre', 'El nombre de la campaña es obligatorio');
      return;
    }
    final mult = _multiplier.text.trim();
    final budget = _budget.text.trim();
    final payload = <String, dynamic>{
      'name': name,
      'affects': _affects,
      if (mult.isNotEmpty && _affects == 'EARNING') 'earning_multiplier': mult,
      if (mult.isNotEmpty && _affects == 'REDEMPTION')
        'redemption_multiplier': mult,
      if (_startDate.isNotEmpty) 'start_date': _startDate,
      if (_endDate.isNotEmpty) 'end_date': _endDate,
      if (budget.isNotEmpty) 'max_points_global': int.tryParse(budget),
    };

    final ok = await widget.controller.submitCampaign(
      payload,
      image: _image,
      editId: _isEdit ? widget.campaign!.id : null,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final existingBanner = widget.campaign?.bannerImage;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_isEdit ? 'Editar campaña' : 'Nueva campaña',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nombre de campaña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _affects,
              decoration: const InputDecoration(
                labelText: 'Afecta a',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'EARNING', child: Text('Ganar puntos (EARNING)')),
                DropdownMenuItem(
                    value: 'REDEMPTION', child: Text('Canjear (REDEMPTION)')),
              ],
              onChanged: (v) => setState(() => _affects = v ?? 'EARNING'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _multiplier,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Multiplicador (ej. 2)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                      'Fecha inicio', _startDate, () => _pickDate(true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      _dateField('Fecha fin', _endDate, () => _pickDate(false)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tope de puntos (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _bannerPreview(existingBanner),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  foregroundColor: _purple,
                  side: const BorderSide(color: _purple)),
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_outlined),
              label: Text(_image != null ? 'Cambiar banner' : 'Subir banner'),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: widget.controller.isSavingCampaign.value
                      ? null
                      : _submit,
                  child: widget.controller.isSavingCampaign.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isEdit ? 'Guardar cambios' : 'Crear campaña'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(value.isEmpty ? 'Seleccionar' : value,
            style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black87)),
      ),
    );
  }

  Widget _bannerPreview(String? existingBanner) {
    if (_image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(_image!.path), height: 120, fit: BoxFit.cover),
      );
    }
    if (existingBanner != null && existingBanner.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(existingBanner,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink()),
      );
    }
    return const SizedBox.shrink();
  }
}
