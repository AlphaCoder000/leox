class EmployerProfileModel {
  String name;
  String email;
  String phone;
  String companyName;
  String? profilePicture;
  String? contactNumber;
  String? address;
  String? linkedin;

  EmployerProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    this.profilePicture,
    this.contactNumber,
    this.address,
    this.linkedin,
  });

  factory EmployerProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployerProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      companyName: json['companyName'] ?? '',
      profilePicture: json['profilePicture'],
      contactNumber: json['contactNumber'],
      address: json['address'] ?? json['location'],
      linkedin: json['linkedin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (contactNumber != null) 'contactNumber': contactNumber,
      if (address != null) 'address': address,
      if (linkedin != null) 'linkedin': linkedin,
    };
  }
}
