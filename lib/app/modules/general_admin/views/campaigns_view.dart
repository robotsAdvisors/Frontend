import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/campaign_model.dart';
import '../controllers/general_admin_controller.dart';

/// Pantalla de campañas promocionales (superadmin).
///
/// Por ahora SOLO lista las campañas del backend (GET /admin/campaigns/). El
/// crear/editar/eliminar y la subida de banner se cablearán después con
/// `_repo.createCampaign` / `uploadCampaignImage` (la capa de datos ya existe).
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
            padding: const EdgeInsets.all(16),
            itemCount: controller.campaigns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _campaignCard(controller.campaigns[i]),
          ),
        );
      }),
    );
  }

  Widget _campaignCard(CampaignModel c) {
    final hasBanner =
        c.bannerImage != null && c.bannerImage!.startsWith('http');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: ListTile(
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
        trailing: c.isActive
            ? null
            : const Text('Inactiva',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }

  String _subtitle(CampaignModel c) {
    final parts = <String>[];
    if (c.affects.isNotEmpty) parts.add(c.affects);
    if (c.earningMultiplier.isNotEmpty) parts.add('×${c.earningMultiplier}');
    if (c.discountPercent > 0) {
      parts.add('${c.discountPercent.toStringAsFixed(0)}%');
    }
    final b = c.budget;
    if (b != null) parts.add('${b.consumedPoints} pts usados');
    return parts.isEmpty ? '—' : parts.join('  ·  ');
  }
}
