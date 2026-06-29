import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';

class ReassignMesaDialog extends StatefulWidget {
  final UserProfileEntity veedor;
  final int numMesas;

  const ReassignMesaDialog({
    super.key,
    required this.veedor,
    required this.numMesas,
  });

  @override
  State<ReassignMesaDialog> createState() => _ReassignMesaDialogState();
}

class _ReassignMesaDialogState extends State<ReassignMesaDialog> {
  String? _newMesaId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.accent, width: 2),
      ),
      elevation: 20,
      title: const Text('Reasignar Mesa', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: DropdownButtonFormField<String>(
          initialValue: _newMesaId,
          decoration: const InputDecoration(
            labelText: 'Nueva mesa',
            prefixIcon: Icon(Icons.table_bar),
          ),
          items: List.generate(
            widget.numMesas,
            (index) {
              final mesa = (index + 1).toString();
              return DropdownMenuItem(
                value: mesa,
                child: Text('Mesa $mesa'),
              );
            },
          ).where((item) => item.value != widget.veedor.mesaId).toList(),
          onChanged: (value) => setState(() => _newMesaId = value),
          validator: (v) =>
              v == null || v.isEmpty ? 'Seleccione una mesa' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: theme.colorScheme.error)),
        ),
        FilledButton(
          onPressed: _newMesaId == null
              ? null
              : () {
                  context.read<RecintoBloc>().add(
                        ReassignVeedorMesaRequested(
                          cedula: widget.veedor.cedula,
                          newMesaId: _newMesaId!,
                        ),
                      );
                  Navigator.of(context).pop();
                },
          child: const Text('Reasignar'),
        ),
      ],
    );
  }
}
