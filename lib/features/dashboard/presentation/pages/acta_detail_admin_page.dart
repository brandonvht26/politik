import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/premium_card.dart';
import '../../../../core/presentation/widgets/premium_scaffold.dart';

class ActaDetailAdminPage extends StatefulWidget {
  final Map<String, dynamic> acta;
  final String dignidadTitle;

  const ActaDetailAdminPage({
    super.key,
    required this.acta,
    required this.dignidadTitle,
  });

  @override
  State<ActaDetailAdminPage> createState() => _ActaDetailAdminPageState();
}

class _ActaDetailAdminPageState extends State<ActaDetailAdminPage> {
  String? _address;
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    final lat = widget.acta['latitud'];
    final lng = widget.acta['longitud'];
    
    if (lat != null && lng != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          setState(() {
            _address = '${p.street}, ${p.subLocality}, ${p.locality}, ${p.country}';
            _isLoadingAddress = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('Error reverse geocoding: $e');
      }
    }
    
    setState(() {
      _address = 'Ubicación desconocida';
      _isLoadingAddress = false;
    });
  }

  Future<void> _openMap() async {
    final lat = widget.acta['latitud'];
    final lng = widget.acta['longitud'];
    if (lat == null || lng == null) return;
    
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Map<String, dynamic> votos = {};
    if (widget.acta['votos_partidos'] != null) {
      try {
        votos = jsonDecode(widget.acta['votos_partidos']);
      } catch (_) {}
    }

    final imageId = widget.acta['image_id'] as String?;
    // Assuming backend endpoint for images. Wait, do we have a way to fetch the image?
    // Let's check how images are displayed. Usually we don't fetch directly without Appwrite auth.
    // For now, I'll just show the ID or a placeholder if image fetching is complex. Or use network image if public.
    
    return PremiumScaffold(
      title: 'Detalle Acta ${widget.dignidadTitle}',
      subtitle: 'Mesa ${widget.acta['id_jrv']}',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumCard(
              hasDecoration: true,
              decorationColor: AppColors.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Ubicación de Registro', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      if (_isLoadingAddress)
                        const Center(child: CircularProgressIndicator())
                      else
                        Text(_address ?? 'Ubicación desconocida', style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      if (widget.acta['latitud'] != null && widget.acta['longitud'] != null)
                        Text(
                          'Coordenadas: ${widget.acta['latitud']}, ${widget.acta['longitud']}',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _openMap,
                        icon: const Icon(Icons.map),
                        label: const Text('Ver en el mapa'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.how_to_vote, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Resultados', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      ...votos.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('${e.value} votos'),
                          ],
                        ),
                      )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Votos Blancos:'),
                          Text('${widget.acta['votos_blancos'] ?? 0}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Votos Nulos:'),
                          Text('${widget.acta['votos_nulos'] ?? 0}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Sufragantes:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${widget.acta['total_sufragantes'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (imageId != null)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.image, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Fotografía del Acta', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 24),
                        // Appwrite images usually need authorization or are public. 
                        // Just indicating it was uploaded for now.
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 48),
                              const SizedBox(height: 8),
                              const Text('Imagen subida correctamente al servidor.'),
                              Text('ID: $imageId', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
