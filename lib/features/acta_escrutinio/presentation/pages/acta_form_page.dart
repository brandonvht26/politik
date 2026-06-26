import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/voto_partido_local_entity.dart';
import 'camera_page.dart';

class ActaFormPage extends StatefulWidget {
  final String tipo;

  const ActaFormPage({
    super.key,
    required this.tipo,
  });

  @override
  State<ActaFormPage> createState() => _ActaFormPageState();
}

class _ActaFormPageState extends State<ActaFormPage> {
  final _formKey = GlobalKey<FormState>();

  static const _organizaciones = [
    'Partido A - Movimiento Nacional',
    'Partido B - Alianza Popular',
    'Partido C - Frente Democrático',
    'Partido D - Unión Cívica',
    'Partido E - Renovación',
  ];

  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _blancosCtrl = TextEditingController();
  final TextEditingController _nulosCtrl = TextEditingController();
  final TextEditingController _sufragantesCtrl = TextEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (final org in _organizaciones) {
      _controllers[org] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _blancosCtrl.dispose();
    _nulosCtrl.dispose();
    _sufragantesCtrl.dispose();
    super.dispose();
  }

  int _parseInt(String text) => int.tryParse(text.trim()) ?? 0;

  bool _validarVotos() {
    int sumaPartidos = 0;
    for (final c in _controllers.values) {
      sumaPartidos += _parseInt(c.text);
    }
    final blancos = _parseInt(_blancosCtrl.text);
    final nulos = _parseInt(_nulosCtrl.text);
    final total = _parseInt(_sufragantesCtrl.text);
    final sumaTotal = sumaPartidos + blancos + nulos;

    if (total <= 0) {
      setState(() => _errorMessage = 'El total de sufragantes debe ser mayor a 0.');
      return false;
    }
    if (sumaTotal > total) {
      setState(() => _errorMessage =
          'La suma de votos ($sumaTotal) excede el total de sufragantes ($total).');
      return false;
    }
    setState(() => _errorMessage = null);
    return true;
  }

  void _siguiente() {
    if (!_formKey.currentState!.validate()) return;
    if (!_validarVotos()) return;

    final votosPartidos = _organizaciones
        .map(
          (org) => VotoPartidoLocalEntity(
            nombreOrganizacion: org,
            cantidadVotos: _parseInt(_controllers[org]!.text),
          ),
        )
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraPage(
          tipo: widget.tipo,
          votosPartidos: votosPartidos,
          votosBlancos: _parseInt(_blancosCtrl.text),
          votosNulos: _parseInt(_nulosCtrl.text),
          totalSufragantes: _parseInt(_sufragantesCtrl.text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tipoLabel = widget.tipo == 'alcalde' ? 'Alcalde' : 'Prefecto';

    return Scaffold(
      appBar: AppBar(
        title: Text('Acta $tipoLabel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Votos por Organización Política',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ..._organizaciones.map((org) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _controllers[org],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: org,
                        hintText: '0',
                      ),
                      validator: (v) {
                        if (v != null && v.isNotEmpty && int.tryParse(v.trim()) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                  )),
              const Divider(height: 32),
              Text('Otros Votos', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _blancosCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Votos Blancos',
                  hintText: '0',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nulosCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Votos Nulos',
                  hintText: '0',
                ),
              ),
              const Divider(height: 32),
              Text('Total', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sufragantesCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Total de Sufragantes',
                  hintText: '0',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _siguiente,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Siguiente: Capturar Foto'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
