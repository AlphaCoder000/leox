class McRequestModel {
  final String id;
  final String seekerId;
  final String providerId;
  final String serviceId;
  final String status; // 'pending', 'accepted', 'completed', 'rejected'
  final DateTime dateTime;

  McRequestModel({
    required this.id,
    required this.seekerId,
    required this.providerId,
    required this.serviceId,
    this.status = 'pending',
    required this.dateTime,
  });

  factory McRequestModel.fromJson(Map<String, dynamic> json, String documentId) {
    return McRequestModel(
      id: documentId,
      seekerId: json['seekerId'] ?? '',
      providerId: json['providerId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      status: json['status'] ?? 'pending',
      dateTime: json['dateTime'] != null 
          ? DateTime.parse(json['dateTime']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seekerId': seekerId,
      'providerId': providerId,
      'serviceId': serviceId,
      'status': status,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
