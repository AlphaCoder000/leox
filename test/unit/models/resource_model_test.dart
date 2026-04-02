import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/resource_model.dart';
import 'package:leox/models/resource_point_model.dart';

void main() {
  group('Resource Models', () {
    test('ResourcePoint constructor should initialize properly', () {
      final point = ResourcePoint(title: 'Point A', description: 'Desc A');
      
      expect(point.title, 'Point A');
      expect(point.description, 'Desc A');
    });

    test('ResourceModel constructor should initialize properly', () {
      final points = [ResourcePoint(title: 'Point A', description: 'Desc A')];
      final model = ResourceModel(
        category: 'Tech',
        title: 'Flutter',
        shortDescription: 'UI Toolkit',
        points: points,
      );

      expect(model.category, 'Tech');
      expect(model.title, 'Flutter');
      expect(model.shortDescription, 'UI Toolkit');
      expect(model.points, points);
      expect(model.points.first.title, 'Point A');
    });
  });
}
