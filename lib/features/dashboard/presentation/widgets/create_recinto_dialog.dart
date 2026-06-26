import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recinto_entity.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';

class CreateRecintoDialog extends StatefulWidget {
  const CreateRecintoDialog({super.key});

  @override
  State<CreateRecintoDialog> createState() => _CreateRecintoDialogState();
}

class _CreateRecintoDialogState extends State<CreateRecintoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cantonCtrl = TextEditingController();
  final _parroquiaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _numMesasCtrl = TextEditingController();

  @override
  void dispose() {
    _cantonCtrl.dispose();
    _parroquiaCtrl.dispose();
    _nombreCtrl.dispose();
    _numMesasCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final recinto = RecintoEntity(
      id: '',
      canton: _cantonCtrl.text.trim(),
      parroquia: _parroquiaCtrl.text.trim(),
      nombre: _nombreCtrl.text.trim(),
      numMesas: int.parse(_numMesasCtrl.text.trim()),
    );

    context.read<ProvincialBloc>().add(CreateRecintoRequested(recinto));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Nuevo Recinto'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _cantonCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Cantón',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Ingrese el cantón' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _parroquiaCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Parroquia',
                    prefixIcon: Icon(Icons.map),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Ingrese la parroquia' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nombreCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Recinto',
                    prefixIcon: Icon(Icons.place),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Ingrese el nombre' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _numMesasCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Número de Mesas',
                    prefixIcon: Icon(Icons.table_bar),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingrese el número de mesas';
                    }
                    final value = int.tryParse(v.trim());
                    if (value == null || value <= 0) {
                      return 'Debe ser un número mayor a 0';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
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
