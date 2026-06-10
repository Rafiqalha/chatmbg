/// Data models for supplier directory.
library;

class Supplier {
  final String id;
  final String name;
  final String city;
  final String district;
  final List<String> categories;
  final int dailyCapacity;
  final bool verified;
  final int profileCompleteness;

  const Supplier({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
    required this.categories,
    required this.dailyCapacity,
    required this.verified,
    required this.profileCompleteness,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      dailyCapacity: json['daily_capacity'] as int? ?? 0,
      verified: json['verified'] as bool? ?? false,
      profileCompleteness: json['profile_completeness'] as int? ?? 0,
    );
  }
}
