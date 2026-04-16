class NeoAsteroid {
  final String id;
  final String name;
  final bool isHazardous;
  final double diameterMinMeters;
  final double diameterMaxMeters;
  final double missDistanceKm;
  final double velocityKmS;
  final String closeApproachDate;
  final String nasaJplUrl;

  const NeoAsteroid({
    required this.id,
    required this.name,
    required this.isHazardous,
    required this.diameterMinMeters,
    required this.diameterMaxMeters,
    required this.missDistanceKm,
    required this.velocityKmS,
    required this.closeApproachDate,
    required this.nasaJplUrl,
  });

  factory NeoAsteroid.fromJson(Map<String, dynamic> json) {
    final estimatedDiameter =
        json['estimated_diameter'] as Map<String, dynamic>? ?? {};
    final meters =
        estimatedDiameter['meters'] as Map<String, dynamic>? ?? {};

    final closeApproachData =
    (json['close_approach_data'] as List<dynamic>? ?? const []);

    final firstApproach = closeApproachData.isNotEmpty
        ? closeApproachData.first as Map<String, dynamic>
        : <String, dynamic>{};

    final relativeVelocity =
        firstApproach['relative_velocity'] as Map<String, dynamic>? ?? {};
    final missDistance =
        firstApproach['miss_distance'] as Map<String, dynamic>? ?? {};

    return NeoAsteroid(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Sin nombre',
      isHazardous:
      json['is_potentially_hazardous_asteroid'] as bool? ?? false,
      diameterMinMeters:
      (meters['estimated_diameter_min'] as num?)?.toDouble() ?? 0,
      diameterMaxMeters:
      (meters['estimated_diameter_max'] as num?)?.toDouble() ?? 0,
      missDistanceKm:
      double.tryParse(missDistance['kilometers']?.toString() ?? '') ?? 0,
      velocityKmS:
      double.tryParse(
        relativeVelocity['kilometers_per_second']?.toString() ?? '',
      ) ??
          0,
      closeApproachDate:
      firstApproach['close_approach_date'] as String? ?? '',
      nasaJplUrl: json['nasa_jpl_url'] as String? ?? '',
    );
  }
}