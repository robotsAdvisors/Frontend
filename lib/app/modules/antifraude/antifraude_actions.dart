import 'package:flutter/material.dart';

/// Acciones sobre el informador (mockup).
/// Los botones aún no están cableados: muestran un aviso hasta que exista el
/// endpoint de antifraude. Se dejó el aviso en vez del `onPressed: () {}` vacío
/// original para que no parezcan funcionales.
class AntifraudeActions extends StatelessWidget {
  const AntifraudeActions({super.key});

  void _pending(BuildContext context, String accion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$accion — pendiente de cablear al backend.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Acciones sobre Informador")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _pending(context, 'Bloquear informador'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Bloquear informador"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _pending(context, 'Suspender cuenta'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Suspender cuenta"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _pending(context, 'Levantar restricción'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Levantar restricción"),
            ),
          ],
        ),
      ),
    );
  }
}
