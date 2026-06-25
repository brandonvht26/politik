import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_blur_detection/image_blur_detection.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/acta_escrutinio_entity.dart';
import '../../domain/entities/jrv_entity.dart';
import '../../domain/entities/votos_partido_entity.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../bloc/acta_state.dart';

class CameraPage extends StatefulWidget {
  final JrvEntity jrv;
  final String dignidad;
  final Map<String, int> votosPartido;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;

  const CameraPage({
    super.key,
    required this.jrv,
    required this.dignidad,
    required this.votosPartido,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  final ImageQualityValidator _validator = ImageQualityValidator(
    config: QualityConfig.photoCapture,
  );

  File? _capturedImage;
  bool _isProcessing = false;
  bool _isSharp = false;
  Position? _position;
  String? _statusMessage;

  Future<void> _tomarFoto() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = null;
      _isSharp = false;
      _capturedImage = null;
      _position = null;
    });

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'No se tomó ninguna foto.';
      });
      return;
    }

    final bytes = await photo.readAsBytes();
    final result = await _validator.validate(bytes);

    if (!result.isValid) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _mostrarDialogoBorrosa();
      return;
    }

    setState(() {
      _capturedImage = File(photo.path);
      _isSharp = true;
      _isProcessing = false;
    });

    await _obtenerGPS();
  }

  void _mostrarDialogoBorrosa() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Foto borrosa'),
        content: const Text(
          'La foto es borrosa. Por favor, tómala de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _tomarFoto();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Future<void> _obtenerGPS() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _statusMessage =
              'Permiso de ubicación denegado. No se puede registrar el GPS.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _position = position;
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error al obtener GPS: $e';
      });
    }
  }

  void _guardarActa() {
    final votosPartidoEntities = widget.votosPartido.entries
        .map(
          (e) => VotosPartidoEntity(
            idOrganizacion: e.key,
            nombreOrganizacion: e.key,
            cantidadVotos: e.value,
          ),
        )
        .toList();

    final acta = ActaEscrutinioEntity(
      id: '${widget.jrv.id}_${widget.dignidad}_${DateTime.now().millisecondsSinceEpoch}',
      idJrv: widget.jrv.id,
      dignidad: widget.dignidad,
      votosPorPartido: votosPartidoEntities,
      votosBlancos: widget.votosBlancos,
      votosNulos: widget.votosNulos,
      totalSufragantes: widget.totalSufragantes,
      latitud: _position?.latitude,
      longitud: _position?.longitude,
      imagePath: _capturedImage?.path ?? '',
      isSynced: false,
    );

    context.read<ActaBloc>().add(SaveActaEvent(acta: acta));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dignidadLabel =
        widget.dignidad == 'alcalde' ? 'Alcalde' : 'Prefecto';

    return BlocConsumer<ActaBloc, ActaState>(
      listener: (context, state) {
        if (state is ActaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else if (state is ActaSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acta guardada offline correctamente'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      builder: (context, state) {
        final isLoading = state is ActaLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text('Foto Acta $dignidadLabel'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resumen de Votos',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...widget.votosPartido.entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(e.key,
                                      style: theme.textTheme.bodyMedium),
                                ),
                                Text('${e.value}',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 16),
                        _resumenRow('Blancos', widget.votosBlancos, theme),
                        _resumenRow('Nulos', widget.votosNulos, theme),
                        const Divider(height: 16),
                        _resumenRow('Total Sufragantes', widget.totalSufragantes,
                            theme, bold: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isProcessing)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_capturedImage != null && _isSharp) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _capturedImage!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF16A34A), size: 24),
                      const SizedBox(width: 8),
                      Text('Foto nítida',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF16A34A))),
                    ],
                  ),
                  if (_position != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(height: 8),
                          Text(
                            'Sin fotografía',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_statusMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: (_isProcessing || isLoading) ? null : _tomarFoto,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_capturedImage != null
                      ? 'Volver a Tomar Foto'
                      : 'Tomar Fotografía'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: (_capturedImage != null &&
                          _isSharp &&
                          !_isProcessing &&
                          !isLoading)
                      ? _guardarActa
                      : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: isLoading
                      ? const Text('Guardando...')
                      : const Text('Guardar Acta'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _resumenRow(String label, int value, ThemeData theme,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: bold
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.bodyMedium),
          Text('$value',
              style: bold
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
