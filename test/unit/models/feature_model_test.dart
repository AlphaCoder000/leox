import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/feature_model.dart';

void main() {
  group('FeatureModel', () {
    test('Constructor should initialize properly', () {
      final model = FeatureModel(
        icon: Icons.star,
        title: 'Premium',
        description: 'Premium feature description',
      );

      expect(model.icon, Icons.star);
      expect(model.title, 'Premium');
      expect(model.description, 'Premium feature description');
    });
  });
}
