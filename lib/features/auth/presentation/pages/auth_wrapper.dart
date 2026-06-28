import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection_container.dart';

import '../../../acta_escrutinio/presentation/pages/mis_mesas_page.dart';
import '../../../dashboard/presentation/pages/provincial_dashboard_page.dart';
import '../../../dashboard/presentation/pages/recinto_dashboard_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'change_password_page.dart';
import 'login_page.dart';
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl.deepLinkService.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // We don't intercept AuthLoading here because it destroys the LoginPage state.
        // LoginPage handles AuthLoading by showing a spinner on its own button.
        
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
