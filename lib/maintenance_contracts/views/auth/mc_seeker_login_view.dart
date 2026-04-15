import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_seeker_auth_controller.dart';
import 'mc_seeker_register_view.dart';
import '../seeker/mc_seeker_dashboard_view.dart';

class McSeekerLoginView extends StatefulWidget {
  const McSeekerLoginView({super.key});

  @override
  State<McSeekerLoginView> createState() => _McSeekerLoginViewState();
}

class _McSeekerLoginViewState extends State<McSeekerLoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<McSeekerAuthController>();
      final error = await authController.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (error == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const McSeekerDashboardView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = context.watch<McSeekerAuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seeker Login"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.scaffoldBackgroundColor, const Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: Card(
              color: theme.cardTheme.color ?? (isDark ? Colors.black87 : Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
              ),
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_outlined, size: 40.sp, color: const Color(0xFF0EA5E9)),
                      SizedBox(height: 2.h),
                      Text(
                        "Seeker Portal",
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Find experts for repair and maintenance.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12.sp),
                      ),
                      SizedBox(height: 4.h),
                      
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0EA5E9)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? "Please enter your email" : null,
                      ),
                      SizedBox(height: 2.h),
                      
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0EA5E9)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? "Please enter your password" : null,
                      ),
                      
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EA5E9),
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: authController.isLoading ? null : _login,
                          child: authController.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text("Login", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const McSeekerRegisterView())),
                        child: Text("Need services? Register here", style: TextStyle(color: const Color(0xFF0EA5E9), fontSize: 13.sp)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
