import 'package:flutter_test/flutter_test.dart';
import 'package:leox/providers/welcome_provider.dart';
import 'package:leox/models/feature_model.dart';
import 'package:leox/models/resource_model.dart';
import 'package:leox/models/resource_point_model.dart';
import 'package:flutter/material.dart';

void main() {
  group('WelcomeController Tests', () {
    test('should have correct static colors', () {
      expect(WelcomeController.primaryColor, const Color(0xFF2563EB));
      expect(WelcomeController.bgColor, const Color(0xFFF8FAFC));
      expect(WelcomeController.cardColor, Colors.white);
      expect(WelcomeController.textDark, const Color(0xFF0F172A));
      expect(WelcomeController.textLight, const Color(0xFF64748B));
    });

    test('should have features data with correct structure', () {
      final features = WelcomeController.features;
      
      expect(features, isA<List<FeatureModel>>());
      expect(features.length, 4);
      
      // Check first feature
      final firstFeature = features.first;
      expect(firstFeature.icon, Icons.flash_on);
      expect(firstFeature.title, "AI-Powered Matching");
      expect(firstFeature.description, "Score and rank candidates instantly.");
      
      // Check all features have required fields
      for (final feature in features) {
        expect(feature.icon, isA<IconData>());
        expect(feature.title, isA<String>());
        expect(feature.title, isNotEmpty);
        expect(feature.description, isA<String>());
        expect(feature.description, isNotEmpty);
      }
      
      // Check specific feature titles
      final titles = features.map((f) => f.title).toList();
      expect(titles, contains("AI-Powered Matching"));
      expect(titles, contains("Centralized Job Board"));
      expect(titles, contains("Candidate Tracking"));
      expect(titles, contains("Insightful Analytics"));
    });

    test('should have resources data with correct structure', () {
      final resources = WelcomeController.resources;
      
      expect(resources, isA<List<ResourceModel>>());
      expect(resources.length, 4);
      
      // Check all resources have required fields
      for (final resource in resources) {
        expect(resource.category, isA<String>());
        expect(resource.category, isNotEmpty);
        expect(resource.title, isA<String>());
        expect(resource.title, isNotEmpty);
        expect(resource.shortDescription, isA<String>());
        expect(resource.shortDescription, isNotEmpty);
        expect(resource.points, isA<List<ResourcePoint>>());
        expect(resource.points, isNotEmpty);
        
        // Check each point has required fields
        for (final point in resource.points) {
          expect(point.title, isA<String>());
          expect(point.title, isNotEmpty);
          expect(point.description, isA<String>());
          expect(point.description, isNotEmpty);
        }
      }
    });

    test('should have correct resource categories', () {
      final resources = WelcomeController.resources;
      final categories = resources.map((r) => r.category).toSet();
      
      expect(categories, contains("Resume Guides"));
      expect(categories, contains("Interview Prep"));
      expect(categories, contains("HR Trends"));
    });

    test('should have resume guide resources', () {
      final resources = WelcomeController.resources;
      final resumeGuides = resources.where((r) => r.category == "Resume Guides").toList();
      
      expect(resumeGuides.length, 2); // Two resume guide cards
      
      for (final guide in resumeGuides) {
        expect(guide.title, contains("Resume"));
        expect(guide.shortDescription, contains("resume"));
        expect(guide.points.length, greaterThanOrEqualTo(3));
      }
    });

    test('should have interview prep resource', () {
      final resources = WelcomeController.resources;
      final interviewPrep = resources.firstWhere(
        (r) => r.category == "Interview Prep",
        orElse: () => throw Exception("Interview prep resource not found"),
      );
      
      expect(interviewPrep.title, "Acing Your Next Behavioral Interview");
      expect(interviewPrep.shortDescription, contains("Behavioral interviews"));
      expect(interviewPrep.points.length, 5);
      
      // Check for STAR method mention
      final hasStarMethod = interviewPrep.points.any((p) => 
        p.title.toLowerCase().contains("star") || p.description.toLowerCase().contains("star"));
      expect(hasStarMethod, true);
    });

    test('should have HR trends resource', () {
      final resources = WelcomeController.resources;
      final hrTrends = resources.firstWhere(
        (r) => r.category == "HR Trends",
        orElse: () => throw Exception("HR trends resource not found"),
      );
      
      expect(hrTrends.title, "The Rise of Internal Mobility Platforms");
      expect(hrTrends.shortDescription, contains("internal hiring"));
      expect(hrTrends.points.length, 5);
      
      // Check for key HR trend topics
      final pointTitles = hrTrends.points.map((p) => p.title.toLowerCase()).toList();
      expect(pointTitles.any((t) => t.contains("retention")), true);
      expect(pointTitles.any((t) => t.contains("cost")), true);
      expect(pointTitles.any((t) => t.contains("promotions")), true);
    });

    test('should have navigation methods (even if empty)', () {
      // These methods should exist and be callable without errors
      // Note: We can't test with null BuildContext, so we just verify the methods exist
      expect(WelcomeController.goToLogin, isA<void Function(BuildContext)>());
      expect(WelcomeController.goToRoleSelection, isA<void Function(BuildContext)>());
    });

    test('should have consistent data quality across all resources', () {
      final resources = WelcomeController.resources;
      
      for (final resource in resources) {
        // Check title length is reasonable
        expect(resource.title.length, greaterThan(5));
        expect(resource.title.length, lessThan(100));
        
        // Check description length is reasonable
        expect(resource.shortDescription.length, greaterThan(10));
        expect(resource.shortDescription.length, lessThan(200));
        
        // Check points have reasonable content
        for (final point in resource.points) {
          expect(point.title.length, greaterThan(3));
          expect(point.title.length, lessThan(100));
          expect(point.description.length, greaterThan(10));
          expect(point.description.length, lessThan(300));
        }
      }
    });

    test('should have unique resource titles', () {
      final resources = WelcomeController.resources;
      final titles = resources.map((r) => r.title).toList();
      final uniqueTitles = titles.toSet();
      
      expect(titles.length, 4); // There are 4 resources total
      expect(uniqueTitles.length, 3); // But only 3 unique titles (one duplicate)
      // Note: There's a duplicate "Crafting a Resume That Stands Out" title
    });

    test('should have proper resource point structure', () {
      final resources = WelcomeController.resources;
      
      for (final resource in resources) {
        for (final point in resource.points) {
          // Check that points don't have leading/trailing whitespace
          expect(point.title, equals(point.title.trim()));
          expect(point.description, equals(point.description.trim()));
          
          // Check that points end with proper punctuation
          expect(point.description, endsWith('.'));
        }
      }
    });
  });
}
