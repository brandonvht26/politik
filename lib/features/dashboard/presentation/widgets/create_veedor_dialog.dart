import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/cedula_validator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';

class CreateVeedorDialog extends StatefulWidget {
  final String recintoId;
  final int numMesas;
  final List<UserProfileEntity> allVeedores;

  const CreateVeedorDialog({
    super.key,
    required this.recintoId,
    required this.numMesas,
    required this.allVeedores,
  });

  @override
  State<CreateVeedorDialog> createState() => _CreateVeedorDialogState();
}

class _CreateVeedorDialogState extends State<CreateVeedorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final Set<String> _selectedMesas = {};

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  Set<String> _getAssignedMesas() {
    final assigned = <String>{};
    for (final v in widget.allVeedores) {
      if (v.mesaId != null && v.mesaId!.trim().isNotEmpty) {
        assigned.addAll(v.mesaId!.split(',').map((e) => e.trim()));
      }
    }
    return assigned;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMesas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar al menos una mesa')),
      );
      return;
    }

    final newMesaId = _selectedMesas.toList()..sort();
    context.read<RecintoBloc>().add(
          CreateVeedorRequested(
            cedula: _cedulaCtrl.text.trim(),
            nombres: _nombresCtrl.text.trim(),
            apellidos: _apellidosCtrl.text.trim(),
            telefono: _telefonoCtrl.text.trim(),
            correoReal: _correoCtrl.text.trim(),
            recintoId: widget.recintoId,
            mesaId: newMesaId.join(','),
          ),
        );
    Navigator.of(context).pop();
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
      title: const Text('Nuevo Veedor de Mesa', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _cedulaCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Cédula',
                    prefixIcon: Icon(Icons.badge),
                    counterText: '',
                  ),
                  validator: (v) {
                    final result = CedulaValidator.validate(v ?? '');
                    return result.isValid ? null : result.message;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nombresCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Nombres',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Ingrese los nombres' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apellidosCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Apellidos',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Ingrese los apellidos'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Ingrese el teléfono'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Correo Real',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingrese el correo';
                    }
                    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Selecciona las mesas a asignar:'),
                const SizedBox(height: 8),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: theme.colorScheme.error)),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
