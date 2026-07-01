import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';

class ReassignMesaDialog extends StatefulWidget {
  final UserProfileEntity veedor;
  final int numMesas;
  final List<UserProfileEntity> allVeedores;

  const ReassignMesaDialog({
    super.key,
    required this.veedor,
    required this.numMesas,
    required this.allVeedores,
  });

  @override
  State<ReassignMesaDialog> createState() => _ReassignMesaDialogState();
}

class _ReassignMesaDialogState extends State<ReassignMesaDialog> {
  final Set<String> _selectedMesas = {};

  @override
  void initState() {
    super.initState();
    if (widget.veedor.mesaId != null && widget.veedor.mesaId!.trim().isNotEmpty) {
      _selectedMesas.addAll(widget.veedor.mesaId!.split(',').map((e) => e.trim()));
    }
  }

  Set<String> _getAssignedMesas() {
    final assigned = <String>{};
    for (final v in widget.allVeedores) {
      if (v.cedula != widget.veedor.cedula && v.mesaId != null && v.mesaId!.trim().isNotEmpty) {
        assigned.addAll(v.mesaId!.split(',').map((e) => e.trim()));
      }
    }
    return assigned;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assignedMesas = _getAssignedMesas();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.accent, width: 2),
      ),
      elevation: 20,
      title: const Text('Reasignar Mesas', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Selecciona las mesas a asignar:'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(widget.numMesas, (index) {
                  final mesa = (index + 1).toString();
                  final isAssignedToOther = assignedMesas.contains(mesa);
                  return FilterChip(
                    label: Text('Mesa $mesa'),
                    selected: _selectedMesas.contains(mesa),
                    onSelected: isAssignedToOther
                        ? null
                        : (selected) {
                            setState(() {
                              if (selected) {
                                _selectedMesas.add(mesa);
                              } else {
                                _selectedMesas.remove(mesa);
                              }
                            });
                          },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    disabledColor: Colors.grey.withOpacity(0.2),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: theme.colorScheme.error)),
        ),
        FilledButton(
          onPressed: () {
            final newMesaId = _selectedMesas.toList()..sort();
            context.read<RecintoBloc>().add(
                  ReassignVeedorMesaRequested(
                    cedula: widget.veedor.cedula,
                    newMesaId: newMesaId.join(','),
                  ),
                );
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
