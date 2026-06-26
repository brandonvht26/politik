import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/recinto_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import '../widgets/create_coordinador_recinto_dialog.dart';
import '../widgets/create_recinto_dialog.dart';

class ProvincialDashboardPage extends StatefulWidget {
  const ProvincialDashboardPage({super.key});

  @override
  State<ProvincialDashboardPage> createState() =>
      _ProvincialDashboardPageState();
}

class _ProvincialDashboardPageState extends State<ProvincialDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ProvincialBloc>().add(LoadProvincialData());
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Provincial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<ProvincialBloc, ProvincialState>(
          listener: (context, state) {
            if (state is ProvincialError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            } else if (state is ProvincialActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProvincialLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProvincialError) {
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

            if (state is ProvincialDataLoaded) {
              return RefreshIndicator(
                onRefresh: () async => _loadData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        icon: Icons.place,
                        title: 'Recintos',
                        count: state.recintos.length,
                      ),
                      const SizedBox(height: 8),
                      _RecintosList(recintos: state.recintos),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _showCreateRecintoDialog(context),
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text('Nuevo Recinto'),
                      ),
                      const SizedBox(height: 32),
                      _SectionHeader(
                        icon: Icons.supervisor_account,
                        title: 'Coordinadores de Recinto',
                        count: state.coordinadores.length,
                      ),
                      const SizedBox(height: 8),
                      _CoordinadoresList(
                        coordinadores: state.coordinadores,
                        recintos: state.recintos,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _showCreateCoordinadorDialog(
                          context,
                          state.recintos,
                        ),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Nuevo Coordinador'),
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

  void _showCreateRecintoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CreateRecintoDialog(),
    );
  }

  void _showCreateCoordinadorDialog(
    BuildContext context,
    List<RecintoEntity> recintos,
  ) {
    showDialog(
      context: context,
      builder: (_) => CreateCoordinadorRecintoDialog(recintos: recintos),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Chip(
          label: Text('$count'),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _RecintosList extends StatelessWidget {
  final List<RecintoEntity> recintos;

  const _RecintosList({required this.recintos});

  @override
  Widget build(BuildContext context) {
    if (recintos.isEmpty) {
      return const _EmptyState(message: 'No hay recintos registrados.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recintos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = recintos[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.place),
            ),
            title: Text(r.nombre),
            subtitle: Text('${r.canton} - ${r.parroquia}'),
            trailing: Chip(
              label: Text('${r.numMesas} mesas'),
            ),
          ),
        );
      },
    );
  }
}

class _CoordinadoresList extends StatelessWidget {
  final List<UserProfileEntity> coordinadores;
  final List<RecintoEntity> recintos;

  const _CoordinadoresList({
    required this.coordinadores,
    required this.recintos,
  });

  @override
  Widget build(BuildContext context) {
    if (coordinadores.isEmpty) {
      return const _EmptyState(
        message: 'No hay coordinadores de recinto registrados.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: coordinadores.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final c = coordinadores[index];
        final recinto = recintos.firstWhere(
          (r) => r.id == c.recintoId,
          orElse: () => const RecintoEntity(
            id: '',
            canton: '',
            parroquia: '',
            nombre: 'Sin recinto asignado',
            numMesas: 0,
          ),
        );

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person),
            ),
            title: Text(c.nombreCompleto),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cédula: ${c.cedula}'),
                Text('Recinto: ${recinto.nombre}'),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
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
