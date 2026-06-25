import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veeduría Electoral',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantilla Prueba'),
      ),
      body: Center(
        child: Text(
          '¡Paleta de colores y arquitectura base lista!',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
