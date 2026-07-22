class SubscriptionPlanModel {
  final String id;
  final String name;
  final String role;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final int trialDurationDays;
  final Map<String, dynamic> features;
  final bool isRecommended;
  final bool isActive;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.trialDurationDays,
    required this.features,
    required this.isRecommended,
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SubscriptionPlanModel(
      id: documentId,
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      description: map['description'] ?? '',
      monthlyPrice: (map['monthlyPrice'] as num?)?.toDouble() ?? 0.0,
      yearlyPrice: (map['yearlyPrice'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'INR',
      trialDurationDays: map['trialDurationDays'] as int? ?? 0,
      features: Map<String, dynamic>.from(map['features'] ?? {}),
      isRecommended: map['isRecommended'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'description': description,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'currency': currency,
      'trialDurationDays': trialDurationDays,
      'features': features,
      'isRecommended': isRecommended,
      'isActive': isActive,
    };
  }
}
