class McServiceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String providerId;
  final String status; // 'active', 'inactive', 'completed'

  McServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.providerId,
    this.status = 'active',
  });

  factory McServiceModel.fromJson(Map<String, dynamic> json, String documentId) {
    return McServiceModel(
      id: documentId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      providerId: json['providerId'] ?? '',
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'providerId': providerId,
      'status': status,
    };
  }
}
