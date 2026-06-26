import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../acta_escrutinio/presentation/pages/mis_mesas_page.dart';
import '../../../dashboard/presentation/pages/provincial_dashboard_page.dart';
import '../../../dashboard/presentation/pages/recinto_dashboard_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'change_password_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthRequiresPasswordChange) {
          return const ForcePasswordChangePage();
        }

        if (state is AuthSuccess) {
          final rol = state.user.rol;
          if (rol == 'provincial') {
            return const ProvincialDashboardPage();
          } else if (rol == 'recinto') {
            return const RecintoDashboardPage();
          } else {
            return const MisMesasPage();
          }
        }

        // AuthInitial, AuthError or any other non-authenticated state.
        return const LoginPage();
      },
    );
  }
}
