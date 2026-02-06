import 'resource_point_model.dart';

class ResourceModel {
  final String category;
  final String title;
  final String shortDescription;
  final List<ResourcePoint> points;

  ResourceModel({
    required this.category,
    required this.title,
    required this.shortDescription,
    required this.points,
  });
}
