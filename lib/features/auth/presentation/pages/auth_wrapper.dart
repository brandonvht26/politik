import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../acta_escrutinio/presentation/pages/mis_mesas_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../pages/change_password_page.dart';
import '../pages/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthUnauthenticated || state is AuthError) {
          return const LoginPage();
        } else if (state is AuthRequirePasswordChange) {
          return const ChangePasswordPage();
        } else if (state is AuthAuthenticated) {
          final user = state.user;
          if (user.rol == 'veedor') {
            return const MisMesasPage();
          } else {
            return _CoordinadorPlaceholder(rol: user.rol);
          }
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginPage();
      },
    );
  }
}

class _CoordinadorPlaceholder extends StatelessWidget {
  final String rol;

  const _CoordinadorPlaceholder({required this.rol});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rolLabel = rol == 'provincial' ? 'Provincial' : 'Recinto';

    return Scaffold(
      appBar: AppBar(
        title: Text('Coordinador $rolLabel'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Panel de Coordinador $rolLabel',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'En construcción',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
