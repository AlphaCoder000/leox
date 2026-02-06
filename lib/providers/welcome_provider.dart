import 'package:flutter/material.dart';
import 'package:leox/models/resource_point_model.dart';
import '../models/feature_model.dart';
import '../models/resource_model.dart';

class WelcomeController {
  // 🎨 App Colors (centralized)
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF64748B);

  // 🔹 Features Data
  static List<FeatureModel> features = [
    FeatureModel(
      icon: Icons.flash_on,
      title: "AI-Powered Matching",
      description: "Score and rank candidates instantly.",
    ),
    FeatureModel(
      icon: Icons.work_outline,
      title: "Centralized Job Board",
      description: "Manage all job postings easily.",
    ),
    FeatureModel(
      icon: Icons.people_outline,
      title: "Candidate Tracking",
      description: "Track applicants from start to hire.",
    ),
    FeatureModel(
      icon: Icons.analytics_outlined,
      title: "Insightful Analytics",
      description: "Make data-driven hiring decisions.",
    ),
  ];

  // 🔹 Resources Data
  static List<ResourceModel> resources = [
    ResourceModel(
      category: "Resume Guides",
      title: "Crafting a Resume That Stands Out",
      shortDescription:
          "Learn how to build a resume that passes ATS systems.",
      points: [
        ResourcePoint(
          title: "Tailor It to the Job",
          description:
              "Customize your resume for each application. Use keywords from the job description to show you're a perfect fit.",
        ),
        ResourcePoint(
          title: "Start with a Powerful Summary",
          description:
              "Write a 2–3 sentence summary highlighting your key qualifications and career goals.",
        ),
        ResourcePoint(
          title: "Focus on Accomplishments, Not Just Duties",
          description:
              "Quantify your impact with numbers instead of listing responsibilities.",
        ),
        ResourcePoint(
          title: "Keep It Clean and Readable",
          description:
              "Use professional fonts, clear headings, and sufficient spacing for readability.",
        ),
      ],
    ),


    ResourceModel(
      category: "Resume Guides",
      title: "Crafting a Resume That Stands Out",
      shortDescription: "Learn how to build a resume that passes ATS systems.",
      points: [
        ResourcePoint(
          title: "Use a clean and simple format",
          description: "Keep your resume layout simple and professional for easy reading.",
        ),
        ResourcePoint(
          title: "Highlight measurable achievements",
          description: "Showcase your accomplishments with numbers and results.",
        ),
        ResourcePoint(
          title: "Optimize keywords for ATS",
          description: "Include relevant keywords to pass applicant tracking systems.",
        ),
        ResourcePoint(
          title: "Avoid unnecessary graphics",
          description: "Stick to text and avoid images or graphics that may confuse ATS.",
        ),
        ResourcePoint(
          title: "Customize resume for each job",
          description: "Tailor your resume to match the requirements of each position.",
        ),
      ],
    ),

    // 🔥 REMAINING 2 CARDS
    ResourceModel(
      category: "Interview Prep",
      title: "Acing Your Next Behavioral Interview",
      shortDescription: "Behavioral interviews test real-life situations.",
      points: [
        ResourcePoint(
          title: "Understand the STAR method",
          description: "Structure your answers using Situation, Task, Action, and Result.",
        ),
        ResourcePoint(
          title: "Prepare real-world examples",
          description: "Think of specific situations from your experience to discuss.",
        ),
        ResourcePoint(
          title: "Focus on problem-solving",
          description: "Highlight how you approach and resolve challenges.",
        ),
        ResourcePoint(
          title: "Be honest and structured",
          description: "Answer questions truthfully and in a logical order.",
        ),
        ResourcePoint(
          title: "Practice communication clarity",
          description: "Speak clearly and concisely to convey your points effectively.",
        ),
      ],
    ),

    ResourceModel(
      category: "HR Trends",
      title: "The Rise of Internal Mobility Platforms",
      shortDescription: "Companies are investing in internal hiring solutions.",
      points: [
        ResourcePoint(
          title: "Boost employee retention",
          description: "Internal mobility helps keep talented employees within the company.",
        ),
        ResourcePoint(
          title: "Reduce hiring costs",
          description: "Filling roles internally saves on recruitment expenses.",
        ),
        ResourcePoint(
          title: "Encourage skill development",
          description: "Employees are motivated to learn new skills for advancement.",
        ),
        ResourcePoint(
          title: "Increase internal promotions",
          description: "More employees are promoted from within the organization.",
        ),
        ResourcePoint(
          title: "Improve workforce satisfaction",
          description: "Internal opportunities lead to higher job satisfaction.",
        ),
      ],
    ),
  ];

  // 🔹 Navigation (future)
  static void goToLogin(BuildContext context) {}
  static void goToRoleSelection(BuildContext context) {}
}
