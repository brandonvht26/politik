import 'package:flutter/material.dart';

import '../../domain/entities/jrv_entity.dart';
import 'acta_form_page.dart';

class MisMesasPage extends StatelessWidget {
  const MisMesasPage({super.key});

  static const List<JrvEntity> _mesasMock = [
    JrvEntity(id: '1', numeroMesa: 1, idRecinto: 'r1'),
    JrvEntity(id: '2', numeroMesa: 2, idRecinto: 'r1'),
    JrvEntity(id: '3', numeroMesa: 3, idRecinto: 'r1'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mesas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mesasMock.length,
        itemBuilder: (context, index) {
          final mesa = _mesasMock[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesa N\u00b0${mesa.numeroMesa}',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JRV: ${mesa.id} \u2022 Recinto: ${mesa.idRecinto}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _navegarActa(context, mesa, 'alcalde'),
                          icon: const Icon(Icons.how_to_vote),
                          label: const Text('Acta Alcalde'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => _navegarActa(context, mesa, 'prefecto'),
                          icon: const Icon(Icons.how_to_vote_outlined),
                          label: const Text('Acta Prefecto'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navegarActa(BuildContext context, JrvEntity mesa, String dignidad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActaFormPage(jrv: mesa, dignidad: dignidad),
      ),
    );
  }
}
