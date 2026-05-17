class McSeekerModel {
  final String id;
  final String userName;
  final String email;
  final String phone;
  final String address;
  final String profilePicture;

  McSeekerModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.phone,
    required this.address,
    this.profilePicture = '',
  });

  factory McSeekerModel.fromJson(Map<String, dynamic> json, String documentId) {
    return McSeekerModel(
      id: documentId,
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'phone': phone,
      'address': address,
      'profilePicture': profilePicture,
    };
  }
}
