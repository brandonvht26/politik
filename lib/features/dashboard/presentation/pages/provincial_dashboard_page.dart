import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/metallic_card.dart';
import '../../../../core/theme/app_colors.dart';
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.metallicGradient,
          ),
        ),
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
            if (state is ProvincialError || state is ProvincialActionError) {
              final message = state is ProvincialError 
                ? state.message 
                : (state as ProvincialActionError).message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            } else if (state is ProvincialActionSuccess) {
              if (state.message.contains('creado')) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('¡Cuenta de Coordinador Creada!'),
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
            if (state is ProvincialLoading || state is ProvincialActionError) {
              // Return nothing if it's an action error, as the data will be reloaded immediately
              if (state is ProvincialActionError) return const SizedBox.shrink();
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
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Gestión', icon: Icon(Icons.admin_panel_settings)),
                        Tab(text: 'Resultados', icon: Icon(Icons.bar_chart)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Gestión (Recintos y Coordinadores)
                          RefreshIndicator(
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
                                    onPressed: () {
                                      if (state.recintos.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Debe crear al menos un recinto primero',
                                            ),
                                            backgroundColor: theme.colorScheme.error,
                                          ),
                                        );
                                        return;
                                      }
                                      _showCreateCoordinadorDialog(context, state.recintos);
                                    },
                                    icon: const Icon(Icons.person_add),
                                    label: const Text('Nuevo Coordinador'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Tab 2: Resultados Consolidados
                          _ResultadosTab(
                            actas: state.actas,
                            organizacionesPoliticas: state.organizacionesPoliticas,
                            onRefresh: () async => _loadData(),
                          ),
                        ],
                      ),
                    ),
                  ],
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
        return MetallicCard(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.account_balance_rounded, size: 32),
            ),
            title: Text(r.nombre),
            subtitle: Text('${r.canton} - ${r.parroquia}', style: const TextStyle(color: Colors.white70)),
            trailing: Chip(
              label: Text('${r.numMesas} mesas'),
              backgroundColor: Colors.white24,
              labelStyle: const TextStyle(color: Colors.white),
              side: BorderSide.none,
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

        return MetallicCard(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.supervisor_account_rounded, size: 32),
            ),
            title: Text(c.nombreCompleto),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cédula: ${c.cedula}', style: const TextStyle(color: Colors.white70)),
                Text('Recinto: ${recinto.nombre}', style: const TextStyle(color: Colors.white70)),
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

class _ResultadosTab extends StatelessWidget {
  final List<Map<String, dynamic>> actas;
  final List<Map<String, dynamic>> organizacionesPoliticas;
  final Future<void> Function() onRefresh;

  const _ResultadosTab({
    required this.actas,
    required this.organizacionesPoliticas,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Agregamos los votos
    final votosAlcalde = <String, int>{};
    final votosPrefecto = <String, int>{};

    int totalBlancosAlcalde = 0;
    int totalNulosAlcalde = 0;
    int totalBlancosPrefecto = 0;
    int totalNulosPrefecto = 0;

    // Inicializar organizaciones
    for (var org in organizacionesPoliticas) {
      final nombre = org['nombre_partido'] as String;
      final dignidad = org['dignidad'] as String;
      if (dignidad == 'alcalde') {
        votosAlcalde[nombre] = 0;
      } else if (dignidad == 'prefecto') {
        votosPrefecto[nombre] = 0;
      }
    }

    // Sumar desde las actas
    for (var acta in actas) {
      final tipo = acta['tipo'] as String;
      final votosStr = acta['votos_partidos'] as String;
      final blancos = (acta['votos_blancos'] as num?)?.toInt() ?? 0;
      final nulos = (acta['votos_nulos'] as num?)?.toInt() ?? 0;

      if (tipo == 'alcalde') {
        totalBlancosAlcalde += blancos;
        totalNulosAlcalde += nulos;
      } else {
        totalBlancosPrefecto += blancos;
        totalNulosPrefecto += nulos;
      }

      try {
        final Map<String, dynamic> votosMap = jsonDecode(votosStr);
        votosMap.forEach((key, value) {
          final int cantidad = (value as num).toInt();
          if (tipo == 'alcalde') {
            votosAlcalde[key] = (votosAlcalde[key] ?? 0) + cantidad;
          } else {
            votosPrefecto[key] = (votosPrefecto[key] ?? 0) + cantidad;
          }
        });
      } catch (e) {
        debugPrint('Error parseando votos_partidos: $e');
      }
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildChartSection(
              context,
              title: 'Alcaldía',
              icon: Icons.account_balance,
              votos: votosAlcalde,
              blancos: totalBlancosAlcalde,
              nulos: totalNulosAlcalde,
            ),
            const SizedBox(height: 32),
            _buildChartSection(
              context,
              title: 'Prefectura',
              icon: Icons.map,
              votos: votosPrefecto,
              blancos: totalBlancosPrefecto,
              nulos: totalNulosPrefecto,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Map<String, int> votos,
    required int blancos,
    required int nulos,
  }) {
    final theme = Theme.of(context);
    final totalVotosValidos = votos.values.fold(0, (sum, val) => sum + val);
    final total = totalVotosValidos + blancos + nulos;

    // Ordenar votos de mayor a menor
    final sortedVotos = votos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$total sufragios',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (total == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('Aún no hay actas registradas.')),
              )
            else ...[
              ...sortedVotos.map((entry) {
                final percentage = total > 0 ? entry.value / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${entry.value} votos (${(percentage * 100).toStringAsFixed(1)}%)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        color: theme.colorScheme.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Votos Blancos: $blancos'),
                  Text('Votos Nulos: $nulos'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

