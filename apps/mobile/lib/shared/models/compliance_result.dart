/// Data models for compliance check results.
library;

class ComplianceResult {
  final String checkType;
  final String overallStatus;
  final int score;
  final int passedCount;
  final int totalChecks;
  final List<ComplianceItem> items;
  final List<String> recommendations;

  const ComplianceResult({
    required this.checkType,
    required this.overallStatus,
    required this.score,
    required this.passedCount,
    required this.totalChecks,
    required this.items,
    required this.recommendations,
  });

  factory ComplianceResult.fromJson(Map<String, dynamic> json) {
    return ComplianceResult(
      checkType: json['check_type'] as String? ?? '',
      overallStatus: json['overall_status'] as String? ?? 'kurang',
      score: json['score'] as int? ?? 0,
      passedCount: json['passed_count'] as int? ?? 0,
      totalChecks: json['total_checks'] as int? ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ComplianceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class ComplianceItem {
  final String name;
  final String description;
  final bool passed;

  const ComplianceItem({
    required this.name,
    required this.description,
    required this.passed,
  });

  factory ComplianceItem.fromJson(Map<String, dynamic> json) {
    return ComplianceItem(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      passed: json['passed'] as bool? ?? false,
    );
  }
}
