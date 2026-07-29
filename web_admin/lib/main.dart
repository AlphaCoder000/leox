import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Reusing models from the parent mobile application package!
import 'package:leox/models/subscription_plan_model.dart';
import 'package:leox/models/subscription_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LEO OPUS Subscriptions Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        cardColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// ================= AUTH WRAPPER =================

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _errorMsg;
  bool _initialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      // 1. Check if already initialized, otherwise initialize
      try {
        Firebase.app();
        if (mounted) {
          setState(() => _initialized = true);
        }
        return;
      } catch (_) {}

      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBNVp_4-eg-QNAlAWY612osmTcOLVrcGXU',
          appId: '1:340682426505:web:a17da0b67f34bd22135e58',
          messagingSenderId: '340682426505',
          projectId: 'studio-7488920972-4ef9c',
          storageBucket: 'studio-7488920972-4ef9c.appspot.com',
        ),
      );
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _initError = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Firebase Setup Error",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Could not connect to Firebase: $_initError\nPlease verify your keys or network connection.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                "Connecting to LEO OPUS Services...",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginScreen(
            initialError: _errorMsg,
            onError: (msg) => setState(() => _errorMsg = msg),
          );
        }

        // Validate custom claims to ensure only admins can enter
        return FutureBuilder<IdTokenResult>(
          future: user.getIdTokenResult(true),
          builder: (context, tokenSnap) {
            if (tokenSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isAdmin = tokenSnap.data?.claims?['admin'] == true;

            if (!isAdmin) {
              // Not an admin, kick out
              FirebaseAuth.instance.signOut();
              return LoginScreen(
                initialError:
                    "Access Denied: You are not authorized as an administrator.",
                onError: (msg) => setState(() => _errorMsg = msg),
              );
            }

            return const AdminDashboardShell();
          },
        );
      },
    );
  }
}

// ================= LOGIN SCREEN =================

class LoginScreen extends StatefulWidget {
  final String? initialError;
  final Function(String) onError;

  const LoginScreen({super.key, this.initialError, required this.onError});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _localError;
  bool _isRegisterMode = false;
  bool _isForgotPasswordMode = false;
  bool _bootstrapMode = false;

  @override
  void initState() {
    super.initState();
    _localError = widget.initialError;
    _checkSetupStatus();
  }

