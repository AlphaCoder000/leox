class McProviderModel {
  final String id;
  final String companyName;
  final String email;
  final String phone;
  final String location;
  final double rating;
  final String profilePicture;

  McProviderModel({
    required this.id,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.location,
    this.rating = 0.0,
    this.profilePicture = '',
  });

  factory McProviderModel.fromJson(Map<String, dynamic> json, String documentId) {
    return McProviderModel(
      id: documentId,
      companyName: json['companyName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      profilePicture: json['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'location': location,
      'rating': rating,
      'profilePicture': profilePicture,
    };
  }
}
