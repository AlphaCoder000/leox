class EmployerProfileModel {
  String name;
  String email;
  String phone;
  String companyName;
  String? profilePicture;

  EmployerProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    this.profilePicture,
  });

  factory EmployerProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployerProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      companyName: json['companyName'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      if (profilePicture != null) 'profilePicture': profilePicture,
    };
  }
}