  Future<void> _checkSetupStatus() async {
    try {
      final response = await http.get(
        Uri.parse('https://leo-opus.onrender.com/api/subscription/admin/setup-status'),
      ).timeout(const Duration(seconds: 4));
      
      final result = jsonDecode(response.body);
      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _bootstrapMode = result['bootstrapMode'] == true;
          });
        } else {
          setState(() {
            _localError = "Backend check failed: ${result['error']}";
          });
        }
      }
    } catch (e) {
      debugPrint('[Login] Error checking admin bootstrap status: $e');
      if (mounted) {
        setState(() {
          _localError = "Cannot connect to backend server. Please verify it is running on http://localhost:3000";
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _localError = "Please fill in all fields.");
      return;
    }

    setState(() {
      _isLoading = true;
      _localError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/subscription/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        final customToken = result['customToken'];
        await FirebaseAuth.instance.signInWithCustomToken(customToken);
      } else {
        setState(() {
          _localError = result['error'] ?? "Failed to authenticate as administrator.";
        });
      }
    } catch (e) {
      setState(() {
        _localError = "Connection failed: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _localError = "Please fill in all fields.");
      return;
    }

    if (password != confirmPassword) {
      setState(() => _localError = "Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
      _localError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/subscription/admin/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        // Automatically login the newly created admin
        await _login();
      } else {
        setState(() {
          _localError = result['error'] ?? "Failed to register administrator.";
        });
      }
    } catch (e) {
      setState(() {
        _localError = "Connection failed: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(
        () =>
            _localError =
                "Please enter your email address to receive reset link.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _localError = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Password reset email sent to $email! Check your inbox.",
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isForgotPasswordMode = false;
        });
      }
    } catch (e) {
      setState(() {
        _localError = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title = "LEO OPUS Portal";
    String subtitle = "Subscription Management Console";
    String buttonText = "Enter Dashboard";

    if (_isForgotPasswordMode) {
      title = "Reset Password";
      subtitle = "Receive password reset instructions by email";
      buttonText = "Send Reset Link";
    } else if (_isRegisterMode) {
      title = "Create Admin Account";
      subtitle = "Register as a platform administrator";
      buttonText = "Register & Login";
    }

    return Scaffold(
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                _isRegisterMode
                    ? Icons.person_add_outlined
                    : (_isForgotPasswordMode
                        ? Icons.key_outlined
                        : Icons.shield_outlined),
                size: 64,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (_localError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _localError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Admin Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              if (!_isForgotPasswordMode) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
              if (_isRegisterMode) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : (_isForgotPasswordMode
                            ? _sendPasswordReset
                            : (_isRegisterMode ? _register : _login)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(height: 16),

              // 🔹 TOGGLE MODES ACTIONS
              if (!_isForgotPasswordMode && !_isRegisterMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed:
                          () => setState(() {
                            _isForgotPasswordMode = true;
                            _localError = null;
                          }),
                      child: const Text("Forgot Password?"),
                    ),
                    if (_bootstrapMode)
                      TextButton(
                        onPressed:
                            () => setState(() {
                              _isRegisterMode = true;
                              _localError = null;
                            }),
                        child: const Text("Create Admin Account"),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ] else ...[
                Center(
                  child: TextButton(
                    onPressed:
                        () => setState(() {
                          _isForgotPasswordMode = false;
                          _isRegisterMode = false;
                          _localError = null;
                        }),
                    child: const Text("Back to Login"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================= CONSOLE SHELL =================

class AdminDashboardShell extends StatefulWidget {
  const AdminDashboardShell({super.key});

  @override
  State<AdminDashboardShell> createState() => _AdminDashboardShellState();
}

class _AdminDashboardShellState extends State<AdminDashboardShell> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const AnalyticsView(),
    const PlanManagementView(),
    const UserManagementView(),
    const CouponManagementView(),
    const AdminsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text(
                "LEO OPUS ADMIN",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: _buildSidebarContent(context, true),
            )
          : null,
      body: Row(
        children: [
          // Sidebar (desktop only)
          if (!isMobile)
            Container(
              width: 250,
              color: const Color(0xFF0F172A),
              child: _buildSidebarContent(context, false),
            ),
          // Viewport Content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: _views[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context, bool isDrawer) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0F172A)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Colors.blue,
                ),
                SizedBox(height: 8),
                Text(
                  "LEO OPUS ADMIN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          _sidebarItem(0, Icons.analytics_outlined, "Analytics", isDrawer),
          _sidebarItem(1, Icons.tune_outlined, "Subscription Plans", isDrawer),
          _sidebarItem(2, Icons.people_outline_rounded, "Users Registry", isDrawer),
          _sidebarItem(3, Icons.local_offer_outlined, "Coupons", isDrawer),
          _sidebarItem(4, Icons.admin_panel_settings_outlined, "Admins", isDrawer),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Log Out",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Log Out"),
                  content: const Text("Are you sure you want to log out of the LEO OPUS Admin Console?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (isDrawer) Navigator.pop(context);
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text("Log Out"),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title, bool isDrawer) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
      onTap: () {
        setState(() => _selectedIndex = index);
        if (isDrawer) {
          Navigator.pop(context);
        }
      },
    );
  }
}

// ================= VIEW: ANALYTICS =================

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: fs.collection('subscriptions').snapshots(),
      builder: (context, subSnapshot) {
        if (subSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<QuerySnapshot>(
          stream: fs.collection('subscription_plans').snapshots(),
          builder: (context, planSnapshot) {
            if (planSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final subs = subSnapshot.data?.docs ?? [];
            final plansDocs = planSnapshot.data?.docs ?? [];

            // Map planId to actual monthly/yearly prices and names
            final Map<String, double> planMonthlyPrices = {};
            final Map<String, double> planYearlyPrices = {};
            final Map<String, String> planNames = {};

            for (var doc in plansDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final pId = doc.id;
              planMonthlyPrices[pId] = (data['monthlyPrice'] as num?)?.toDouble() ?? 0.0;
              planYearlyPrices[pId] = (data['yearlyPrice'] as num?)?.toDouble() ?? 0.0;
              planNames[pId] = data['name'] ?? pId;
            }

            // Calculations
            int activeCount = 0;
            int trialCount = 0;
            double mrr = 0.0;
            final Map<String, int> planCounts = {};

            String? targetRole;
            if (_tabController.index == 1) targetRole = 'employer';
            if (_tabController.index == 2) targetRole = 'employee';
            if (_tabController.index == 3) targetRole = 'provider';
            if (_tabController.index == 4) targetRole = 'seeker';

            for (var doc in subs) {
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'expired';
              final planId = data['planId'] ?? '';
              final billingCycle = data['billingCycle'] ?? 'monthly';
              final role = data['role'] ?? '';

              // Filter by selected tab role
              if (targetRole != null && role != targetRole) continue;

              if (status == 'active') {
                activeCount++;
                
                // Calculate dynamic MRR contribution based on real plan details
                double price = 0.0;
                if (billingCycle == 'yearly') {
                  price = (planYearlyPrices[planId] ?? 0.0) / 12;
                } else {
                  price = planMonthlyPrices[planId] ?? 0.0;
                }
                mrr += price;

                // Count active plans for distribution
                planCounts[planId] = (planCounts[planId] ?? 0) + 1;
              } else if (status == 'trial') {
                trialCount++;
              }
            }

            final totalActive = activeCount > 0 ? activeCount : 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Analytics Dashboard",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: "All Roles"),
                    Tab(text: "Employers"),
                    Tab(text: "Employees"),
                    Tab(text: "Providers"),
                    Tab(text: "Seekers"),
                  ],
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount = width < 600 ? 1 : (width < 1000 ? 2 : 4);
                    
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: width < 600 ? 3.0 : 1.8,
                      children: [
                        _metricCard(
                          "Active Subscriptions",
                          activeCount.toString(),
                          Icons.check_circle_outline,
                          Colors.green,
                        ),
                        _metricCard(
                          "Free Trial Users",
                          trialCount.toString(),
                          Icons.hourglass_empty,
                          Colors.amber,
                        ),
                        _metricCard(
                          "Monthly Recurring Revenue (MRR)",
                          "₹${mrr.toStringAsFixed(0)}",
                          Icons.monetization_on_outlined,
                          Colors.blue,
                        ),
                        _metricCard(
                          "Annual Run Rate (ARR)",
                          "₹ ${(mrr * 12).toStringAsFixed(0)}",
                          Icons.trending_up,
                          Colors.purple,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  "Popular Plans Distribution",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: planCounts.isEmpty
                          ? const Center(child: Text("No active subscriptions found to display distribution."))
                          : ListView(
                              children: planCounts.entries.map((entry) {
                                final planId = entry.key;
                                final count = entry.value;
                                final pct = ((count / totalActive) * 100).round();
                                final name = planNames[planId] ?? planId;

                                Color col = Colors.blue;
                                if (planId.contains('employer')) col = Colors.orange;
                                if (planId.contains('employee')) col = Colors.green;
                                if (planId.contains('provider')) col = Colors.purple;
                                if (planId.contains('seeker')) col = Colors.teal;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: _barDistribution("$name ($count)", pct, col),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _metricCard(String title, String val, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  val,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _barDistribution(String name, int val, Color col) {
    return Row(
      children: [
        SizedBox(width: 150, child: Text(name)),
        Expanded(
          child: LinearProgressIndicator(
            value: val / 100,
            color: col,
            backgroundColor: Colors.white10,
            minHeight: 12,
          ),
        ),
        const SizedBox(width: 16),
        Text("$val %"),
      ],
    );
  }
}

// ================= VIEW: PLAN MANAGEMENT =================

class PlanManagementView extends StatefulWidget {
  const PlanManagementView({super.key});

  @override
  State<PlanManagementView> createState() => _PlanManagementViewState();
}

class _PlanManagementViewState extends State<PlanManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPlanDialog(BuildContext context, [SubscriptionPlanModel? plan]) {
    final fs = FirebaseFirestore.instance;
    final nameController = TextEditingController(text: plan?.name ?? '');
    final descController = TextEditingController(text: plan?.description ?? '');
    final monthlyController = TextEditingController(
      text: plan?.monthlyPrice.toString() ?? '199.00',
    );
    final yearlyController = TextEditingController(
      text: plan?.yearlyPrice.toString() ?? '1999.00',
    );
    final trialController = TextEditingController(
      text: plan?.trialDurationDays.toString() ?? '30',
    );
    final idController = TextEditingController(text: plan?.id ?? '');

    String currentTabRole = 'employer';
    if (_tabController.index == 1) {
      currentTabRole = 'employee';
    } else if (_tabController.index == 2) {
      currentTabRole = 'provider';
    } else if (_tabController.index == 3) {
      currentTabRole = 'seeker';
    }

    String selectedRole = plan?.role ?? currentTabRole;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              plan == null
                  ? "Create Subscription Plan"
                  : "Edit Plan: ${plan.name}",
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (plan == null)
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: "Plan Identifier ID (e.g. employer_premium)",
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Plan Name"),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text("All Roles (Common Plan)"),
                      ),
                      DropdownMenuItem(
                        value: 'employee',
                        child: Text("Employee"),
                      ),
                      DropdownMenuItem(
                        value: 'employer',
                        child: Text("Employer"),
                      ),
                      DropdownMenuItem(
                        value: 'provider',
                        child: Text("Provider"),
                      ),
                      DropdownMenuItem(value: 'seeker', child: Text("Seeker")),
                    ],
                    onChanged: (v) => selectedRole = v!,
                    decoration: const InputDecoration(labelText: "Role Group"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: monthlyController,
                    decoration: const InputDecoration(
                      labelText: "Monthly Price (INR)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: yearlyController,
                    decoration: const InputDecoration(
                      labelText: "Yearly Price (INR)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: trialController,
                    decoration: const InputDecoration(
                      labelText: "Free Trial Duration (Days)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final id = plan?.id ?? idController.text.trim();
                  final monthly = double.tryParse(monthlyController.text.trim()) ?? 199.00;
                  final yearly = double.tryParse(yearlyController.text.trim()) ?? 1999.00;
                  final trialDays = int.tryParse(trialController.text.trim()) ?? 30;
                  final desc = descController.text.trim();

                  final rolesToUpdate = selectedRole == 'all'
                      ? ['employer', 'employee', 'provider', 'seeker']
                      : [selectedRole];

                  for (final r in rolesToUpdate) {
                    final planDocId = selectedRole == 'all' ? '${r}_monthly' : (id.isEmpty ? '${r}_monthly' : id);
                    final payload = {
                      'name': nameController.text.trim().isEmpty ? "${r.toUpperCase()} Premium Plan" : nameController.text.trim(),
                      'role': r,
                      'monthlyPrice': monthly,
                      'yearlyPrice': yearly,
                      'trialDurationDays': trialDays,
                      'description': desc,
                      'isActive': plan?.isActive ?? true,
                      'isRecommended': plan?.isRecommended ?? true,
                      'currency': 'INR',
                      'features': plan?.features ?? {
                        'post_jobs': r == 'employer',
                        'resume_matching': r != 'seeker',
                        'view_candidates': r == 'employer',
                        'book_services': r == 'seeker',
                        'create_services': r == 'provider',
                      },
                    };

                    await fs
                        .collection('subscription_plans')
                        .doc(planDocId)
                        .set(payload, SetOptions(merge: true));
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Save Plan"),
              ),
            ],
          ),
    );
  }

  Future<void> _setupCommonPlan(BuildContext context) async {
    final fs = FirebaseFirestore.instance;
    final roles = ['employer', 'employee', 'provider', 'seeker'];
    for (final r in roles) {
      await fs.collection('subscription_plans').doc('${r}_monthly').set({
        'name': '${r.toUpperCase()} Premium Plan',
        'role': r,
        'monthlyPrice': 199.00,
        'yearlyPrice': 1999.00,
        'trialDurationDays': 30,
        'description': 'Universal ₹199 premium plan with 30 days initial free trial.',
        'isActive': true,
        'isRecommended': true,
        'currency': 'INR',
        'features': {
          'post_jobs': r == 'employer',
          'resume_matching': r != 'seeker',
          'view_candidates': r == 'employer',
          'book_services': r == 'seeker',
          'create_services': r == 'provider',
        },
      }, SetOptions(merge: true));
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Common ₹199 plan established for all 4 account roles!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Subscription Plan Settings",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _setupCommonPlan(context),
                  icon: const Icon(Icons.bolt),
                  label: const Text("Set Universal ₹199 Plan (All Roles)"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showPlanDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text("Create Plan"),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Employer Plans"),
            Tab(text: "Employee Plans"),
            Tab(text: "Provider Plans"),
            Tab(text: "Seeker Plans"),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: fs.collection('subscription_plans').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              String targetRole = 'employer';
              if (_tabController.index == 1) {
                targetRole = 'employee';
              } else if (_tabController.index == 2) {
                targetRole = 'provider';
              } else if (_tabController.index == 3) {
                targetRole = 'seeker';
              }

              final roleDocs = docs.where((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return d['role'] == targetRole;
              }).toList();

              if (roleDocs.isEmpty) {
                return const Center(child: Text("No plans defined for this role group."));
              }

              return ListView.builder(
                itemCount: roleDocs.length,
                itemBuilder: (context, index) {
                  final data = roleDocs[index].data() as Map<String, dynamic>;
                  final plan = SubscriptionPlanModel.fromMap(data, roleDocs[index].id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(
                        plan.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(plan.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "₹${plan.monthlyPrice.toStringAsFixed(0)} / mo",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          Switch(
                            value: plan.isActive,
                            onChanged: (val) async {
                              await fs
                                  .collection('subscription_plans')
                                  .doc(plan.id)
                                  .update({'isActive': val});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showPlanDialog(context, plan),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ================= VIEW: USER SUBSCRIPTIONS =================

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _filterPlan = 'All';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchUserProfile(String userId, String role) async {
    String collectionName;
    if (role == 'employer') {
      collectionName = 'employers';
    } else if (role == 'employee') {
      collectionName = 'employees';
    } else if (role == 'provider') {
      collectionName = 'mc_providers';
    } else if (role == 'seeker') {
      collectionName = 'mc_seekers';
    } else {
      return null;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection(collectionName).doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (_) {
      return null;
    }
  }

  void _triggerBackendOverride(
    BuildContext context,
    String userId,
    String action, [
    int? days,
    String? planId,
  ]) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      final response = await http.post(
        Uri.parse('http://localhost:3000/api/subscription/admin/modify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'action': action,
          if (days != null) 'extensionDays': days,
          if (planId != null) 'planId': planId,
          'reason': 'Consular manual override action',
        }),
      );

      final result = jsonDecode(response.body);

      if (context.mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Action '$action' processed successfully.")),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${result['error']}")));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("API communication failed: $e")));
      }
    }
  }

  void _showComplimentaryDialog(BuildContext context, String userId) {
    final daysController = TextEditingController(text: '30');
    
    // Determine the user's role from the composite ID to offer relevant plans
    String role = 'employer';
    if (userId.contains('_')) {
      role = userId.split('_')[1];
    }
    
    String selectedPlan = '${role}_yearly';
    if (role == 'seeker') {
      selectedPlan = 'seeker_free_trial'; // Seeker default
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Grant Complimentary Plan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: daysController,
                  decoration: const InputDecoration(labelText: "Duration (Days)"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPlan,
                  decoration: const InputDecoration(labelText: "Select Plan"),
                  items: [
                    if (role == 'employer') ...const [
                      DropdownMenuItem(value: 'employer_yearly', child: Text("Employer Premium (Yearly)")),
                      DropdownMenuItem(value: 'employer_monthly', child: Text("Employer Basic (Monthly)")),
                      DropdownMenuItem(value: 'employer_free_trial', child: Text("Employer Free Trial")),
                    ] else if (role == 'employee') ...const [
                      DropdownMenuItem(value: 'employee_yearly', child: Text("Employee Pro (Yearly)")),
                      DropdownMenuItem(value: 'employee_monthly', child: Text("Employee Pro (Monthly)")),
                      DropdownMenuItem(value: 'employee_free_trial', child: Text("Employee Free Trial")),
                    ] else if (role == 'provider') ...const [
                      DropdownMenuItem(value: 'provider_yearly', child: Text("Provider Pro (Yearly)")),
                      DropdownMenuItem(value: 'provider_monthly', child: Text("Provider Pro (Monthly)")),
                      DropdownMenuItem(value: 'provider_free_trial', child: Text("Provider Free Trial")),
                    ] else if (role == 'seeker') ...const [
                      DropdownMenuItem(value: 'seeker_free', child: Text("Seeker Basic")),
                      DropdownMenuItem(value: 'seeker_free_trial', child: Text("Seeker Free Trial")),
                    ],
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      selectedPlan = val;
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final days = int.tryParse(daysController.text) ?? 30;
                  _triggerBackendOverride(context, userId, 'grant_complimentary', days, selectedPlan);
                  Navigator.pop(context);
                },
                child: const Text("Grant"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "User Subscriptions Registry",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: "Search User UID",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _filterPlan,
              items: const [
                DropdownMenuItem(
                  value: 'All',
                  child: Text("Filter: All Plans"),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text("Filter: Active Only"),
                ),
                DropdownMenuItem(
                  value: 'trial',
                  child: Text("Filter: Trial Only"),
                ),
                DropdownMenuItem(
                  value: 'expired',
                  child: Text("Filter: Expired Only"),
                ),
              ],
              onChanged: (v) => setState(() => _filterPlan = v!),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(text: "All Roles"),
            Tab(text: "Employers"),
            Tab(text: "Employees"),
            Tab(text: "Providers"),
            Tab(text: "Seekers"),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: fs.collection('subscriptions').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data?.docs ?? [];

              // Filter out obsolete legacy document IDs (must contain '_')
              docs = docs.where((doc) => doc.id.contains('_')).toList();

              // Search Filter
              if (_searchController.text.isNotEmpty) {
                docs =
                    docs
                        .where((doc) => doc.id.contains(_searchController.text))
                        .toList();
              }

              // Status Filter
              if (_filterPlan != 'All') {
                docs =
                    docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == _filterPlan;
                    }).toList();
              }

              // Tab Role Filter
              if (_tabController.index == 1) {
                docs = docs.where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'employer').toList();
              } else if (_tabController.index == 2) {
                docs = docs.where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'employee').toList();
              } else if (_tabController.index == 3) {
                docs = docs.where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'provider').toList();
              } else if (_tabController.index == 4) {
                docs = docs.where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'seeker').toList();
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final sub = SubscriptionModel.fromMap(data, docs[index].id);

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchUserProfile(sub.userId, sub.role),
                    builder: (context, userSnapshot) {
                      final profile = userSnapshot.data;
                      final name = profile?['name'] ?? profile?['userName'] ?? profile?['companyName'] ?? 'No Name / Pending Setup';
                      final email = profile?['email'] ?? 'No Email Profile';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Email: $email | UID: ${sub.userId}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(sub.role.toUpperCase()),
                                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                      ),
                                      const SizedBox(width: 8),
                                      Chip(label: Text(sub.planId)),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text(sub.status.toUpperCase()),
                                        backgroundColor:
                                            sub.isActive
                                                ? Colors.green.withValues(
                                                  alpha: 0.2,
                                                )
                                                : Colors.red.withValues(alpha: 0.2),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                "Expires: ${sub.endDate.toLocal().toString().split(' ')[0]}",
                              ),
                              const SizedBox(width: 24),
                              // Actions Dropdown
                              PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'extend_30') {
                                    _triggerBackendOverride(
                                      context,
                                      docs[index].id,
                                      'extend',
                                      30,
                                    );
                                  } else if (val == 'cancel') {
                                    _triggerBackendOverride(
                                      context,
                                      docs[index].id,
                                      'cancel',
                                    );
                                  } else if (val == 'reset_trial') {
                                    _triggerBackendOverride(
                                      context,
                                      docs[index].id,
                                      'reset_trial',
                                    );
                                  } else if (val == 'grant_comp') {
                                    _showComplimentaryDialog(context, docs[index].id);
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'extend_30',
                                        child: Text("Extend Sub +30 Days"),
                                      ),
                                      const PopupMenuItem(
                                        value: 'grant_comp',
                                        child: Text("Grant Complimentary Plan"),
                                      ),
                                      const PopupMenuItem(
                                        value: 'reset_trial',
                                        child: Text("Reset 30-Day Free Trial"),
                                      ),
                                      const PopupMenuItem(
                                        value: 'cancel',
                                        child: Text("Cancel Subscription"),
                                      ),
                                    ],
                                child: ElevatedButton(
                                  onPressed: null,
                                  child: Row(
                                    children: [
                                      const Text("Manage Actions"),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ================= VIEW: COUPONS =================

class CouponManagementView extends StatefulWidget {
  const CouponManagementView({super.key});

  @override
  State<CouponManagementView> createState() => _CouponManagementViewState();
}

class _CouponManagementViewState extends State<CouponManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCouponDialog(BuildContext context) {
    final fs = FirebaseFirestore.instance;
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    final usesController = TextEditingController(text: '100');
    final daysController = TextEditingController(text: '0');

    String selectedType = 'percentage';
    List<String> selectedRoles = ['employer', 'employee', 'provider', 'seeker'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Create Coupon Code"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: "Coupon Code (e.g. SAVE50)",
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: 'percentage',
                        child: Text("Percentage Discount"),
                      ),
                      DropdownMenuItem(
                        value: 'flat',
                        child: Text("Flat INR Discount"),
                      ),
                    ],
                    onChanged: (v) => selectedType = v!,
                    decoration: const InputDecoration(labelText: "Discount Type"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: valueController,
                    decoration: const InputDecoration(
                      labelText: "Discount Value (e.g. 50 for 50%)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: usesController,
                    decoration: const InputDecoration(
                      labelText: "Maximum Usages Limit",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: daysController,
                    decoration: const InputDecoration(
                      labelText: "Bonus Trial Extension (Days)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Applicable Account Roles:", style: TextStyle(fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () {
                                  setDialogState(() {
                                    if (selectedRoles.length == 4) {
                                      selectedRoles.clear();
                                    } else {
                                      selectedRoles = ['employer', 'employee', 'provider', 'seeker'];
                                    }
                                  });
                                },
                                child: Text(selectedRoles.length == 4 ? "Deselect All" : "Select All (Common Coupon)"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            title: const Text("Employers"),
                            value: selectedRoles.contains('employer'),
                            dense: true,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedRoles.add('employer');
                                } else {
                                  selectedRoles.remove('employer');
                                }
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Employees"),
                            value: selectedRoles.contains('employee'),
                            dense: true,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedRoles.add('employee');
                                } else {
                                  selectedRoles.remove('employee');
                                }
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Providers"),
                            value: selectedRoles.contains('provider'),
                            dense: true,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedRoles.add('provider');
                                } else {
                                  selectedRoles.remove('provider');
                                }
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Seekers"),
                            value: selectedRoles.contains('seeker'),
                            dense: true,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedRoles.add('seeker');
                                } else {
                                  selectedRoles.remove('seeker');
                                }
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final code = codeController.text.trim().toUpperCase();
                  if (code.isEmpty) return;

                  // Get all active plans from database
                  final plansSnap = await fs.collection('subscription_plans').get();
                  final planIds = plansSnap.docs.map((doc) => doc.id).toList();

                  final payload = {
                    'code': code,
                    'discountType': selectedType,
                    'discountValue':
                        double.tryParse(valueController.text.trim()) ?? 0.0,
                    'maxUses': int.tryParse(usesController.text.trim()) ?? 100,
                    'useCount': 0,
                    'trialExtensionDays':
                        int.tryParse(daysController.text.trim()) ?? 0,
                    'isActive': true,
                    'applicablePlans': planIds,
                    'applicableRoles': selectedRoles,
                    'expiryDate': Timestamp.fromDate(
                      DateTime.now().add(const Duration(days: 30)),
                    ),
                    'createdAt': FieldValue.serverTimestamp(),
                  };

                  await fs.collection('coupons').doc(code).set(payload);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Save Coupon"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Coupon & Promotion Manager",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showCouponDialog(context),
                  icon: const Icon(Icons.stars_rounded),
                  label: const Text("Create Common Coupon (All Roles)"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCouponDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text("Create Coupon"),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(text: "All Coupons"),
            Tab(text: "Employer Coupons"),
            Tab(text: "Employee Coupons"),
            Tab(text: "Provider Coupons"),
            Tab(text: "Seeker Coupons"),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: fs.collection('coupons').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              String? targetRole;
              if (_tabController.index == 1) {
                targetRole = 'employer';
              } else if (_tabController.index == 2) {
                targetRole = 'employee';
              } else if (_tabController.index == 3) {
                targetRole = 'provider';
              } else if (_tabController.index == 4) {
                targetRole = 'seeker';
              }

              final filteredDocs = docs.where((doc) {
                if (targetRole == null) return true;
                final d = doc.data() as Map<String, dynamic>;
                final roles = List<String>.from(d['applicableRoles'] ?? []);
                return roles.isEmpty || roles.contains(targetRole);
              }).toList();

              if (filteredDocs.isEmpty) {
                return const Center(child: Text("No coupons applicable for this role."));
              }

              return ListView.builder(
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final data = filteredDocs[index].data() as Map<String, dynamic>;
                  final roles = List<String>.from(data['applicableRoles'] ?? []);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        data['code'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Discount: ${data['discountValue']} (${data['discountType']}) | Used: ${data['useCount']} / ${data['maxUses']}"),
                          const SizedBox(height: 4),
                          Text("Roles: ${roles.isEmpty ? 'All' : roles.join(', ').toUpperCase()}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: Switch(
                        value: data['isActive'] ?? true,
                        onChanged: (val) async {
                          await fs
                              .collection('coupons')
                              .doc(filteredDocs[index].id)
                              .update({'isActive': val});
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ================= VIEW: ADMINS MANAGEMENT =================

class AdminsView extends StatefulWidget {
  const AdminsView({super.key});

  @override
  State<AdminsView> createState() => _AdminsViewState();
}

class _AdminsViewState extends State<AdminsView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAdminAccount(String email, String password) async {
    setState(() => _isSubmitting = true);
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/subscription/admin/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password.trim(),
        }),
      );

      final result = jsonDecode(response.body);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Administrator account $email created successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          _emailController.clear();
          _passwordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${result['error']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create admin: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _updateAdminRole(String email, bool isAdmin) async {
    setState(() => _isSubmitting = true);
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/subscription/admin/grant-role'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': email.trim(), 'isAdmin': isAdmin}),
      );

      final result = jsonDecode(response.body);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAdmin
                    ? "Granted administrator status to $email successfully!"
                    : "Revoked administrator status from $email successfully!",
              ),
              backgroundColor: Colors.green,
            ),
          );
          if (isAdmin) {
            _emailController.clear();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${result['error']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Administrators",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage administrative rights and secure dashboard access",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (_isSubmitting)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
          ],
        ),
        const SizedBox(height: 32),

        // 🔹 ADD ADMIN CARD
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create New Administrator Account",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobileForm = constraints.maxWidth < 800;
                    
                    final emailField = TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Admin Email",
                        hintText: "Enter user's email address...",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    );

                    final passwordField = TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Assign Password",
                        hintText: "Enter a secure password...",
                        prefixIcon: Icon(Icons.key_outlined),
                        border: OutlineInputBorder(),
                      ),
                    );

                    final submitButton = SizedBox(
                      height: 56,
                      width: isMobileForm ? double.infinity : null,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();
                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Email and password are required."),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                _createAdminAccount(email, password);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add_moderator),
                        label: const Text("Create Admin"),
                      ),
                    );

                    if (isMobileForm) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          emailField,
                          const SizedBox(height: 16),
                          passwordField,
                          const SizedBox(height: 16),
                          submitButton,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: emailField),
                        const SizedBox(width: 16),
                        Expanded(child: passwordField),
                        const SizedBox(width: 16),
                        submitButton,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // 🔹 ADMINS LIST CARD
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Administrators",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: fs.collection('admins').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error: ${snapshot.error}",
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var docs = snapshot.data?.docs ?? [];
                        
                        // Sort in memory by grantedAt descending safely
                        docs.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;
                          final aTime = aData['grantedAt'] as Timestamp?;
                          final bTime = bData['grantedAt'] as Timestamp?;
                          if (aTime == null && bTime == null) return 0;
                          if (aTime == null) return 1;
                          if (bTime == null) return -1;
                          return bTime.compareTo(aTime);
                        });

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No other administrators registered. Use the panel or console to add more.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final email = data['email'] ?? '';
                            final grantedAt =
                                (data['grantedAt'] as Timestamp?)?.toDate();
                            final grantedAtStr =
                                grantedAt != null
                                    ? "${grantedAt.day}/${grantedAt.month}/${grantedAt.year} ${grantedAt.hour}:${grantedAt.minute.toString().padLeft(2, '0')}"
                                    : "N/A";

                            final currentUserEmail =
                                FirebaseAuth.instance.currentUser?.email;
                            final isSelf = email == currentUserEmail;

                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueGrey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(
                                email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("Granted on: $grantedAtStr"),
                              trailing:
                                  isSelf
                                      ? const Chip(
                                        label: Text("You"),
                                        backgroundColor: Colors.blue,
                                      )
                                      : OutlinedButton.icon(
                                        onPressed: _isSubmitting
                                            ? null
                                            : () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text("Revoke Administrator Access"),
                                                    content: Text("Are you sure you want to revoke admin access for $email? This user will immediately lose all dashboard privileges."),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text("Cancel"),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.redAccent,
                                                          foregroundColor: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          _updateAdminRole(email, false);
                                                        },
                                                        child: const Text("Revoke Access"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.redAccent,
                                          side: const BorderSide(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.remove_moderator,
                                          size: 16,
                                        ),
                                        label: const Text("Revoke Access"),
                                      ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
