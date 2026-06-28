import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/recinto_bloc.dart';
import '../bloc/recinto_event.dart';
import '../bloc/recinto_state.dart';
import '../widgets/create_veedor_dialog.dart';
import '../widgets/reassign_mesa_dialog.dart';

class RecintoDashboardPage extends StatefulWidget {
  const RecintoDashboardPage({super.key});

  @override
  State<RecintoDashboardPage> createState() => _RecintoDashboardPageState();
}

class _RecintoDashboardPageState extends State<RecintoDashboardPage> {
  String? _recintoId;

  @override
  void initState() {
    super.initState();
    _recintoId = LocalStorageService.sessionBox.get('current')?.recintoId;
    if (_recintoId != null && _recintoId!.isNotEmpty) {
      context.read<RecintoBloc>().add(LoadRecintoData(_recintoId!));
    }
  }

  void _loadData() {
    if (_recintoId != null && _recintoId!.isNotEmpty) {
      context.read<RecintoBloc>().add(LoadRecintoData(_recintoId!));
    }
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_recintoId == null || _recintoId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Coordinación de Recinto')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No tiene un recinto asignado.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinación de Recinto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<RecintoBloc, RecintoState>(
          listener: (context, state) {
            if (state is RecintoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            } else if (state is RecintoActionSuccess) {
              if (state.message.contains('creado')) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('¡Cuenta de Veedor Creada!'),
                    content: const Text(
                      'Hemos enviado un correo de verificación automático al usuario. Por favor, indíquele lo siguiente:\n\n'
                      'a. Que abra su bandeja de entrada (o carpeta de SPAM) y busque un correo de Appwrite / Politik.\n\n'
                      'b. Que presione el botón azul \'Confirm email address\'.\n\n'
                      'c. Que regrese a esta app e inicie sesión usando su Cédula y la contraseña temporal: Ecuador2026.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Entendido'),
                      ),
                    ],
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is RecintoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecintoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error al cargar datos',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is RecintoDataLoaded) {
              final recinto = state.recinto;
              final veedores = state.veedores;

              return RefreshIndicator(
                onRefresh: () async => _loadData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recinto.nombre,
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${recinto.canton} - ${recinto.parroquia}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.table_bar,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${recinto.numMesas} mesas (JRVs)',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.table_bar,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Mesas',
                            style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _MesasList(
                        numMesas: recinto.numMesas,
                        veedores: veedores,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Icon(Icons.people,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Veedores',
                            style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _showCreateVeedorDialog(
                              context,
                              recinto.id,
                              recinto.numMesas,
                            ),
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Nuevo'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _VeedoresList(
                        veedores: veedores,
                        numMesas: recinto.numMesas,
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showCreateVeedorDialog(
    BuildContext context,
    String recintoId,
    int numMesas,
  ) {
    showDialog(
      context: context,
      builder: (_) => CreateVeedorDialog(
        recintoId: recintoId,
        numMesas: numMesas,
      ),
    );
  }
}

class _MesasList extends StatelessWidget {
  final int numMesas;
  final List<UserProfileEntity> veedores;

  const _MesasList({required this.numMesas, required this.veedores});

  @override
  Widget build(BuildContext context) {
    if (numMesas <= 0) {
      return const _EmptyState(message: 'El recinto no tiene mesas asignadas.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: numMesas,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final mesaNumero = (index + 1).toString();
        final asignado = veedores.where((v) => v.mesaId == mesaNumero).toList();

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text(mesaNumero),
            ),
            title: Text('Mesa $mesaNumero'),
            subtitle: asignado.isEmpty
                ? const Text('Sin asignar',
                    style: TextStyle(fontStyle: FontStyle.italic))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: asignado
                        .map((v) => Text('• ${v.nombreCompleto}'))
                        .toList(),
                  ),
            trailing: asignado.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Reasignar veedor',
                    onPressed: () => _showReassignDialog(
                      context,
                      asignado.first,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  void _showReassignDialog(
    BuildContext context,
    UserProfileEntity veedor,
  ) {
    showDialog(
      context: context,
      builder: (_) => ReassignMesaDialog(
        veedor: veedor,
        numMesas: numMesas,
      ),
    );
  }
}

class _VeedoresList extends StatelessWidget {
  final List<UserProfileEntity> veedores;
  final int numMesas;

  const _VeedoresList({required this.veedores, required this.numMesas});

  @override
  Widget build(BuildContext context) {
    if (veedores.isEmpty) {
      return const _EmptyState(message: 'No hay veedores registrados.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: veedores.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final v = veedores[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person),
            ),
            title: Text(v.nombreCompleto),
            subtitle: Text('Cédula: ${v.cedula}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text('Mesa ${v.mesaId ?? "-"}'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Reasignar mesa',
                  onPressed: () => _showReassignDialog(context, v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReassignDialog(BuildContext context, UserProfileEntity veedor) {
    showDialog(
      context: context,
      builder: (_) => ReassignMesaDialog(
        veedor: veedor,
        numMesas: numMesas,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
      ),
    );
  }
}
