import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'apod_data.dart';
import 'apod_service.dart';
import 'neo_asteroid.dart';
import 'neo_service.dart';

void main() {
  runApp(const NasaApodApp());
}

class NasaApodApp extends StatelessWidget {
  const NasaApodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA APOD + NeoWs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const ApodPage(),
    );
  }
}

class ApodPage extends StatefulWidget {
  const ApodPage({super.key});

  @override
  State<ApodPage> createState() => _ApodPageState();
}

class _ApodPageState extends State<ApodPage> {
  ApodData? _apod;
  List<NeoAsteroid> _asteroids = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _asteroidsError;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _asteroidsError = null;
    });

    final dateStr = _formatDate(_selectedDate);

    try {
      final apodData = await fetchApod(date: dateStr);

      debugPrint('APOD MEDIA TYPE: ${apodData.mediaType}');
      debugPrint('APOD URL: ${apodData.url}');
      debugPrint('APOD HDURL: ${apodData.hdurl}');
      debugPrint('APOD BEST URL: ${apodData.bestImageUrl}');

      List<NeoAsteroid> asteroidData = [];
      String? asteroidError;

      try {
        asteroidData = await fetchClosestAsteroids(date: dateStr);
        debugPrint('NEO COUNT: ${asteroidData.length}');
      } catch (e) {
        asteroidError = e.toString();
      }

      if (!mounted) return;

      setState(() {
        _apod = apodData;
        _asteroids = asteroidData;
        _asteroidsError = asteroidError;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1995, 6, 16),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadData();
    }
  }

  String _formatKm(double km) {
    if (km >= 1000000) {
      return '${(km / 1000000).toStringAsFixed(2)} millones de km';
    }
    return '${km.toStringAsFixed(0)} km';
  }

  String _formatMeters(double min, double max) {
    return '${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)} m';
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_apod == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return _buildApodView(_apod!);
  }

  Widget _buildImage(ApodData apod) {
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              'En Flutter Web algunas imágenes remotas de APOD pueden fallar por restricciones del navegador.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 12),
            SelectableText(
              apod.bestImageUrl,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        apod.bestImageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'No se pudo cargar la imagen.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  apod.bestImageUrl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAsteroidsSection() {
    if (_asteroidsError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _asteroidsError!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_asteroids.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No se encontraron asteroides para esta fecha.'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _asteroids.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final asteroid = _asteroids[index];
        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${asteroid.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Fecha de aproximación: ${asteroid.closeApproachDate}'),
                Text('Distancia mínima: ${_formatKm(asteroid.missDistanceKm)}'),
                Text(
                  'Velocidad relativa: ${asteroid.velocityKmS.toStringAsFixed(2)} km/s',
                ),
                Text(
                  'Diámetro estimado: ${_formatMeters(asteroid.diameterMinMeters, asteroid.diameterMaxMeters)}',
                ),
                Text(
                  asteroid.isHazardous
                      ? 'Potencialmente peligroso: Sí'
                      : 'Potencialmente peligroso: No',
                  style: TextStyle(
                    color: asteroid.isHazardous ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (asteroid.nasaJplUrl.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    asteroid.nasaJplUrl,
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApodView(ApodData apod) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            apod.date,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            apod.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          if (apod.copyright != null)
            Text(
              '© ${apod.copyright}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 20),
          if (apod.mediaType == 'image')
            _buildImage(apod)
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.videocam),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'El recurso de este día es un vídeo.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      apod.url,
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Explicación',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            apod.explanation,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),
          Text(
            'Asteroides más cercanos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Objetos cercanos a la Tierra para la fecha ${apod.date}, ordenados por distancia mínima.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildAsteroidsSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NASA - Imagen del Día'),
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Seleccionar fecha',
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
