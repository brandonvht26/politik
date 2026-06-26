import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/injection_container.dart';
import 'core/services/appwrite_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/acta_escrutinio/presentation/bloc/acta_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('No se pudo cargar el archivo .env: $e');
  }

  await LocalStorageService.init();
  await AppwriteService().init();

  sl.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ActaBloc>.value(value: sl.actaBloc),
        BlocProvider<AuthBloc>.value(value: sl.authBloc),
      ],
      child: MaterialApp(
        title: 'Veeduría Electoral',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
