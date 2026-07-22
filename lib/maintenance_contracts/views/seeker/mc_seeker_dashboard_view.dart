import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/mc_seeker_auth_controller.dart';
import '../../controllers/mc_seeker_dashboard_controller.dart';
import 'mc_seeker_catalog_view.dart';
import 'mc_seeker_profile_view.dart';
import 'mc_seeker_bookings_view.dart';
import '../../../../providers/theme_povider.dart';
import '../../../../providers/subscription_provider.dart';
import '../../../../widgets/premium_paywall.dart';

import '../../../../widgets/subscription_status_badge.dart';

class McSeekerDashboardView extends StatefulWidget {
  const McSeekerDashboardView({super.key});

  @override
  State<McSeekerDashboardView> createState() => _McSeekerDashboardViewState();
}

class _McSeekerDashboardViewState extends State<McSeekerDashboardView> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const McSeekerCatalogView(),
      const McSeekerBookingsView(),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: PremiumPaywall(
          featureKey: 'book_services',
          onAuthorized: () {},
          isFullScreen: false,
        ),
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<SubscriptionProvider>().listenToSubscription(uid, 'seeker');
      }

      final authCtrl = context.read<McSeekerAuthController>();
      String? seekerId = authCtrl.currentSeeker?.id;

      // Auto-fetch if app was restarted and currentSeeker is null
      if (seekerId == null && FirebaseAuth.instance.currentUser != null) {
        await authCtrl.fetchSeekerProfile(FirebaseAuth.instance.currentUser!.uid);
        seekerId = authCtrl.currentSeeker?.id;
      }

      if (!mounted) return;

      if (seekerId != null) {
        context.read<McSeekerDashboardController>().fetchAllServices();
        context.read<McSeekerDashboardController>().fetchMyRequests(seekerId);
        context.read<McSeekerDashboardController>().fetchMyReviews(seekerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seeker Hub", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          const SubscriptionStatusBadge(),
          const SizedBox(width: 8),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.themeMode == ThemeMode.light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
          Consumer<McSeekerAuthController>(
            builder: (context, authController, _) {
              final seeker = authController.currentSeeker;
              return IconButton(
                icon: seeker?.profilePicture != null && seeker!.profilePicture.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(seeker.profilePicture),
                        backgroundColor: const Color(0xFF0EA5E9),
                        radius: 16,
                      )
                    : const Icon(Icons.account_circle, size: 28),
                onPressed: () {
                  final sId = authController.currentSeeker?.id;
                  if (sId != null) {
                    context.read<McSeekerDashboardController>().fetchMyReviews(sId);
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const McSeekerProfileView()));
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF0EA5E9),
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.handyman), label: "Catalog"),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "My Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Subscription"),
        ],
      ),
    );
  }
}
