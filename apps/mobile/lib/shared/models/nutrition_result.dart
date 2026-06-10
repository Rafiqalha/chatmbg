/// Data models for nutrition validation results.
library;

class ValidationResult {
  final String status; // 'memenuhi' | 'kurang' | 'tidak_memenuhi'
  final int score;
  final List<NutrientResult> nutrients;
  final List<String> suggestions;
  final String regulation;

  const ValidationResult({
    required this.status,
    required this.score,
    required this.nutrients,
    required this.suggestions,
    required this.regulation,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      status: json['status'] as String? ?? 'kurang',
      score: json['score'] as int? ?? 0,
      nutrients: (json['nutrients'] as List<dynamic>?)
              ?.map((e) => NutrientResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      regulation: json['regulation'] as String? ?? '',
    );
  }
}

class NutrientResult {
  final String name;
  final double value;
  final String unit;
  final double standard;
  final double percentage;
  final String status;

  const NutrientResult({
    required this.name,
    required this.value,
    required this.unit,
    required this.standard,
    required this.percentage,
    required this.status,
  });

  factory NutrientResult.fromJson(Map<String, dynamic> json) {
    return NutrientResult(
      name: json['name'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      standard: (json['standard'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'kurang',
    );
  }
}
