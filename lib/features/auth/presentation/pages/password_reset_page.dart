import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PasswordResetPage extends StatefulWidget {
  final String userId;
  final String secret;

  const PasswordResetPage({
    super.key,
    required this.userId,
    required this.secret,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  int _strength = 0;
  String _strengthText = '';
  Color _strengthColor = Colors.grey;

  void _checkPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9!@#\$&*~_]'))) strength++;

    setState(() {
      if (password.isEmpty) {
        _strength = 0;
        _strengthText = '';
        _strengthColor = Colors.grey;
      } else if (strength <= 2) {
        _strength = 1;
        _strengthText = 'Débil';
        _strengthColor = Colors.red;
      } else if (strength == 3) {
        _strength = 2;
        _strengthText = 'Media';
        _strengthColor = Colors.orange;
      } else {
        _strength = 3;
        _strengthText = 'Fuerte';
        _strengthColor = Colors.green;
      }
    });
  }

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          PasswordResetConfirmed(
            userId: widget.userId,
            secret: widget.secret,
            newPassword: _newPasswordCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.metallicGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.accent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is PasswordResetSuccess) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '¡Contraseña Actualizada!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tu contraseña ha sido modificada exitosamente. Ya puedes iniciar sesión en la aplicación con tus nuevas credenciales.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () async {
                                if (kIsWeb) {
                                  final uri = Uri.parse('politik://');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                    return;
                                  }
                                }
                                // Pop untill the root route (LoginPage)
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                              icon: const Icon(Icons.login),
                              label: const Text('Ir a la aplicación'),
                            ),
                          ),
                        ],
                      );
                    }

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_reset,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nueva Contraseña',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ingresa tu nueva contraseña para acceder al sistema.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _newPasswordCtrl,
                            obscureText: _obscureNew,
                            textInputAction: TextInputAction.next,
                            onChanged: _checkPasswordStrength,
                            decoration: InputDecoration(
                              labelText: 'Nueva Contraseña',
                              hintText: 'Mínimo 8 caracteres',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingrese una contraseña';
                              }
                              if (v.contains(' ')) {
                                return 'La contraseña no debe contener espacios';
                              }
                              if (v.length < 8) {
                                return 'Mínimo 8 caracteres';
                              }
                              if (!v.contains(RegExp(r'[A-Z]'))) {
                                return 'Debe contener al menos una mayúscula';
                              }
                              if (!v.contains(RegExp(r'[a-z]'))) {
                                return 'Debe contener al menos una minúscula';
                              }
                              if (!v.contains(RegExp(r'[0-9]')) && !v.contains(RegExp(r'[!@#\$&*~_]'))) {
                                return 'Debe contener un número o carácter especial';
                              }
                              return null;
                            },
                          ),
                          if (_newPasswordCtrl.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: _strength / 3,
                                        backgroundColor: Colors.grey.shade300,
                                        color: _strengthColor,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _strengthText,
                                    style: TextStyle(
                                      color: _strengthColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordCtrl,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _resetPassword(),
                            decoration: InputDecoration(
                              labelText: 'Confirmar Contraseña',
                              hintText: 'Repita la contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirme su contraseña';
                              }
                              if (v != _newPasswordCtrl.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          Builder(
                            builder: (context) {
                              final isLoading = state is AuthLoading;
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.metallicGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: FilledButton.icon(
                                  onPressed: isLoading ? null : _resetPassword,
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.check_circle, color: Colors.white),
                                  label: isLoading
                                      ? const Text('Restableciendo...', style: TextStyle(color: Colors.white))
                                      : const Text('Actualizar Contraseña', style: TextStyle(color: Colors.white)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
