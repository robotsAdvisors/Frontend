import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../general_admin/views/backoffice_sidebar.dart';
import '../controllers/customer_search_controller.dart';

/// Buscador de clientes de la app → ficha de puntos. Punto de entrada del
/// Módulo A (el superadmin busca por email).
class CustomerSearchView extends GetView<CustomerSearchController> {
  const CustomerSearchView({super.key});

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Clientes · Puntos',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('Busca un cliente por email para ver y ajustar sus puntos.',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: TextField(
                      controller: controller.searchField,
                      onChanged: controller.onQueryChanged,
                      onSubmitted: (_) => controller.search(),
                      decoration: InputDecoration(
                        hintText: 'email@cliente.com',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(child: Obx(_buildResults)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.query.value.trim().length < 2) {
      return _hint('Escribe al menos 2 caracteres del email.');
    }
    if (!controller.hasSearched.value) {
      return const SizedBox.shrink();
    }
    if (controller.results.isEmpty) {
      return _hint('Sin resultados para "${controller.query.value.trim()}".');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
      itemCount: controller.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final c = controller.results[i];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEDE9FE),
              child: Text(
                (c.email.isNotEmpty ? c.email[0] : '?').toUpperCase(),
                style: const TextStyle(
                    color: _purple, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(c.email,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text([
              if (c.name.isNotEmpty) c.name,
              c.isActive ? 'Activo' : 'Inactivo',
            ].join(' · ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(
              Routes.CUSTOMER_POINTS_DETAIL,
              arguments: {'id': c.id, 'email': c.email, 'name': c.name},
            ),
          ),
        );
      },
    );
  }

  Widget _hint(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text,
              style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
        ),
      );
}
