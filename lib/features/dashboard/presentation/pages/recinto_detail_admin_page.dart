import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/premium_card.dart';
import '../../../../core/presentation/widgets/premium_scaffold.dart';
import '../../domain/entities/recinto_entity.dart';
import 'acta_detail_admin_page.dart';

class RecintoDetailAdminPage extends StatelessWidget {
  final RecintoEntity recinto;
  final List<Map<String, dynamic>> actas;

  const RecintoDetailAdminPage({
    super.key,
    required this.recinto,
    required this.actas,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumScaffold(
      title: recinto.nombre,
      subtitle: '${recinto.canton} - ${recinto.parroquia}',
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recinto.numMesas,
        itemBuilder: (context, index) {
          final numMesa = index + 1;
          final mesaIdStr = numMesa.toString();
          
          final actaAlcalde = actas.where((a) => a['id_jrv'] == mesaIdStr && (a['dignidad'] == 'alcalde' || a['tipo'] == 'alcalde')).firstOrNull;
          final actaPrefecto = actas.where((a) => a['id_jrv'] == mesaIdStr && (a['dignidad'] == 'prefecto' || a['tipo'] == 'prefecto')).firstOrNull;

          return PremiumCard(
            margin: const EdgeInsets.only(bottom: 12),
            hasDecoration: true,
            decorationColor: AppColors.primary.withOpacity(0.05),
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.table_bar, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Mesa $numMesa', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActaStatusChip(
                          title: 'Alcalde',
                          acta: actaAlcalde,
                          onTap: actaAlcalde != null ? () => _viewActa(context, actaAlcalde, 'Alcalde') : null,
                        ),
                        _ActaStatusChip(
                          title: 'Prefecto',
                          acta: actaPrefecto,
                          onTap: actaPrefecto != null ? () => _viewActa(context, actaPrefecto, 'Prefecto') : null,
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

  void _viewActa(BuildContext context, Map<String, dynamic> acta, String dignidadTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActaDetailAdminPage(
          acta: acta,
          dignidadTitle: dignidadTitle,
        ),
      ),
    );
  }
}

class _ActaStatusChip extends StatelessWidget {
  final String title;
  final Map<String, dynamic>? acta;
  final VoidCallback? onTap;

  const _ActaStatusChip({
    required this.title,
    this.acta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasActa = acta != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        label: Text(title),
        avatar: Icon(
          hasActa ? Icons.check_circle : Icons.pending,
          color: hasActa ? Colors.green : Colors.grey,
        ),
        backgroundColor: hasActa ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        side: BorderSide(
          color: hasActa ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
