class McReviewModel {
  final String id;
  final String seekerId;
  final String providerId;
  final String serviceId;
  final double rating; // 1.0 to 5.0
  final String comment;
  final DateTime dateTime;
  final String seekerName;
  final String serviceTitle;

  McReviewModel({
    required this.id,
    required this.seekerId,
    required this.providerId,
    required this.serviceId,
    required this.rating,
    required this.comment,
    required this.dateTime,
    required this.seekerName,
    required this.serviceTitle,
  });

  factory McReviewModel.fromJson(Map<String, dynamic> json, String documentId) {
    return McReviewModel(
      id: documentId,
      seekerId: json['seekerId'] ?? '',
      providerId: json['providerId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      dateTime: json['dateTime'] != null 
          ? DateTime.parse(json['dateTime']) 
          : DateTime.now(),
      seekerName: json['seekerName'] ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seekerId': seekerId,
      'providerId': providerId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'dateTime': dateTime.toIso8601String(),
      'seekerName': seekerName,
      'serviceTitle': serviceTitle,
    };
  }
}
