import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/voto_partido_local_entity.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import 'camera_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActaFormPage extends StatefulWidget {
  final String tipo;
  final bool isReadOnly;
  final Map<String, dynamic>? initialData;
  final String recintoId;
  final String mesaId;

  const ActaFormPage({
    super.key,
    required this.tipo,
    required this.recintoId,
    required this.mesaId,
    this.isReadOnly = false,
    this.initialData,
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
      _controllers[org] = TextEditingController(
        text: widget.initialData?['votos_partidos']?[org]?.toString() ?? '',
      );
    }
    _blancosCtrl.text = widget.initialData?['votos_blancos']?.toString() ?? '';
    _nulosCtrl.text = widget.initialData?['votos_nulos']?.toString() ?? '';
    _sufragantesCtrl.text = widget.initialData?['total_sufragantes']?.toString() ?? '';

    if (!widget.isReadOnly && widget.initialData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showHelpModal();
      });
    }
  }

  void _showHelpModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Aviso Importante'),
        content: const Text(
          'Por favor, asegúrate de ingresar los datos correctamente.\n\n'
          'Si no te sientes seguro de poder llenar el formulario correctamente, por favor informa al Coordinador de Recinto para que él lo llene por ti.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
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
    
    if (sumaTotal != total) {
      final diferencia = (total - sumaTotal).abs();
      final esSobrante = sumaTotal > total;
      setState(() => _errorMessage =
          'Hay un descuadre en los votos. '
          '${esSobrante ? 'Sobran' : 'Faltan'} $diferencia votos '
          'para igualar el total de sufragantes ($total).');
      return false;
    }
    
    setState(() => _errorMessage = null);
    return true;
  }

  void _siguiente() {
    if (!_formKey.currentState!.validate()) return;
    if (!_validarVotos()) return;

    if (!widget.isReadOnly && widget.initialData == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmación'),
          content: const Text(
            '¿Estás seguro de que los datos son correctos?\n\n'
            'Una vez enviada el acta, no podrás modificarla. Solo el Coordinador de Recinto podrá corregirla en caso de error.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Revisar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navegarCamara();
              },
              child: const Text('Sí, enviar'),
            ),
          ],
        ),
      );
    } else {
      _navegarCamara();
    }
  }

  void _navegarCamara() {
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

    return PremiumScaffold(
      title: 'Acta $tipoLabel',
      subtitle: 'Ingresa los resultados cuidadosamente',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PremiumCard(
          padding: const EdgeInsets.all(24),
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
                            readOnly: widget.isReadOnly,
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
                      readOnly: widget.isReadOnly,
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
                      readOnly: widget.isReadOnly,
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
                      readOnly: widget.isReadOnly,
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
                    if (widget.initialData != null && !widget.isReadOnly) ...[
                      FilledButton.icon(
                        onPressed: _guardarCambios,
                        icon: const Icon(Icons.save),
                        label: const Text('Actualizar Acta (Misma Foto)'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!widget.isReadOnly)
                      FilledButton.icon(
                        onPressed: _siguiente,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(widget.initialData != null ? 'Tomar Nueva Foto' : 'Siguiente: Capturar Foto'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: widget.initialData != null ? Colors.grey.shade700 : AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _guardarCambios() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Por favor, corrija los errores del formulario.');
      return;
    }
    
    final sumaVotos = _organizaciones.fold<int>(
      0,
      (prev, org) => prev + _parseInt(_controllers[org]!.text),
    ) + _parseInt(_blancosCtrl.text) + _parseInt(_nulosCtrl.text);
    
    if (sumaVotos != _parseInt(_sufragantesCtrl.text)) {
      setState(() {
        _errorMessage = 'La suma total ($sumaVotos) no coincide con el Total de Sufragantes (${_parseInt(_sufragantesCtrl.text)}).';
      });
      return;
    }
    
    setState(() => _errorMessage = null);

    final votosPartidos = _organizaciones
        .map((org) => VotoPartidoLocalEntity(
              nombreOrganizacion: org,
              cantidadVotos: _parseInt(_controllers[org]!.text),
            ))
        .toList();

    context.read<ActaBloc>().add(
          SaveActaRequested(
            recintoId: widget.recintoId,
            mesaId: widget.mesaId,
            tipo: widget.tipo,
            votosPartidos: votosPartidos,
            votosBlancos: _parseInt(_blancosCtrl.text),
            votosNulos: _parseInt(_nulosCtrl.text),
            totalSufragantes: _parseInt(_sufragantesCtrl.text),
            imageLocalPath: '', // No local path because we are just updating text and keeping the image_id
            imageId: widget.initialData?['image_id'],
            latitud: (widget.initialData?['latitud'] as num?)?.toDouble(),
            longitud: (widget.initialData?['longitud'] as num?)?.toDouble(),
          ),
        );
        
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guardando cambios...')),
    );
    Navigator.pop(context);
  }
}
