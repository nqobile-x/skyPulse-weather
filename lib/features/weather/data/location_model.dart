/// Simple location model used for search results.
class LocationModel {
  const LocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1; // State/province

  /// Human-readable display name.
  String get displayName {
    final parts = <String>[name];
    if (admin1 != null && admin1!.isNotEmpty) parts.add(admin1!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
    );
  }
}
