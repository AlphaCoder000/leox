import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/mc_provider_auth_controller.dart';
import '../../controllers/mc_provider_dashboard_controller.dart';
import 'mc_provider_home_view.dart';
import 'mc_provider_profile_view.dart';
import 'mc_service_management_view.dart';
import 'mc_request_management_view.dart';
import '../../../providers/theme_povider.dart';

class McProviderDashboardView extends StatefulWidget {
  const McProviderDashboardView({super.key});

  @override
  State<McProviderDashboardView> createState() => _McProviderDashboardViewState();
}

class _McProviderDashboardViewState extends State<McProviderDashboardView> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authCtrl = context.read<McProviderAuthController>();
      String? providerId = authCtrl.currentProvider?.id;
      
      // Auto-fetch if app was restarted and currentProvider is null
      if (providerId == null && FirebaseAuth.instance.currentUser != null) {
        await authCtrl.fetchProviderProfile(FirebaseAuth.instance.currentUser!.uid);
        providerId = authCtrl.currentProvider?.id;
      }

      if (!mounted) return;

      if (providerId != null) {
        context.read<McProviderDashboardController>().fetchMyServices(providerId);
        context.read<McProviderDashboardController>().fetchIncomingRequests(providerId);
        context.read<McProviderDashboardController>().fetchProviderReviews(providerId);
      }
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Portal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
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
          Consumer<McProviderAuthController>(
            builder: (context, authController, _) {
              final provider = authController.currentProvider;
              return IconButton(
                icon: provider?.profilePicture != null && provider!.profilePicture.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(provider.profilePicture),
                        backgroundColor: const Color(0xFF0EA5E9),
                        radius: 14,
                      )
                    : const Icon(Icons.account_circle, size: 28),
                onPressed: () {
                  final pId = authController.currentProvider?.id;
                  if (pId != null) {
                    context.read<McProviderDashboardController>().fetchProviderReviews(pId);
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const McProviderProfileView()));
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          McProviderHomeView(
            onNavigate: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          const McServiceManagementView(),
          const McRequestManagementView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF0EA5E9),
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Overview"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Services"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Requests"),
        ],
      ),
    );
  }
}
