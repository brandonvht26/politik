import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/cedula_validator.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';

class CreateVeedorDialog extends StatefulWidget {
  final String recintoId;
  final int numMesas;

  const CreateVeedorDialog({
    super.key,
    required this.recintoId,
    required this.numMesas,
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
  String? _mesaId;

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

    context.read<RecintoBloc>().add(
          CreateVeedorRequested(
            cedula: _cedulaCtrl.text.trim(),
            nombres: _nombresCtrl.text.trim(),
            apellidos: _apellidosCtrl.text.trim(),
            telefono: _telefonoCtrl.text.trim(),
            correoReal: _correoCtrl.text.trim(),
            recintoId: widget.recintoId,
            mesaId: _mesaId!,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Nuevo Veedor de Mesa'),
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
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _mesaId,
                  decoration: const InputDecoration(
                    labelText: 'Mesa asignada',
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
                  ),
                  onChanged: (value) => setState(() => _mesaId = value),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Seleccione una mesa' : null,
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
