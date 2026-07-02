import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as import_connectivity;

import '../../../../core/services/local_storage_service.dart';
import '../../domain/entities/voto_partido_local_entity.dart';
import '../bloc/acta_bloc.dart';
import '../bloc/acta_event.dart';
import '../bloc/acta_state.dart';

class CameraPage extends StatefulWidget {
  final String tipo;
  final List<VotoPartidoLocalEntity> votosPartidos;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;

  const CameraPage({
    super.key,
    required this.tipo,
    required this.votosPartidos,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String? _capturedImagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tipoLabel = widget.tipo == 'alcalde' ? 'Alcalde' : 'Prefecto';
    final session = LocalStorageService.sessionBox.get('current');
    final recintoId = session?.recintoId ?? '';
    final mesaId = session?.mesaId ?? '';

    return BlocConsumer<ActaBloc, ActaState>(
      listener: (context, state) {
        if (state is ActaPhotoCaptured) {
          setState(() => _capturedImagePath = state.imagePath);
        } else if (state is ActaSuccess) {
          import_connectivity.Connectivity().checkConnectivity().then((result) {
            if (!mounted) return;
            final isOffline = result == import_connectivity.ConnectivityResult.none;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isOffline ? 'Acta guardada offline correctamente' : 'Acta enviada correctamente'),
                backgroundColor: const Color(0xFF16A34A),
              ),
            );
          });
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (state is ActaValidationError || state is ActaError) {
          final message = state is ActaValidationError
              ? state.message
              : (state as ActaError).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ActaLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text('Foto Acta $tipoLabel'),
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
                        ...widget.votosPartidos.map(
                          (v) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(v.nombreOrganizacion,
                                      style: theme.textTheme.bodyMedium),
                                ),
                                Text('${v.cantidadVotos}',
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
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_capturedImagePath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_capturedImagePath!),
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
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4)),
                          const SizedBox(height: 8),
                          Text(
                            'Sin fotografía',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: isLoading ? null : _tomarFoto,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_capturedImagePath != null
                      ? 'Volver a Tomar Foto'
                      : 'Tomar Fotografía'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: (_capturedImagePath != null && !isLoading)
                      ? () => _guardarActa(
                            context,
                            recintoId: recintoId,
                            mesaId: mesaId,
                          )
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

  void _tomarFoto() {
    context.read<ActaBloc>().add(CapturePhotoRequested());
  }

  void _guardarActa(
    BuildContext context, {
    required String recintoId,
    required String mesaId,
  }) {
    if (_capturedImagePath == null) return;

    context.read<ActaBloc>().add(
          SaveActaRequested(
            recintoId: recintoId,
            mesaId: mesaId,
            tipo: widget.tipo,
            votosPartidos: widget.votosPartidos,
            votosBlancos: widget.votosBlancos,
            votosNulos: widget.votosNulos,
            totalSufragantes: widget.totalSufragantes,
            imageLocalPath: _capturedImagePath!,
          ),
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
