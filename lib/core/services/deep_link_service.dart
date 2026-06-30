import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'appwrite_service.dart';
import '../../features/auth/presentation/pages/password_reset_page.dart';

class DeepLinkService {
  final AppwriteService _appwrite;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService(this._appwrite);

  void initialize(BuildContext context) {
    _appLinks = AppLinks();

    // Manejar el link si la app fue abierta desde el correo estando cerrada
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        if (!context.mounted) return;
        _handleDeepLink(uri, context);
      }
    });

    // Escuchar links mientras la app está en memoria o en background
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (!context.mounted) return;
      _handleDeepLink(uri, context);
    }, onError: (err) {
      debugPrint('Error escuchando links: $err');
    });
  }

  void _handleDeepLink(Uri uri, BuildContext context) async {
    debugPrint('Deep Link recibido: $uri');
    
    // Verificamos si es el link de confirmación de cuenta
    if (uri.scheme == 'politik' && uri.host == 'verify') {
      final userId = uri.queryParameters['userId'];
      final secret = uri.queryParameters['secret'];

      if (userId != null && secret != null) {
        try {
          await _appwrite.account.updateVerification(
            userId: userId,
            secret: secret,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ ¡Tu cuenta ha sido confirmada exitosamente!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error verificando cuenta: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error al confirmar la cuenta: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } else if (uri.queryParameters['action'] == 'reset' || uri.path == '/reset-password') {
      final userId = uri.queryParameters['userId'];
      final secret = uri.queryParameters['secret'];

      if (userId != null && secret != null) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PasswordResetPage(
                userId: userId,
                secret: secret,
              ),
            ),
          );
        }
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
