import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/cedula_validator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/recinto_entity.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class CreateCoordinadorRecintoDialog extends StatefulWidget {
  final List<RecintoEntity> recintos;

  const CreateCoordinadorRecintoDialog({
    super.key,
    required this.recintos,
  });

  @override
  State<CreateCoordinadorRecintoDialog> createState() =>
      _CreateCoordinadorRecintoDialogState();
}

class _CreateCoordinadorRecintoDialogState
    extends State<CreateCoordinadorRecintoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  String? _recintoId;

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<ProvincialBloc>().state;
    if (state is ProvincialDataLoaded) {
      final cedula = _cedulaCtrl.text.trim();
      final correo = _correoCtrl.text.trim();
      final telefono = _telefonoCtrl.text.trim();

      for (final coord in state.coordinadores) {
        if (coord.cedula == cedula) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ya existe un coordinador con esta cédula')));
          return;
        }
        if (coord.correoReal == correo) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ya existe un coordinador con este correo electrónico')));
          return;
        }
        if (coord.telefono == telefono) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ya existe un coordinador con este número de teléfono')));
          return;
        }
      }
    }

    context.read<ProvincialBloc>().add(
          CreateCoordinadorRecintoRequested(
            cedula: _cedulaCtrl.text.trim(),
            nombres: _nombresCtrl.text.trim(),
            apellidos: _apellidosCtrl.text.trim(),
            telefono: _telefonoCtrl.text.trim(),
            correoReal: _correoCtrl.text.trim(),
            recintoId: _recintoId!,
          ),
        );
    Navigator.of(context).pop();
  }

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
      title: const Text('Nuevo Coordinador de Recinto', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  textInputAction: TextInputAction.done,
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
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _recintoId,
                  decoration: const InputDecoration(
                    labelText: 'Recinto asignado',
                    prefixIcon: Icon(Icons.place),
                  ),
                  items: widget.recintos
                      .map(
                        (r) => DropdownMenuItem(
                          value: r.id,
                          child: Text(r.nombre, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _recintoId = value),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Seleccione un recinto' : null,
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
