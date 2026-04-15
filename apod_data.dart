class ApodData {
  final String title;
  final String date;
  final String explanation;
  final String url;
  final String? hdurl;
  final String mediaType; // image o video
  final String? copyright;

  const ApodData({
    required this.title,
    required this.date,
    required this.explanation,
    required this.url,
    required this.hdurl,
    required this.mediaType,
    required this.copyright,
  });

  factory ApodData.fromJson(Map<String, dynamic> json) {
    return ApodData(
      title: json['title'] as String? ?? 'Sin título',
      date: json['date'] as String? ?? '',
      explanation: json['explanation'] as String? ?? 'Sin explicación',
      url: json['url'] as String? ?? '',
      hdurl: json['hdurl'] as String?,
      mediaType: json['media_type'] as String? ?? 'image',
      copyright: json['copyright'] as String?,
    );
  }

  String get bestImageUrl {
    final candidate = (hdurl != null && hdurl!.isNotEmpty) ? hdurl! : url;
    return candidate.replaceFirst('http://', 'https://');
  }
}